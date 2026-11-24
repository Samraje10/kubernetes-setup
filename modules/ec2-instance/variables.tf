variable "ami_id" {

    type = string

}

variable "instance_type" {
    type = string
    
}

variable "vpc_security_group_ids" {
    type = list(string)

}

variable "key_name" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "name" {
    type = string
}

variable "volume_size" {
    type = number
    default = 20
}

variable "volume_type" {
    type = string
}

variable "instance_name" {
    type = string
}
