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
}