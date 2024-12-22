provider "aws" {
}
data "aws_vpc" "vpc" {
  default = true
}
data "aws_subnet" "subnet1" {
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = "us-east-1a"
}
data "aws_subnet" "subnet2" {
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = "us-east-1b"
}

resource "aws_security_group" "webserver_sg" {
  name = "webserver-sg"
  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "webserver" {
  ami             = ""
  instance_type   = "t2.micro"
  key_name        = ""
  count           = 2
  security_groups = [aws_security_group.webserver_sg.name]
  user_data       = <<-EOF
      #! /bin/bash
      yum update -y
      yum install httpd -y
      systemctl enable httpd
      systemctl start httpd
   echo "<html><h1 style='color:green'>Hello World, Server is running in: $(hostname) </h1></html>" > /var/www/html/index.html
   EOF
  tags = {
    Name = "instance-${count.index}"
  }

}
resource "aws_lb_target_group" "target_group" {
  health_check {
    interval            = 10
    protocol            = "HTTP"
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  name        = "my-target-group"
  protocol    = "HTTP"
  port        = 80
  target_type = "instance"
  vpc_id      = data.aws_vpc.vpc.id
}
resource "aws_lb" "webserver_alb" {
  name               = "web-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  subnets            = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  security_groups    = [aws_security_group.webserver_sg.id]

  tags = {
    Name = "web-alb"
  }
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.webserver_alb.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"
  }
}
resource "aws_lb_target_group_attachment" "attach" {
  count            = length(aws_instance.webserver)
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.webserver[count.index].id

}