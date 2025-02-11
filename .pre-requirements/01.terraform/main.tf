# creating a resources in AWS using terraform (VPC, Subnet, Security Group, Route Table, Internet Gateway, EC2 Instance)
# availability zones: ap-northeast-1a, ap-northeast-1c, ap-northeast-1d
# Create Key pair name as "Medicure"

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}
variable "access_key" {
  description = "AWS Access Key"
}
variable "secret_key" {
  description = "AWS Secret Key"
}
# Creating VPC
resource "aws_vpc" "Project-Medicure-vpc" {
  cidr_block = "14.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Project-Medicure-VPC"
  }
}

# Creating 2 Subnets 
resource "aws_subnet" "Project-pub-sub-a1" {
  vpc_id     = aws_vpc.Project-Medicure-vpc.id
  cidr_block = "14.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Project-pub-sub-a1"
  }
}   
resource "aws_subnet" "Project-pub-sub-b1" {
  vpc_id     = aws_vpc.Project-Medicure-vpc.id
  cidr_block = "14.0.14.0/24"
  availability_zone = "eu-west-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "Project-pub-sub-b1"
  }
}

# Creating 1 Internet Gateway
resource "aws_internet_gateway" "Project-igw" {
  vpc_id = aws_vpc.Project-Medicure-vpc.id
  tags = {
    Name = "Project-igw"
  }
}

# Creating 2 Route Tables
resource "aws_route_table" "Project-pub-rt1" {
  vpc_id = aws_vpc.Project-Medicure-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project-igw.id
  }
  tags = {
    Name = "Project-pub-rt1"
  }
}
resource "aws_route_table" "Project-pub-rt2" {
  vpc_id = aws_vpc.Project-Medicure-vpc.id
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
# For Jenkins Master Node
resource "aws_eip" "Project-eip-JM" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-JM"
  }
}
# For Test Server
resource "aws_eip" "Project-eip-TS" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-TS"
  }
}
# For Kubernetes Worker Node 01
resource "aws_eip" "Project-eip-KW1" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-KW1"
  }
}
# For Kubernetes Worker Node 02
resource "aws_eip" "Project-eip-KW2" {
  associate_with_private_ip = true
  depends_on = [aws_internet_gateway.Project-igw]
  tags = {
    Name = "Project-eip-KW2"
  }
}

