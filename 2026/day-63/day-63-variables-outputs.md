# providers.tf
```
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = var.region
}
```

# main.tf 
```
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}



# 1. Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

# 2. Create an Internet Gateway (allows public internet access)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-igw"
  })
}
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Create a Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet-cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-public-subnet"
  })
}

# 4. Create a Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-private-subnet"
  })
}

# 5. Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# 6. Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


# 1. Public Security Group (e.g., for Web Servers / Load Balancers)
resource "aws_security_group" "public_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP, HTTPS, and SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}
# 1. Dynamically fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. Launch the EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true

lifecycle {
  create_before_destroy = true
}

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-server"
  })
}

```

# variables.tf

```
variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc-cidr" {
  description = "VPC Cidr"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet-cidr" {
  description = "VPC Subnet Cidr"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance-type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}


variable "project_name" {
  description = "The name of the project used for resource naming and tagging."
  type        = string
  nullable    = false
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "allowed_ports" {
  description = "List of allowed ingress network ports."
  type        = list(number)
  default     = [22, 80, 443]
}

variable "extra_tags" {
  description = "Additional key-value tags to apply to resources."
  type        = map(string)
  default     = {}
}

```

# terraform.tfvars
```
project_name = "terraweek"
env  = "dev"
instance-type = "t2.micro"
```

# prod.tfvars
```
project_name = "terraweek"
env  = "prod"
instance-type = "t3.small"
vpc-cidr     = "10.1.0.0/16"
subnet-cidr  = "10.1.1.0/24"
```

# outputs.tf
```
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the public subnet."
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.web_server.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.web_server.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance."
  value       = aws_instance.web_server.public_dns
}

output "security_group_id" {
  description = "The ID of the security group."
  value       = aws_security_group.public_sg.id
}
```
