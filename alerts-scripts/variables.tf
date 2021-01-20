variable "location" {
  type = string
  default = "East US"
}
variable email_address {
type = string
default = "<here>"
}

variable "app_id" {
  type = string
  default = "00000000-0000-0000-0000-000000000000"
}

variable "client_id" {
  type = map
  default = {
    "dev"  = "<here>"
    "prod" = "<here>"
  }
}
variable "tenant_id" {
  type = map
  default = {
    "dev"  = "<here>"
    "prod" = "<here>"
  }
}

variable "subscription_id" {
  type = map
  default = {
    "dev"  = "<here>"
    "prod" = "<here>"
  }
}
