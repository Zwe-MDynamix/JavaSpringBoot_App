# JavaSpringBoot_App

[![Build Status](https://img.shields.io/badge/CI%2FCD-Jenkins-blue)](http://localhost:8080)
[![Docker Pulls](https://img.shields.io/docker/pulls/zwelakhem/javaspringboot_app)](https://hub.docker.com/r/zwelakhem/javaspringboot_app)

## Overview

**JavaSpringBoot_App** is a sample LiveScore gaming application built with **Java Spring Boot**.  
It demonstrates a complete **DevOps CI/CD pipeline** including:

- **GitHub**: Source code management
- **Jenkins**: Automated build, test, and deployment
- **Maven**: Build and dependency management
- **Docker**: Containerization and image publishing
- **Docker Hub**: Image registry
- **Terraform**: Infrastructure provisioning (local Docker)
- **Ansible**: Automated deployment and container management

This project is ideal for **showcasing DevOps skills** for recruiters or interviews.

---

## Features

- REST endpoint: `/score`  
  Returns live game scores for a demo game:

```json
{
  "game": "Sky Heroes",
  "score": "3-2",
  "status": "live"
}

