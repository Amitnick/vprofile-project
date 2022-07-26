provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "terraform-training-amit"
    key    = "terraform/terraform.tfstate"
    region = "us-east-2"
  }
}
#
#data "aws_eks_cluster" "cluster" {
#  name = module.eks.cluster_id
#}
#
#data "aws_eks_cluster_auth" "cluster" {
#  name = module.eks.cluster_id
#}

#provider "kubernetes" {
#  host = data.aws_eks_cluster.cluster.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster_auth.cluster.certificate_authority.0.data)
#  token = data.aws_eks_cluster_auth.cluster.token
#  load_config_file = false
#}
