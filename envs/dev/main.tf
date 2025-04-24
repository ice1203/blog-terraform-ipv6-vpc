# network
module "main_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${local.prefix}-vpc"
  cidr = "172.18.0.0/16"

  # IPv6 CIDR ブロックを有効化
  enable_ipv6       = true
  public_subnet_assign_ipv6_address_on_creation = true
  private_subnet_assign_ipv6_address_on_creation = true

  # subnetが作成されるアベイラビリティゾーン
  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  
  # public subnetにはIPv4アドレスを割り当てる
  public_subnets  = ["172.18.128.0/24", "172.18.129.0/24"]

  # ipv6_native = trueにすることでIPv6のみのサブネットを作成することができる
  private_subnet_ipv6_native = true

  # IPv6のプレフィックス設定
  private_subnet_ipv6_prefixes = [1, 2]
  public_subnet_ipv6_prefixes  = [3, 4]

  # NAT Gateway等 の設定
  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_vpn_gateway                   = false

  # Internet Gateway と Egress-Only Internet Gateway の設定
  create_igw = true
  create_egress_only_igw = true

  # DNS設定
  enable_dns_hostnames = true
  enable_dns_support   = true
  public_subnet_enable_dns64  = false
  private_subnet_enable_dns64 = true

  # VPCフローログの設定
  enable_flow_log                      = false
  flow_log_max_aggregation_interval    = 60
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

}

module "ec2" {
  source = "../../modules/ec2"

  prefix = local.prefix
  vpc_id = module.main_vpc.vpc_id

  ec2_instance_info = {
    instance_type = "t3.micro"
    subnet_id = module.main_vpc.private_subnets[0]
    key_pair_name = var.ec2_key_pair_name
    volume_size   = 30
  }

  security_group_rules = {
    inbound_rules = {
    }
    outbound_rules = {
      all = {
        from_port   = -1
        to_port     = -1
        ip_protocol = "-1"
        cidr_ipv6   = "::/0"
      }
    }
  
  }
}
