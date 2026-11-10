output "app_url" {
  value = "http://localhost:${var.web_port}/"
}

output "web_replicas" {
  value = docker_container.web[*].name
}

output "deployed_image" {
  value = docker_image.web.name
}
