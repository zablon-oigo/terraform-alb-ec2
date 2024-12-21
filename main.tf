provider "aws" {
}
data "aws_vpc" "vpc" {
  default = true
}
data "aws_subnet" "subnet1" {
}