# security groupの作成
resource "aws_security_group" "main" {
  name_prefix = var.prefix
  description = "for ${var.prefix}-server"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.prefix}-ec2-sg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# IPv6アウトバウンドルール
resource "aws_vpc_security_group_egress_rule" "ipv6_outbound" {
  for_each          = var.security_group_rules.outbound_rules
  security_group_id = aws_security_group.main.id

  # IPv4 CIDRの代わりにIPv6 CIDRを使用
  cidr_ipv6 = each.value.cidr_ipv6
  from_port        = each.value.from_port
  ip_protocol      = each.value.ip_protocol
  to_port          = each.value.to_port
}

# IPv6インバウンドルール
resource "aws_vpc_security_group_ingress_rule" "ipv6_inbound" {
  for_each          = var.security_group_rules.inbound_rules
  security_group_id = aws_security_group.main.id

  # IPv4 CIDRの代わりにIPv6 CIDRを使用
  cidr_ipv6 = each.value.cidr_ipv6
  from_port        = each.value.from_port
  ip_protocol      = each.value.ip_protocol
  to_port          = each.value.to_port
}

# data "aws_ssm_parameter" "ubuntu" {
#   name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
# }

# amazon linux2023 for x86_64 のAMIを取得する
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

## ec2 role
data "aws_iam_policy_document" "main" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "main" {
  name_prefix        = "${var.prefix}-"
  assume_role_policy = data.aws_iam_policy_document.main.json
  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "main" {
  name = aws_iam_role.main.name
  role = aws_iam_role.main.name
}

resource "aws_instance" "main" {
  ami                         = data.aws_ssm_parameter.al2023.value
  instance_type               = var.ec2_instance_info.instance_type
  subnet_id                   = var.ec2_instance_info.subnet_id
  associate_public_ip_address = false
  
  # IPv6アドレスを有効化
  ipv6_address_count          = 1

  vpc_security_group_ids      = [aws_security_group.main.id]
  key_name                    = var.ec2_instance_info.key_pair_name
  iam_instance_profile        = aws_iam_instance_profile.main.name
  # user_data関連
  # user_data_replace_on_change = false
  # user_data                   = templatefile("${path.module}/templates/user_data.sh.tftpl", {
  #   prefix = var.prefix
  # })

  # IPv6 DNSレコードを有効化
  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = true
    hostname_type                        = "resource-name"
  }

  # ebs定義
  root_block_device {
    volume_size = var.ec2_instance_info.volume_size
    encrypted   = true
  }

  # IMDSv2の設定
  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.prefix}-server"
  }
}

