variable "vpc_cidr" {
  type = string
}

variable "profile" {
  type = string
}
variable "subnet_cidr" {
  type = list(any)
}

variable "region" {
  type = string
}

variable "public_key" {
  type = string
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string

}
variable "availability_zone" {
  type = list(string)

}
variable "db_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "db_password" {
  type = string
}

variable "db_allocated_storage" {
  type = number

}
variable "nametg" {
  type = string

}

variable "lbrname" {
  type = string
}
