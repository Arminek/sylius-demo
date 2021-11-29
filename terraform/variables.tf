variable "main_domain" {
  type = string
  default = "sylius.com"
}

variable "cluster_name" {
  type = string
  default = "private-cloud"
}

variable "digital_ocean_access_token" {
  type = string
}

variable "nginx_namespace" {
  type = string
  default = "nginx-controller"
}

variable "nginx_controller_name" {
  type = string
  default = "ingress-nginx-controller"
}

variable "sub_domain" {
  type = string
  default = "swi-demo"
}

variable "module_namespace" {
  type = string
  default = "swibeco-demo"
}

variable "ghcr_username" {
  type = string
}

variable "ghcr_password" {
  type = string
}

variable "ghcr_email" {
  type = string
}

variable "ghcr_auth" {
  type = string
}

variable "app_name" {
  type = string
  default = "swibeco"
}

variable "env" {
  type = string
  default = "prod"
}

variable "app_docker_image" {
  type = string
}

variable "mysql_cluster_name" {
    type = string
    default = "mysql-cluster"
}
