module "vpc_red" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.4"

  name = "vpc-red"
  cidr = "10.3.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  private_subnets = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
  public_subnets  = ["10.3.101.0/24", "10.3.102.0/24", "10.3.103.0/24"]

  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
    }
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = var.tags
}
