provider "aws" {
  region = "ap-southeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-tienll-s3-backend"
    key            = "test-project"
    region         = "ap-southeast-1"
    encrypt        = true
    role_arn       = "arn:aws:iam::539051983169:role/Terraform-TienllS3BackendRole"
    dynamodb_table = "terraform-tienll-s3-backend"
  }
}


module "vpc" {
  source = "./vpc"

  vpc_cidr_block    = "10.0.0.0/16"
  private_subnet    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zone = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}


module "eks" {
  source = "./eks"
  private_subnet_id = module.vpc.private_subnet
  subnet_id = concat(module.vpc.private_subnet, module.vpc.public_subnet)
  instance_type = "t3.medium"  
  capacity_type = "SPOT"
  desired_size = 3
  min = 1
  max = 3
}



