# A Terraform module directory
```
terraform-modules/
  main.tf                    # Root module -- calls child modules
  variables.tf               # Root variables
  outputs.tf                 # Root outputs
  providers.tf               # Provider config
  modules/
    ec2-instance/
      main.tf                # EC2 resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
    security-group/
      main.tf                # Security group resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
```

# terraform-modules/modules/ec2-instance/main.tf
```
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true

lifecycle {
  create_before_destroy = true
}

  tags = merge(
    var.tags,
    {
      Name = var.instance_name
    }
  )
}

```

# terraform-modules/modules/ec2-instance/variables.tf
```

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
  default     = {}
}

```
# terraform-modules/modules/ec2-instance/outputs.tf

```
output "instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.web_server.public_ip
}

output "private_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.web_server.private_ip
}
```
# terraform-modules/modules/security-group/main.tf
```

resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group created using Terraform module"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
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

  tags = merge(
    var.tags,
    {
      Name = var.sg_name
    }
  )
}

```
# terraform-modules/modules/security-group/variables.tf
```

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_ports" {
  description = "List of inbound ports to allow"
  type        = list(number)
  default     = [22, 80]
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}

```
# terraform-modules/modules/security-group/outputs.tf
```

output "sg_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}
```
# terraform-modules/main.tf
```
# Here we are using the modules that we have created loacally


locals {
  common_tags = {
    Project     = "TerraWeek"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "terraweek-vpc"
  })
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "terraweek-public-subnet"
  })
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "terraweek-igw"
  })
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "terraweek-public-rt"
  })
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Call Security Group Module
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# Call EC2 Module - Web Server
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

# Call EC2 Module - API Server
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}


# Here we are using the  Public Registry Module 

# version = "5.1.0" -- exact version
# version = "~> 5.0" -- any 5.x version
# version = ">= 5.0, < 6.0" -- range

# Common tags
locals {
  common_tags = {
    Project     = "TerraWeek"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Official AWS VPC Registry Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  tags = local.common_tags
}

# Security Group Module
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = module.vpc.vpc_id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}

# Web Server EC2 Module
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

# API Server EC2 Module
module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = module.vpc.public_subnets[0]
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```
# terraform-modules/outputs.tf
```

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

# Security Group Output
output "security_group_id" {
  description = "ID of the shared security group"
  value       = module.web_sg.sg_id
}

# Web Server Outputs
output "web_server_id" {
  description = "ID of the web server"
  value       = module.web_server.instance_id
}

output "web_server_ip" {
  description = "Public IP of the web server"
  value       = module.web_server.public_ip
}

output "web_server_private_ip" {
  description = "Private IP of the web server"
  value       = module.web_server.private_ip
}

# API Server Outputs
output "api_server_id" {
  description = "ID of the API server"
  value       = module.api_server.instance_id
}

output "api_server_ip" {
  description = "Public IP of the API server"
  value       = module.api_server.public_ip
}

output "api_server_private_ip" {
  description = "Private IP of the API server"
  value       = module.api_server.private_ip
}
```

# terraform-modules/providers.tf
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
  region = "us-east-1"
}
```
# terraform-modules/variables.tf
```

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraweek"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "Dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ingress_ports" {
  description = "Inbound ports for the security group"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```
