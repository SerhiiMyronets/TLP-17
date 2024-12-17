variable "instance" {
  type = map(string)
  default = {
    type = "t2.micro"
    ami  = "ami-005fc0f236362e99f"
  }
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "keypair" {
  type = map(string)
  default = {
    name      = "ec2_keypair"
    algorithm = "ED25519"
    filename  = "ec2-keypair.pem"
  }
}