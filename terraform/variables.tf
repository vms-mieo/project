variable "region" {
  default = "us-east-1"
}
variable "network_address_space" {
  description = "Network address space for VPC"
  default = "10.100.0.0/16"
}
variable "subnet_public" {
    description = "Address space for subnet public"
    default = "10.100.1.0/24"
  
}
variable "key_name" {
    default = "demo-instance"
  
}