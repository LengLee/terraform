# Var for Region
variable "region" {
  default = "us-east-1"
}

# Var for which AMI to spin up based on the Region defined
variable "amis" {
  type = "map"
  default = {
      "us-east-1" = "ami-b374d5a5"
      "us-west-1" = "ami-4b32be2b"
  }
}

