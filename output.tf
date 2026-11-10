output "app_url" {
  value = "http://localhost:${var.web_port}/"
}

output "deployed_image" {
  value = docker_image.web.name
}
