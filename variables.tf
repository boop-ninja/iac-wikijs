##################################################################
# Configurations
##################################################################

variable "dns_hostname" {
  type        = string
  description = "DNS For Service"
}

##################################################################
# Application Configuration
##################################################################

variable "namespace" {
  type        = string
  description = "Namespace of the deployment"
}

variable "database_name" {
  type        = string
  default     = "wiki"
  description = "Postgres Database Name"
}

variable "database_user" {
  type        = string
  default     = "wiki"
  description = "Postgres Database User"
}

variable "database_password" {
  type        = string
  default     = "P@ssw0rd!"
  description = "Postgres Database Password"
}

variable "docker_images" {
  type = map(any)
  default = {
    application = "requarks/wiki:2.5"
    database    = "mysql:8"
  }
}


