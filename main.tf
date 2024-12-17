provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      owner       = "Serhii"
      provisioner = "Terraform"
      project = "cron-ubuntu"
    }
  }
}

resource "tls_private_key" "ec2-keypair" {
  algorithm = var.keypair.algorithm
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.ec2-keypair.private_key_openssh
  filename = var.keypair.filename

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }
}
resource "aws_key_pair" "ec2-keypair" {
  key_name   = "${var.keypair.name}-${random_pet.random.id}"
  public_key = tls_private_key.ec2-keypair.public_key_openssh
}

resource "aws_instance" "cron" {
  ami             = var.instance.ami
  instance_type   = var.instance.type
  key_name        = aws_key_pair.ec2-keypair.key_name
  security_groups = [aws_security_group.vpc-web.name]

  connection {
    user        = "ubuntu"
    private_key = tls_private_key.ec2-keypair.private_key_openssh
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/home/ubuntu/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/script.sh",
      "sudo /home/ubuntu/script.sh"
    ]
  }
}


resource "aws_security_group" "vpc-web" {
  name        = "sg"
  vpc_id      = data.aws_vpc.default.id
  description = "Web Traffic"

  ingress {
    description = "Allow all port access"
    from_port   = 22
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all port access"
    from_port   = 22
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}