# JavaSpringBoot_App

[![Build Status](https://img.shields.io/badge/CI%2FCD-Jenkins-blue)](http://localhost:8080)
[![Docker Pulls](https://img.shields.io/docker/pulls/zwelakhem/javaspringboot_app)](https://hub.docker.com/r/zwelakhem/javaspringboot_app)

## Overview

JavaSpringBoot_App is a sample LiveScore gaming application built with **Spring Boot**.  
It demonstrates a complete **DevOps CI/CD pipeline** including:

- GitHub: Source code management
- Jenkins: Automated build, test, Docker, and deployment
- Maven: Build automation
- Docker: Containerization
- Docker Hub: Image registry
- Terraform: Infrastructure provisioning
- Ansible: Deployment automation

________________________________________________________________________________

## Quick Start

1. Clone the repo:

```bash
git clone https://github.com/zwelakhem/JavaSpringBoot_App.git
cd JavaSpringBoot_App

2. Run demo script:
./demo_run.sh

3. Test API:
curl http://localhost:8080/score
Expected output:
{"game":"Sky Heroes","score":"3-2","status":"live"}

______________________________________________________________________________________

Tech Stack:

Java 17, Spring Boot, Maven, Docker, Jenkins, Docker Hub, Terraform, Ansible, jq

______________________________________________________________________________________

Author

Zwelakhe Msuthu – DevOps Engineer
GitHub: zwelakhem


