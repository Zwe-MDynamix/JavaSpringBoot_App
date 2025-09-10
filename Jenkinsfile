pipeline {
  agent any
  environment {
    IMAGE_NAME = "zwelakhem/javaspringboot_app"
    DOCKER_TAG = "${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build & Test') {
      steps { sh 'mvn -B clean package' }
      post { always { junit '**/target/surefire-reports/*.xml' } }
    }
    stage('Build Docker Image') {
      steps { sh "docker build -t ${IMAGE_NAME}:${DOCKER_TAG} ." }
    }
    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                          usernameVariable: 'DH_USER',
                                          passwordVariable: 'DH_PASS')]) {
          sh '''
            echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
            docker push ${IMAGE_NAME}:${DOCKER_TAG}
            docker tag ${IMAGE_NAME}:${DOCKER_TAG} ${IMAGE_NAME}:latest
            docker push ${IMAGE_NAME}:latest
          '''
        }
      }
    }
    stage('Deploy (Ansible)') {
      steps {
        sh '''
          ansible-galaxy collection install community.docker
          ansible-playbook -i ansible/inventory.ini ansible/deploy.yml             --extra-vars "docker_image=${IMAGE_NAME} docker_tag=${DOCKER_TAG}"
        '''
      }
    }
  }
}
