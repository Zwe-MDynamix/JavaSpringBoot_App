terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.19"
    }
  }
}
provider "docker" {}
resource "docker_image" "live_score" {
  name = "zwelakhem/javaspringboot_app:latest"
}
resource "docker_container" "live_score" {
  name  = "javaspringboot_app"
  image = docker_image.live_score.latest
  ports { internal = 8080, external = 8080 }
}
