
provider "aws" {
  alias    = "aws"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

# Create a VPC
resource "aws_vpc" "vpc_name" {
  cidr_block = "10.0.0.0/16" # Adjust CIDR as necessary
  tags = {
    Name = "vpc_name"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "your_igw" {
  vpc_id = aws_vpc.your_vpc.id
  tags = {
    Name = "your_igw" 
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "route_table_name" { #route_table_name
  vpc_id = aws_vpc.vpc_name.id #vpc name
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.your_igw_name.id #your_igw name
  }
  tags = {
    Name = "your_PublicRouteTable"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "your_name_rt__assoc" { # your_aws_route_table assocation
  subnet_id      = aws_subnet.subnet_name.id
  route_table_id = aws_route_table.your_route_name_rt.id
}

# Create a subnet within the VPC
resource "aws_subnet" "subnet_name" {
  vpc_id                = aws_vpc.vpc_name.id #vpc name
  cidr_block            = "10.0.2.0/24" # Change this to a non-conflicting CIDR block
  availability_zone     = "us-east-1a"  # Adjust as necessary
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet_name"
  }
}

# Create a security group to allow traffic
resource "aws_security_group" "prometheus_sg_1" {
  name_prefix = "your_sg_name" # Security group_name
  vpc_id      = aws_vpc.vpc_name.id # VPC_name
  
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
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

# Define an EC2 instance to run Prometheus
resource "aws_instance" "your_instance name" { #name of instance
  ami                    = "your_ami_" #  your ami 
  instance_type          = "t2.micro"
  key_name               = "SELECT_PRIVATEKEY"       #SAVE YOUR KEY IN LOCAL SYSTEM
  subnet_id              = aws_subnet.yoursubnet.id # Reference the subnet
  vpc_security_group_ids = [aws_security_group.your_sg_.id] # Use the security group ID




# Install Prometheus using user_data script
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo useradd --no-create-home --shell /bin/false prometheus
              sudo mkdir /etc/prometheus
              sudo mkdir /var/lib/prometheus
              sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
              cd /tmp
              wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz
              tar -xvf prometheus-2.37.0.linux-amd64.tar.gz
              sudo cp prometheus-2.37.0.linux-amd64/prometheus /usr/local/bin/
              sudo cp prometheus-2.37.0.linux-amd64/promtool /usr/local/bin/
              sudo cp -r prometheus-2.37.0.linux-amd64/consoles /etc/prometheus
              sudo cp -r prometheus-2.37.0.linux-amd64/console_libraries /etc/prometheus
              sudo cp prometheus-2.37.0.linux-amd64/prometheus.yml /etc/prometheus
              sudo chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
              sudo chown -R prometheus:prometheus /etc/prometheus
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              cd /usr/share/nginx/html/
              sudo rm -rf index.html
              sudo scp (source) /var/www/html/index.html
              sudo mkdir -p /etc/nginx/sites-available/default
              sudo scp (source) /var/www/html/index.html
              sudo nginx -t
              sudo systemctl daemon-reload
              sudo systemctl restart nginx
              sudo usermod -aG wheel prometheus
              echo '[Unit]
              Description=Prometheus Monitoring
              After=network.target
              [Service]
              User=prometheus
              Group=prometheus
              ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/
              [Install]
              WantedBy=multi-user.target' | sudo tee /etc/systemd/system/prometheus.service
              sudo systemctl daemon-reload
              sudo systemctl enable prometheus
              sudo systemctl start prometheus
              EOF

  tags = {
    Name = "Prometheus-Instance"
  }
}


  
  
  
