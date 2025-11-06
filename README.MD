✅ JOBSTER — Complete CI/CD Setup Guide for Jenkins + Docker

This document explains every step required before running the Jenkins CI/CD pipeline for the Jobster project.
Follow this guide from top to bottom to fully prepare your environment, server, Docker, and Jenkins for automated deployment.

✅ 1. Server Requirements

Before running the pipeline, ensure you have:

✅ Linux Server (Ubuntu recommended)

Minimum specs:

2 CPU cores

4 GB RAM

20 GB Disk

✅ SSH Access

Example:

ssh user@your-server-ip

✅ 2. Install Required Software on the Server

You must install:

✅ 2.1 Install Docker
sudo apt update
sudo apt install -y ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io


Enable Docker:

sudo systemctl enable docker
sudo systemctl start docker

✅ 2.2 Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/2.24.0/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


Verify:

docker-compose --version

✅ 2.3 Allow Jenkins to Use Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

✅ 3. Install Jenkins
✅ Install Java (required by Jenkins)
sudo apt update
sudo apt install -y openjdk-17-jdk

✅ Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins


Access Jenkins:

http://your-server-ip:8080

✅ 4. Initial Jenkins Setup
Install these plugins:

✅ Git Plugin
✅ Docker Pipeline
✅ Docker API Plugin
✅ Credentials Binding Plugin
✅ Pipeline Plugin
✅ Blue Ocean (optional)
✅ NodeJS Plugin (optional)

✅ 5. Create Jenkins Credentials

Go to:

Jenkins → Manage Jenkins → Credentials → Global → Add Credentials

Create the following:

ID	Type	Purpose
dockerhub-token	Secret Text	Docker Hub access token
jwt-secret	Secret Text	JWT secret for backend
github-credentials (optional)	Username + PAT	For private repos
✅ 6. Docker Hub Setup

You MUST have:

✅ A Docker Hub account
✅ Two repositories:

jobster-frontend

jobster-backend

Create an access token:

Docker Hub → Security → New Access Token

Save this in Jenkins as:

dockerhub-token

✅ 7. GitHub Setup
✅ 7.1 Remove secrets from Git history

You must ensure no secrets appear in any commit.

You already removed the hardcoded token using:

git filter-repo

✅ 7.2 Push cleaned history with force
git push origin main --force

✅ 7.3 Add new (clean) Jenkinsfile

Now you may add a safe Jenkinsfile.

✅ 8. Required Files in Your Repository

Your repo must contain:

/client/Dockerfile      → frontend
/Dockerfile             → backend
Jenkinsfile             → CI/CD pipeline
docker-compose.yml      (optional for local dev)

✅ 9. Jenkinsfile (Final Clean Version)
pipeline {
    agent any

    environment {
        DOCKER_USER = 'rakshith3'
        DOCKER_PASS = credentials('dockerhub-token')
        GIT_URL = 'https://github.com/rak2712/jobster-dockerized.git'
        GIT_BRANCH = 'main'
        MONGO_URI = 'mongodb://mongo-service:27017/jobster'
        JWT_SECRET = credentials('jwt-secret')
        JWT_LIFETIME = '30d'
    }

    stages {

        stage('Checkout Code') {
            steps {
                sh 'rm -rf jobster-dockerized'
                sh 'git clone $GIT_URL'
            }
        }

        stage('Build Docker Images') {
            steps {
                dir('jobster-dockerized/client') {
                    sh 'docker build -t $DOCKER_USER/jobster-frontend:latest .'
                }
                dir('jobster-dockerized') {
                    sh 'docker build -t $DOCKER_USER/jobster-backend:latest .'
                }
            }
        }

        stage('Push Images') {
            steps {
                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                sh 'docker push $DOCKER_USER/jobster-frontend:latest'
                sh 'docker push $DOCKER_USER/jobster-backend:latest'
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh 'docker network create jobster-net || true'

                    sh 'docker rm -f jobster-backend || true'
                    sh 'docker rm -f jobster-frontend || true'

                    sh '''
                        docker run -d \
                        --network jobster-net \
                        --name mongo-service \
                        -p 27017:27017 \
                        --restart always \
                        mongo:latest || true
                    '''

                    sh '''
                        docker run -d \
                        --network jobster-net \
                        --name jobster-backend \
                        -p 5000:5000 \
                        --restart always \
                        -e MONGO_URI=$MONGO_URI \
                        -e JWT_SECRET=$JWT_SECRET \
                        -e JWT_LIFETIME=$JWT_LIFETIME \
                        $DOCKER_USER/jobster-backend:latest
                    '''

                    sh '''
                        docker run -d \
                        --network jobster-net \
                        --name jobster-frontend \
                        -p 81:80 \
                        --restart always \
                        $DOCKER_USER/jobster-frontend:latest
                    '''
                }
            }
        }
    }
}

✅ 10. Running the Pipeline

Open Jenkins → New Item → Pipeline → Configure:

✅ Select Pipeline from SCM
✅ Enter GitHub repository URL
✅ Branch: main

Click Build Now.

Jenkins will:

✅ Clone code
✅ Build frontend + backend
✅ Push to Docker Hub
✅ Deploy MongoDB
✅ Deploy backend container
✅ Deploy frontend container
✅ Application becomes live

✅ 11. Application URLs

✅ Frontend → http://your-server-ip:81
✅ Backend → http://your-server-ip:5000
✅ MongoDB exposed at → 27017
