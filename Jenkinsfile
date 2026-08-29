pipeline {
    agent any

    stages {
        stage('Debug Java') {
            steps {
                sh 'which java'
                sh 'java -version'
                sh 'echo $JAVA_HOME'
            }
        }

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Secrets Scan - Gitleaks') {
            steps {
                sh 'gitleaks detect --source . -v --exit-code 1'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t devsecops-demo:$BUILD_NUMBER .'
            }
        }
    }
}
