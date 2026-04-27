
# VPC

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}


# SUBNET

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  availability_zone = "ap-south-1a"   

  tags = {
    Name = "devops-subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  availability_zone = "ap-south-1b"

  tags = {
    Name = "devops-subnet-2"
  }
}

resource "aws_db_subnet_group" "db_subnet" {
  name = "devops-db-subnet-1"

  subnet_ids = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  tags = {
    Name = "DevOps DB Subnet"
  }
}




# INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}


# ROUTE TABLE

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}


# SECURITY GROUP

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask app
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MySQL 
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 INSTANCE

resource "aws_instance" "ec2" {
  ami           = "ami-05d2d839d4f73aafb"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  key_name = "terra-key-ec2"

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y docker.io

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

# install docker-compose
curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOF

lifecycle {
  ignore_changes = [user_data]
}
  tags = {
    Name = "DevOps-EC2"
  }
}



# RDS (MYSQL)

resource "aws_db_instance" "mysql" {
  allocated_storage   = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "password123"
  skip_final_snapshot = true

  db_name = "mydb"

  # 👇 IMPORTANT (ADD THESE)
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.sg.id]

  publicly_accessible = true
}
