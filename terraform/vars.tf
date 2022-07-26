variable "AWS_REGION" {
  default = "us-east-2"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-2  = "ami-00978328f54e31526"
    us-east-1  = "ami-00978328f54e31526"
    ap-south-1 = "ami-0238411fb452f8275"
  }
}

variable "PRIV_KEY_PATH" {
  default = "vprofilekey"
}

variable "PUB_KEY_PATH" {
  default = "vprofilekey.pub"
}

variable "USER" {
  default = "ubuntu"
}

variable "MYIP" {
  default = "192.168.0.117/32"
}

variable "instance_count" {
  default = "1"
}

variable "VPC_NAME" {
  default = "vprofile-VPC"
}

variable "ZONE1" {
  default = "us-east-2a"
}

variable "ZONE2" {
  default = "us-east-2b"
}
variable "ZONE3" {
  default = "us-east-2c"
}

variable "VPC_CIDR" {
  default = "172.21.0.0/16"
}

variable "pubSub1CIDR" {
  default = "172.21.1.0/24"
}

variable "pubSub2CIDR" {
  default = "172.21.2.0/24"
}

variable "privSub1CIDR" {
  default = "172.21.4.0/24"
}

variable "privSub2CIDR" {
  default = "172.21.5.0/24"
}

variable "cluster-name" {
  default = "demo-cluster"
}