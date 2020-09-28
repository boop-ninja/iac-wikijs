##################################################################
# Cloudflare Authentication
##################################################################

variable cloudflare_email {
  type        = string
  description = "Cloudflare email for authentication"
}

variable cloudflare_api_token {
  type        = string
  description = "Cloudflare api token for authentication"
}

##################################################################
# Kubernetes Authentication
##################################################################


variable kube_host {
  type        = string
  description = "Kuberentes Host"
}

variable kube_username {
  type        = string
  description = "Kubernetes Username"
}

variable kube_password {
  type        = string
  description = "Kubernetes Password"
}

##################################################################
# Cloudflare Configurations
##################################################################

variable dns_zone {
  type        = string
  description = "DNS Zone"
}

variable dns_hostname {
  type        = string
  description = "DNS For Service"
}

##################################################################
# Application Configuration
##################################################################

variable namespace {
  type        = string
  description = "Namespace of the deployment"
}

variable database_password {
  type        = string
  default     = "P@ssw0rd!"
  description = "Postgres Database Password"
}

variable docker_images {
  type = map(any)
  default = {
    application = "requarks/wiki:2.5"
    database    = "postgres:12"
  }
}