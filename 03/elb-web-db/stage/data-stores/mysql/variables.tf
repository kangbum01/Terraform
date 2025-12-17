variable "dbuser" {
  description = "DB User Name(ex: dbuser)"
  type = string
  sensitive = true
}

variable "dbpassword" {
  description = "DB User Password(ex: dbpassword)"
  type = string
  sensitive = true
}
