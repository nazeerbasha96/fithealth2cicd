variable "fithealth_db_securtiy_cidr_block" {
  type = list(any)
}
variable "db_name" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}

variable "db_allocated_storage" {
  type = number

}
variable "vpc_id" {
  type = string
  
}
variable "subnet_ids" {
  type = list(any)
}

