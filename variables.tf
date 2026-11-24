variable "ubuntu_ami_id" {
  description = "ubuntu ami id"
  type        = string
}

variable "region" {
  description = "aws region Mumbai"
  type        = string
}

variable "worker_instance_type" {
  description = "k8s worker instance type"
  type        = string
}

variable "cp_instance_type" {
  description = "k8s control plane instance type"
  type        = string
}

variable "worker_1" {
  type = string
}

variable "worker_2" {
  type = string
}

variable "control_plane" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

variable "worker_count" {
  type    = number
  default = 1
}

variable "cp_count" {
  type = string
}

variable "workers" {
  type = list(string)
  default = [
    "worker-1",
  ]
}
