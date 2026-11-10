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
