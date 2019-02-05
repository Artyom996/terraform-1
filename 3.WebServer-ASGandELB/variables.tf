# Terraform Variable files
# File with name "variables.tf" will be added automatically to Template


#----------Variables--------------------
variable "myVPC_id" {
  default = "vpc-dfd21ba7"
}
variable "myPublicSubnetA_id" {
  default = "subnet-4b2b1e11"
}
variable "myPublicSubnetB_id" {
  default = "subnet-820f55fb"
}
variable "myInstanceSize" {
  default = "t3.micro"
}
