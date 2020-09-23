variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "aws_sbunets" {
  type    = list
  default = "subnet-pu1,subnet-pu2"
}