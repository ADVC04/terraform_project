terraform {
    required_version = ">= 0.12"
    backend "s3" {
        bucket = "terraform-state-qaenv1"
        key = "myapp/state.tfstate"
        region = "ap-south-1"
    }
}

provider "aws" {
    region = var.region
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip, var.jenkins_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "example" {
  key_name = "example-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBCZWHsI9mz0waS1Al0JJnUvAUCofzFAoZ+kvn5QSn6YeKgEYGFqBeK9anLnXaReXp33A3BEFDvHjH7XBkv09P02MYbkfjs5uZ0gwiX+oduEbSOiqAtWPx8farhcYrBpUwdyR2V0PpFk3shUy8pVsZI+3DB8C6BtIi2Hun6Gm/UvZOl6OVDyYcfLcmAKXZqRRFd8CAD+uui9tii2Jvn+ZONUaRPauA7HpUUkv3oHbhurUnrZbvtLrNmqL5bVb57tukXQ0gWuYeUpi1KDD8RVNV+iqjPW8CLIkjRlWH4i9gRQR5yc/0zDgof9ddKqaVgCBpoQunkK01AWHtdc2Hmi1b5RoeAMLdl19sq0IjPb39z7O4WNFY4s8esvKFCNGZ/m6W/ZOjt0ZOzd4Z97xmF/o6IlBbtkDhjeeip7D6gevBJ6nP8+IuzpUYIJnbd5Oxnm1yRAKGcEThXrWgYo0EiBnRipkD9q8qsWtmeZLse9MVCRxE7F+T3ZWaY/MnKRtb2eE= sijju999@HighQ"
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name =   aws_key_pair.example.key_name
    user_data = file("entry-script.sh")

    tags = {
        Name = "${var.env_prefix}-server"
    }
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}