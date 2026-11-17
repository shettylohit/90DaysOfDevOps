# Project structure

```
terraweek-capstone/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── locals.tf
├── dev.tfvars
├── staging.tfvars
├── prod.tfvars
├── .gitignore
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security-group/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ec2-instance/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

# terraweek-capstone/modules/ec2-instance/main.tf
```

resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-ec2"
    Environment = var.environment
    Project     = var.project_name
  })
}

```

# terraweek-capstone/modules/ec2-instance/outputs.tf

```

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.main.public_ip
}

```

# terraweek-capstone/modules/ec2-instance/variables.tf

```

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
```

# terraweek-capstone/modules/security-group/main.tf

```

resource "aws_security_group" "main" {
  name        = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports

    content {
      description = "Allow TCP port ${ingress.value}"
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

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-sg"
    Environment = var.environment
    Project     = var.project_name
  })
}

```

# terraweek-capstone/modules/security-group/outputs.tf

```

output "sg_id" {
  description = "Security group ID"
  value       = aws_security_group.main.id
}

```

# terraweek-capstone/modules/security-group/variables.tf

```

variable "vpc_id" {
  description = "VPC ID where security group will be created"
  type        = string
}

variable "ingress_ports" {
  description = "List of inbound TCP ports"
  type        = list(number)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
```

# terraweek-capstone/modules/vpc/main.tf

```

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-subnet"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

```

#  terraweek-capstone/modules/vpc/outputs.tf
```

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}
```

# terraweek-capstone/modules/vpc/variables.tf

```

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
```
# terraweek-capstone/main.tf

```

module "vpc" {
  source = "./modules/vpc"

  cidr               = var.vpc_cidr
  public_subnet_cidr = var.subnet_cidr

  environment = local.environment
  project_name = var.project_name
  common_tags = local.common_tags
}

module "security_group" {
  source = "./modules/security-group"

  vpc_id        = module.vpc.vpc_id
  ingress_ports = var.ingress_ports

  environment  = local.environment
  project_name = var.project_name
  common_tags = local.common_tags
}

module "ec2_instance" {
  source = "./modules/ec2-instance"

  ami_id             = var.ami_id
  instance_type      = var.instance_type
  subnet_id          = module.vpc.subnet_id
  security_group_ids = [module.security_group.sg_id]

  environment  = local.environment
  project_name = var.project_name
  common_tags = local.common_tags
}
```
# terraweek-capstone/outputs.tf

```

output "vpc_id" {
  description = "Created VPC ID"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.subnet_id
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security_group.sg_id
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  description = "EC2 public IP"
  value       = module.ec2_instance.public_ip
}

```
# terraweek-capstone/variables.tf

```
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraweek"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "subnet_cidr" {
  description = "Public subnet CIDR block"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ingress_ports" {
  description = "Allowed inbound TCP ports"
  type        = list(number)
  default     = [22, 80]
}

variable "ami_id" {
  description = "AWS EC2 AMI ID"
  type        = string
  default = "ami-096ef200a877f36af"

}
```
# terraweek-capstone/locals.tf

```
locals {
  environment = terraform.workspace

  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}
```
# terraweek-capstone/dev.tfvars

```

vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
instance_type = "t2.micro"
ingress_ports = [22, 80]

```
# terraweek-capstone/prod.tfvars

```

vpc_cidr      = "10.2.0.0/16"
subnet_cidr   = "10.2.1.0/24"
instance_type = "t3.small"
ingress_ports = [80, 443]

```

# terraweek-capstone/staging.tfvars

```

vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
instance_type = "t2.small"
ingress_ports = [22, 80, 443]

```
