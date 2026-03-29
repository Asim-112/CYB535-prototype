pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'asim112/java-cicd-app'
        SONARQUBE_URL = 'http://sonarqube:9000'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Asim-112/CYB535-prototype.git'
            }
        }

        stage('Copy Code to Containers') {
            steps {
                sh 'docker cp . java17-builder:/app'
                sh 'docker cp . java11-tester:/app'
                sh 'docker cp . java8-analyzer:/app'
            }
        }

        stage('Build with Java 17') {
            steps {
                sh '''
                    docker exec java17-builder bash -c "
                        cd /app &&
                        javac -version &&
                        mvn clean compile
                    "
                '''
            }
        }

        stage('Test with Java 11') {
            steps {
                sh '''
                    docker exec java11-tester bash -c "
                        cd /app &&
                        java -version &&
                        mvn test -Dmaven.compiler.source=11 -Dmaven.compiler.target=11
                    "
                '''
            }
        }

        stage('SonarQube Analysis with Java 8') {
            steps {
                sh '''
                    docker exec java8-analyzer bash -c "
                        cd /app &&
                        mvn sonar:sonar \
                            -Dmaven.compiler.source=8 -Dmaven.compiler.target=8 \
                            -Dsonar.host.url=http://sonarqube:9000 \
                            -Dsonar.login=admin \
                            -Dsonar.password=admin
                    "
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f deployment.yaml'
                sh 'kubectl rollout status deployment/java-app'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs above for details.'
        }
        always {
            sh 'docker logout || true'
        }
    }
}
