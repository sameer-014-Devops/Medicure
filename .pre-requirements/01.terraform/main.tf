# creating a resources in AWS using terraform (VPC, Subnet, Security Group, Route Table, Internet Gateway, EC2 Instance)
# availability zones: ap-northeast-1a, ap-northeast-1c, ap-northeast-1d
# Create Key pair name as "Devops"
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.access_key
  secret_key = var.secret_key
}
variable "access_key" {}
variable "secret_key" {}

# Creating VPC
resource "aws_vpc" "Project-vpc" {
  cidr_block = "14.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Project-VPC"
  }
}

# Creating 2 Subnets 
resource "aws_subnet" "Project-pub-sub-a1" {
  vpc_id     = aws_vpc.Project-vpc.id
  cidr_block = "14.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Project-pub-sub-a1"
  }
}   
resource "aws_subnet" "Project-pub-sub-b1" {
  vpc_id     = aws_vpc.Project-vpc.id
  cidr_block = "14.0.14.0/24"
  availability_zone = "ap-northeast-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "Project-pub-sub-b1"
  }
}

# Creating 5 Security Group
# For Jenkins master node
resource "aws_security_group" "Project-SG-JM" {
  name        = "Project-SG-JM"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.Project-vpc.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG-JM"
  }
}

# For Test server
resource "aws_security_group" "Project-SG-TS" {
  name        = "Project-SG-TS"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.Project-vpc.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG-TS"
  }
}

# For kubernetes Master
resource "aws_security_group" "Project-SG-KM" {
  name        = "Project-SG-KM"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.Project-vpc.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 2379
    to_port          = 2380
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 10250
    to_port          = 10259
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG-KM"
  }
}

# For kubernetes Worker Nodes
resource "aws_security_group" "Project-SG-KW" {
  name        = "Project-SG-KW"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.Project-vpc.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 10250
    to_port          = 10256
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG-KW"
  }
}

# Default to allow all traffic
resource "aws_security_group" "Project-SG-Default" {
  name        = "Project-SG-Default"
  description = "Allow All traffic"
  vpc_id      = aws_vpc.Project-vpc.id
  ingress {
    description      = "All traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Project-SG-Default"
  }
}

# Creating 1 Internet Gateway
resource "aws_internet_gateway" "Project-igw" {
  vpc_id = aws_vpc.Project-vpc.id
  tags = {
    Name = "Project-igw"
  }
}

# Creating 2 Route Tables
resource "aws_route_table" "Project-pub-rt1" {
  vpc_id = aws_vpc.Project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project-igw.id
  }
  tags = {
    Name = "Project-pub-rt1"
  }
}
resource "aws_route_table" "Project-pub-rt2" {
  vpc_id = aws_vpc.Project-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project-igw.id
  }
  tags = {
    Name = "Project-pub-rt2"
  }
}

# Creating 2 Route Table Associations
resource "aws_route_table_association" "Project-pub-sub-a1-rt" {
  subnet_id      = aws_subnet.Project-pub-sub-a1.id
  route_table_id = aws_route_table.Project-pub-rt1.id
}
resource "aws_route_table_association" "Project-pub-sub-b1-rt" {
  subnet_id      = aws_subnet.Project-pub-sub-b1.id
  route_table_id = aws_route_table.Project-pub-rt2.id
}

# Creating 4 Elastic IPs
resource "aws_eip" "Project-eip-JM" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-JM"
  }
}
resource "aws_eip" "Project-eip-TS" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-TS"
  }
}
resource "aws_eip" "Project-eip-KW1" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-KW1"
  }
}
resource "aws_eip" "Project-eip-KW2" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-KW2"
  }
}

# Instance Creating
# Jenkins master node
resource "aws_instance" "Jenkins-Master" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-a1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-JM.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Devops"
  tags = {
    Name = "Jenkins-Master"
  }
}
# Kubernetes master node
resource "aws_instance" "Kubernetes-Master" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KM.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Devops"
  tags = {
    Name = "Kubernetes-Master"
  }
}
# Ansible master node
resource "aws_instance" "Ansible-Master" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-a1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-Default.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Devops"
  tags = {
    Name = "Ansible-Master"
  }
}
# Build Node MVN
resource "aws_instance" "Build-Node-mvn" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-Default.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 16
  }
  key_name = "Devops"
  tags = {
    Name = "Build-Node-mvn"
  }
}
# Test server
resource "aws_instance" "Test-Server" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-TS.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 16
  }
  key_name = "Devops"
  tags = {
    Name = "Test-Server"
  }
}
# Kubernetes worker node 01
resource "aws_instance" "Kubernetes-Worker-01" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KW.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Devops"
  tags = {
    Name = "Kubernetes-Worker-01"
  }
}
# Kubernetes worker node 02
resource "aws_instance" "Kubernetes-Worker-02" {
  ami           = "ami-08f191dd81ec3a3de"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KW.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Devops"
  tags = {
    Name = "Kubernetes-Worker-02"
  }
}

#Associate EIPs with instances
resource "aws_eip_association" "Project-eip-JM" {
  instance_id   = aws_instance.Jenkins-Master.id
  allocation_id = aws_eip.Project-eip-JM.id
}
resource "aws_eip_association" "Project-eip-TS" {
  instance_id   = aws_instance.Test-Server.id
  allocation_id = aws_eip.Project-eip-TS.id
}
resource "aws_eip_association" "Project-eip-KW1" {
  instance_id   = aws_instance.Kubernetes-Worker-01.id
  allocation_id = aws_eip.Project-eip-KW1.id
}
resource "aws_eip_association" "Project-eip-KW2" {
  instance_id   = aws_instance.Kubernetes-Worker-02.id
  allocation_id = aws_eip.Project-eip-KW2.id
}
