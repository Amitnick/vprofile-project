module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = var.VPC_NAME
  cidr            = var.VPC_CIDR
  azs             = [var.ZONE1, var.ZONE2, var.ZONE3]
  private_subnets = [var.privSub1CIDR, var.privSub2CIDR]
  public_subnets  = [var.pubSub1CIDR, var.pubSub2CIDR]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "Prod"
  }

  vpc_tags = {
    Name = var.VPC_NAME
  }
}