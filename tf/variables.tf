variable "client_id" {
  type = string
}

variable "secret" {
  type = string
}

variable "issuer" {
  type = string
}

variable "mf_broker_host" {
  type = string
}

variable "name" {
  type = string
}

variable "type" {
  type = string
}

variable "locations" {
  type = list(string)
}

variable "instances" {
  type = number
}

variable "swap" {
  type = number
}

variable "size" {
  type = string
}

variable "cname_pattern" {
  type = list(string)
}

variable "lb_route_prefixes" {
  type = list(string)
}
