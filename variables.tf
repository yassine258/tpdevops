variable "docker_host" {
  description = "Docker daemon socket (Linux/macOS: unix socket, Windows: npipe:////./pipe/docker_engine)"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "dockerhub_user" {
  description = "Docker Hub username / namespace"
  type        = string
}

variable "image_tag" {
  description = "Tag of counter-app to deploy (e.g. sha-abc1234, 1.0, latest)"
  type        = string
  default     = "latest"
}

variable "replicas" {
  description = "Number of web app containers behind the load balancer"
  type        = number
  default     = 3

  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "replicas must be between 1 and 10."
  }
}

variable "nginx_image" {
  type    = string
  default = "nginx:1.27-alpine"
}

variable "redis_image" {
  type    = string
  default = "redis:7-alpine"
}

variable "app_port" {
  description = "Port the app listens on inside the container"
  type        = number
  default     = 8787
}

variable "web_port" {
  description = "Port exposed on the host"
  type        = number
  default     = 8787
}
