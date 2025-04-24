variable "prefix" {
  type        = string
  description = "resource name prefix"
}
variable "vpc_id" {
  type        = string
  description = "vpc id"

}
variable "ec2_instance_info" {
  type = object({
    instance_type = string
    subnet_id     = string
    key_pair_name = string
    volume_size   = optional(number, 30)
  })
  description = "ec2 instance information"

}

variable "security_group_rules" {
  description = "Security group rules"
  type = object({
    inbound_rules = map(object({
      cidr_ipv4       = optional(string)
      cidr_ipv6 = optional(string)
      from_port       = number
      ip_protocol     = string
      to_port         = number
    }))
    outbound_rules = map(object({
      cidr_ipv4       = optional(string)
      cidr_ipv6 = optional(string)
      from_port       = number
      ip_protocol     = string
      to_port         = number
    }))
  })
}