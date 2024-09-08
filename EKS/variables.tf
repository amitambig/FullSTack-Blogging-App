variable "ssh_key_name" {
  description = "The name of the SSH key pair to use for instances"
  type        = string
  default     = "myKey"
}
variable "subnet_cidr" {
  default = ["10.0.1.0/24","10.0.2.0/24"]
}