# Creating 5 Security Group
# For Jenkins master node
resource "aws_security_group" "Project-SG-JM" {
  name        = "Project-SG-JM"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.Project-Medicure-vpc.id
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
  vpc_id      = aws_vpc.Project-Medicure-vpc.id
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
    to_port          = 8085
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
  vpc_id      = aws_vpc.Project-Medicure-vpc.id
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
  vpc_id      = aws_vpc.Project-Medicure-vpc.id
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
  vpc_id      = aws_vpc.Project-Medicure-vpc.id
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

# Creating Key Pair
resource "tls_private_key" "skmirza_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}
# Ansible master node
resource "aws_instance" "Ansible-Master" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-a1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-Default.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Medicure"
  tags = {
    Name = "Ansible-Master"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [
      "sudo -i apt update -y",
      "sudo -i apt install software-properties-common",
      "sudo -i add-apt-repository --yes --update ppa:ansible/ansible",
      "sudo -i apt install ansible -y",
      "sudo -i apt install openjdk-17-jre -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "sudo -i chown -R skmirza:skmirza /etc/ansible",
      "sudo -i mkdir -p /home/skmirza/.ssh",
      "echo '${tls_private_key.skmirza_ssh_key.private_key_pem}' | sudo -i tee /home/skmirza/.ssh/id_rsa",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/id_rsa.pub",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/id_rsa",
      "sudo -i chmod 600 /home/skmirza/.ssh/id_rsa.pub",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}
resource "null_resource" "Copy_Yaml_Files" {
  provisioner "local-exec" {
    command= "scp -o StrictHostKeyChecking=no -i /path/to/Medicure.pem /path/to/*.yaml ubuntu@${aws_instance.Ansible-Master.public_ip}:/home/ubuntu/"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = aws_instance.Ansible-Master.public_ip
    }
    inline = [
      "sudo -i mv /home/ubuntu/*.yaml /etc/ansible/",
      "sudo -i chown -R skmirza:skmirza /etc/ansible/*.yaml"
    ]  
  }
}

# Jenkins master node
resource "aws_instance" "Jenkins-Master" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-a1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-JM.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Medicure"
  tags = {
    Name = "Jenkins-Master"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

# Kubernetes master node
resource "aws_instance" "Kubernetes-Master" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-a1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KM.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Medicure"
  tags = {
    Name = "Kubernetes-Master"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [  
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

# Build Node Maven
resource "aws_instance" "Build-Node-mvn" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-Default.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 16
  }
  key_name = "Medicure"
  tags = {
    Name = "Build-Node-mvn"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [  
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

# Test server
resource "aws_instance" "Test-Server" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-TS.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 16
  }
  key_name = "Medicure"
  tags = {
    Name = "Test-Server"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [  
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

# Kubernetes worker node 01
resource "aws_instance" "Kubernetes-Worker-01" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KW.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Medicure"
  tags = {
    Name = "Kubernetes-Worker-01"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [  
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

# Kubernetes worker node 02
resource "aws_instance" "Kubernetes-Worker-02" {
  ami           = "ami-06cff85354b67982b"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.Project-pub-sub-b1.id
  vpc_security_group_ids = [aws_security_group.Project-SG-KW.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }
  key_name = "Medicure"
  tags = {
    Name = "Kubernetes-Worker-02"
  }
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = self.public_ip
    }
    inline = [  
      "sudo -i apt update -y",
      "sudo -i useradd skmirza -s /bin/bash -m -d /home/skmirza",
      "echo 'skmirza:YOURPASSWD' | sudo -i chpasswd",
      "echo 'PasswordAuthentication yes' | sudo -i tee -a /etc/ssh/sshd_config",
      "sudo -i service ssh reload",
      "echo 'skmirza ALL=(ALL) NOPASSWD: ALL' | sudo -i tee -a /etc/sudoers",
      "echo 'YOURPASSWD' | su - skmirza -c 'mkdir -p /home/skmirza/.ssh'",
      "echo '${tls_private_key.skmirza_ssh_key.public_key_openssh}' | sudo -i tee -a /home/skmirza/.ssh/authorized_keys",
      "sudo -i chown -R skmirza:skmirza /home/skmirza/.ssh",
      "sudo -i chmod 700 /home/skmirza/.ssh",
      "sudo -i chmod 600 /home/skmirza/.ssh/authorized_keys"
    ]
  }
}

resource "null_resource" "Config_Ansible-Master" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/path/to/Medicure.pem")
      host     = aws_instance.Ansible-Master.public_ip
    }
    inline = [
      "echo '[JenkinsMaster]' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'JenM ansible_ssh_host=${aws_instance.Jenkins-Master.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo '' | sudo tee -a /etc/ansible/hosts",
      "echo '[BuildNodes]' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'BN01 ansible_ssh_host=${aws_instance.Build-Node-mvn.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo '' | sudo tee -a /etc/ansible/hosts",
      "echo '[TestServers]' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'TCS ansible_ssh_host=${aws_instance.Test-Server.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo '' | sudo tee -a /etc/ansible/hosts",
      "echo '[ProdMaster]' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'PM ansible_ssh_host=${aws_instance.Kubernetes-Master.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo '' | sudo tee -a /etc/ansible/hosts",
      "echo '[ProdWorkers]' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'PW01 ansible_ssh_host=${aws_instance.Kubernetes-Worker-01.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo 'PW02 ansible_ssh_host=${aws_instance.Kubernetes-Worker-02.private_ip} ansible_ssh_user=skmirza' | sudo -i tee -a /etc/ansible/hosts",
      "echo '' | sudo -i tee -a /etc/ansible/hosts"
    ]
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
resource "aws_eip_association" "Project-eip-KW2" {
  instance_id   = aws_instance.Kubernetes-Worker-02.id
  allocation_id = aws_eip.Project-eip-KW2.id
}
