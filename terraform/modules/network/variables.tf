variable "common" {
  type = object({
    project     = string
    environment = string
    region      = string
    prefix_name = string
    tags        = map(string)
  })
}

variable "network" {
  type = object({
    my_ip_cidr = string
  })
}
