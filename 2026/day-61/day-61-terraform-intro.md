```
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "tws-1219"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "my-web-server"

  ami                    = "ami-096ef200a877f36af" # Replace with a valid AMI ID for your region
  instance_type          = "t2.micro"
  monitoring             = true
  subnet_id              = "subnet-0c894ec81dd7bcc7e"
  tags = {
    Name = "TerraWeek-Day1"
  }
}
```
