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
