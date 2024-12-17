resource "random_pet" "random" {}
data "aws_vpc" "default" {
  default = true
}