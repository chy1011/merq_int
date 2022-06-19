terraform {
  required_version = ">= 1.2.3"
}

resource "aws_security_group" "demo_sg" {
  name        = "demo_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from specific IPs"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["118.189.0.0/16", "116.206.0.0/16", "223.25.0.0/16"]
  }

  ingress {
    description = "Allow SSH from any"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "demo_instance" {
  depends_on = [
    aws_security_group.demo_sg
  ]

  ami                    = "ami-052efd3df9dad4825" # ubuntu 22.04
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  subnet_id              = var.private_subnet_id

  user_data = <<-EOF
    #! /bin/bash
    sudo apt update -y && upgrade
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y
    sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
    sudo systemctl restart docker
    sudo systemctl enable docker

    touch $HOME/index.html
    echo "Chan Hou Yong" > $HOME/index.html

    sudo docker pull nginx
    sudo docker run --name demo_nginx -p 80:80 -v $HOME/index.html:/usr/share/nginx/html/index.html -d nginx

    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo useradd -m merq -s /bin/bash
    sudo echo 'merq:Welcome@merq' | chpasswd
    sudo usermod -aG sudo merq
  EOF

  tags = {
    Name = "demo_instance"
  }
}
