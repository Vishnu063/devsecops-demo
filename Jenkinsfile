pipeline {
    agent any

    environment {
        ECR_REPO = "138300868541.dkr.ecr.ap-south-1.amazonaws.com/devsecops-demo"
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "devsecops-demo-cluster"
    }

    stages {
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

        stage('Run Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$BUILD_NUMBER .'
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    docker push $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('Update GitOps Manifest') {
            steps {
                script {
                    def namespace = ""
                    if (env.BRANCH_NAME == 'dev') {
                        namespace = "dev"
                    } else if (env.BRANCH_NAME == 'qa') {
                        namespace = "qa"
                    } else if (env.BRANCH_NAME == 'staging') {
                        namespace = "staging"
                    } else if (env.BRANCH_NAME == 'main') {
                        namespace = "prod"
                    } else {
                        error("No deployment configured for branch: ${env.BRANCH_NAME}")
                    }

                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config user.email "jenkins@ci.local"
                            git config user.name "Jenkins CI"
                            sed -i "s|image: .*|image: ${ECR_REPO}:${BUILD_NUMBER}|" k8s/deployment.yaml
                            git add k8s/deployment.yaml
                            git commit -m "Update image to build ${BUILD_NUMBER} [skip ci]" || echo "No changes to commit"
                            git push https://\${GIT_USER}:\${GIT_TOKEN}@github.com/Vishnu063/devsecops-demo.git HEAD:${env.BRANCH_NAME}
                        """
                    }
                }
            }
        }
    }
}
