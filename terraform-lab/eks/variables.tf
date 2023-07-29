variable "private_subnet_id" {
  type    = list(string)
}

variable "subnet_id" {
  type    = list(string)
}

# variable "availability_zone" {
#   type    = list(string)
# }

variable "instance_type" {
  type        = string
}

variable "capacity_type" {
  type        = string
}


variable "desired_size" {
    type = number
}

variable "max"{
    type = number
}

variable "min"{
    type = number
}