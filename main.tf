provider "aws" {
}
data "aws_vpc" "vpc" {
  default = true
}
data "aws_subnet" "subnet1" {
    vpc_id = data.aws_vpc.vpc.id 
    availability_zone = "us-east-1a"
}
data "aws_subnet" "subnet2" {
    vpc_id = data.aws_vpc.vpc.id
    availability_zone = "us-east-1b"
}

resource "aws_security_group" "webserver_sg" {
  name = "webserver-sg"
  ingress {
    to_port = 80
    from_port = 80
    protocol = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress{
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "webserver" {
  ami = ""
  instance_type = "t2.micro"
  key_name = ""
  count = 2
  security_groups = [ aws_security_group.webserver_sg.name ]
  user_data = <<-EOF
  EOF
  tags = {
    Name="instance-${count.index}"
  }
  
}