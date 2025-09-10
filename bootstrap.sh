#!/bin/bash
set -e

# === CONFIG ===
DOCKERHUB_USER="zwelakhem"
GITHUB_REPO="JavaSpringBoot_App"
PROJECT_DIR=~/Documents/$GITHUB_REPO

echo "📦 Creating project folder..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "📄 Generating .gitignore..."
cat > .gitignore << 'EOF'
/target
*.iml
*.log
*.jar
.env
EOF

echo "📄 Generating pom.xml..."
cat > pom.xml << 'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>JavaSpringBoot_App</artifactId>
  <version>0.1.0</version>
  <packaging>jar</packaging>
  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.2.0</version>
  </parent>
  <properties><java.version>17</java.version></properties>
  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
  </build>
</project>
EOF

echo "📄 Generating Java source files..."
mkdir -p src/main/java/com/example/livescore/controller
mkdir -p src/test/java/com/example/livescore

cat > src/main/java/com/example/livescore/Application.java << 'EOF'
package com.example.livescore;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
@SpringBootApplication
public class Application {
  public static void main(String[] args) { SpringApplication.run(Application.class, args); }
}
EOF

cat > src/main/java/com/example/livescore/controller/ScoreController.java << 'EOF'
package com.example.livescore.controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
@RestController
public class ScoreController {
  @GetMapping("/score")
  public Map<String,Object> score() {
    return Map.of("game","Sky Heroes", "score","3-2", "status","live");
  }
}
EOF

cat > src/test/java/com/example/livescore/ScoreControllerTest.java << 'EOF'
package com.example.livescore;
import com.example.livescore.controller.ScoreController;
import org.junit.jupiter.api.Test;
import static org.assertj.core.api.Assertions.assertThat;
public class ScoreControllerTest {
  @Test void testScoreResponse() {
    ScoreController c = new ScoreController();
    var map = c.score();
    assertThat(map).containsKeys("game","score","status");
  }
}
EOF

echo "📄 Generating Dockerfile..."
cat > Dockerfile << 'EOF'
# Build stage with Maven
FROM maven:3.9.3-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -q -DskipTests package

# Runtime stage
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
EOF

echo "📄 Generating Jenkinsfile..."
cat > Jenkinsfile << EOF
pipeline {
  agent any
  environment {
    IMAGE_NAME = "$DOCKERHUB_USER/javaspringboot_app"
    DOCKER_TAG = "\${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build & Test') { steps { sh 'mvn -B clean package' } }
    stage('Build Docker Image') { steps { sh "docker build -t \${IMAGE_NAME}:\${DOCKER_TAG} ." } }
    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DH_USER',
                                          passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "\$DH_PASS" | docker login -u "\$DH_USER" --password-stdin
            docker push \${IMAGE_NAME}:\${DOCKER_TAG}
            docker tag \${IMAGE_NAME}:\${DOCKER_TAG} \${IMAGE_NAME}:latest
            docker push \${IMAGE_NAME}:latest
          '''
        }
      }
    }
    stage('Deploy (Ansible)') {
      steps {
        sh '''
          ansible-galaxy collection install community.docker
          ansible-playbook -i ansible/inventory.ini ansible/deploy.yml \
            --extra-vars "docker_image=\${IMAGE_NAME} docker_tag=\${DOCKER_TAG}"
        '''
      }
    }
  }
}
EOF

echo "📄 Generating Terraform files..."
mkdir -p terraform
cat > terraform/main.tf << EOF
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
  name = "$DOCKERHUB_USER/javaspringboot_app:latest"
}
resource "docker_container" "live_score" {
  name  = "javaspringboot_app"
  image = docker_image.live_score.latest
  ports { internal = 8080, external = 8080 }
}
EOF

echo "📄 Generating Ansible files..."
mkdir -p ansible
cat > ansible/inventory.ini << 'EOF'
[apphosts]
localhost ansible_connection=local
EOF

cat > ansible/deploy.yml << EOF
- hosts: apphosts
  become: false
  vars:
    docker_image: "$DOCKERHUB_USER/javaspringboot_app"
    docker_tag: "latest"
  tasks:
    - name: Pull image
      community.docker.docker_image:
        name: "{{ docker_image }}"
        tag: "{{ docker_tag }}"
        source: pull
    - name: Remove existing container (if any)
      community.docker.docker_container:
        name: javaspringboot_app
        state: absent
        force_kill: yes
    - name: Start container
      community.docker.docker_container:
        name: javaspringboot_app
        image: "{{ docker_image }}:{{ docker_tag }}"
        state: started
        restart_policy: always
        published_ports:
          - "8080:8080"
EOF

echo "✅ Files generated successfully."

echo "🔧 Initializing Git..."
git init -b development
git add .
git commit -m "Initial commit - Java Spring Boot App CI/CD setup"

echo "📡 Creating GitHub repo and pushing code..."
gh auth login
gh repo create $GITHUB_REPO --public --source=. --remote=origin --push

echo "🎉 Bootstrap complete! Next steps:"
echo "1. Open Jenkins at http://localhost:8080"
echo "2. Create Pipeline job named $GITHUB_REPO pointing to GitHub repo"
echo "3. Add DockerHub credentials in Jenkins with ID 'dockerhub-creds'"
echo "4. Trigger Build Now 🚀"

