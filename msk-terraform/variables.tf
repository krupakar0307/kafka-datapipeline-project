# This variable defines the AWS Region.
variable "region" {
  description = "aws region"
  type        = string
  default     = "ap-south-1"
}

variable "msk_name" {
  type    = string
  default = "msk-dev"
}