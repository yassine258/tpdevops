terraform {
  required_version = ">= 1.5"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }

  # State path is passed at init time (-backend-config) so it lives
  # OUTSIDE the repo checkout and survives between workflow runs.
  backend "local" {}
}

provider "docker" {
  host = var.docker_host
}

# ---------------- Network & volume ----------------
resource "docker_network" "app" {
  name = "app-network"
}

resource "docker_volume" "redis_data" {
  name = "redis-data"
}

# ---------------- Redis ----------------
resource "docker_image" "redis" {
  name         = var.redis_image
  keep_locally = true
}

resource "docker_container" "redis" {
  name    = "db-service"
  image   = docker_image.redis.image_id
  command = ["redis-server", "--appendonly", "yes"]
  restart = "unless-stopped"

  networks_advanced {
    name    = docker_network.app.name
    aliases = ["db-service"]
  }

  volumes {
    volume_name    = docker_volume.redis_data.name
    container_path = "/data"
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }

  # Equivalent of compose "condition: service_healthy"
  wait         = true
  wait_timeout = 60
}

# ---------------- Web app ----------------
data "docker_registry_image" "web" {
  name = "${var.dockerhub_user}/counter-app:${var.image_tag}"
}

resource "docker_image" "web" {
  name          = data.docker_registry_image.web.name
  pull_triggers = [data.docker_registry_image.web.sha256_digest] # re-pull when image changes
  keep_locally  = false
}

resource "docker_container" "web" {
  count   = var.replicas
  name    = "counter-web-${count.index + 1}"
  image   = docker_image.web.image_id
  restart = "unless-stopped"

  env = [
    "REDIS_HOST=db-service",
    "APP_PORT=${var.app_port}",
  ]

  # No host port here: replicas can't share one port.
  # Traffic reaches them through the nginx load balancer below.
  networks_advanced {
    name    = docker_network.app.name
    aliases = ["web"]
  }

  depends_on = [docker_container.redis]
}

# ---------------- Load balancer (nginx) ----------------
locals {
  nginx_conf = <<-EOT
    events {}
    http {
      upstream counter_app {
      %{~ for n in docker_container.web[*].name }
        server ${n}:${var.app_port};
      %{~ endfor }
      }
      server {
        listen 80;
        location / {
          proxy_pass http://counter_app;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          add_header X-Upstream $upstream_addr always;  # shows which replica answered
        }
      }
    }
  EOT
}

resource "docker_image" "nginx" {
  name         = var.nginx_image
  keep_locally = true
}

resource "docker_container" "lb" {
  name    = "counter-lb"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  # Config is regenerated when replicas change -> LB is recreated automatically
  upload {
    content = local.nginx_conf
    file    = "/etc/nginx/nginx.conf"
  }

  ports {
    internal = 80
    external = var.web_port
  }

  networks_advanced {
    name = docker_network.app.name
  }
}
