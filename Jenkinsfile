pipeline {
    agent any

    options {
        retry(2)
    }

    environment {
        ECR_REPO = "138300868541.dkr.ecr.ap-south-1.amazonaws.com/devsecops-demo"
        AWS_REGION = "ap-south-1"
        CLUSTER_NAME = "devsecops-demo-cluster"
        IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                retry(3) {
                    checkout scm
                }
            }
        }

        stage('Secrets Scan - Gitleaks') {
            steps {
                sh 'gitleaks detect --source . -v --exit-code 1'
            }
        }

        stage('SAST Scan - Semgrep') {
            steps {
                sh 'semgrep --config auto src/ --error --json --output semgrep-results.json || true'
                sh 'semgrep --config auto src/'
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
sh 'docker build --no-cache -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        stage('Container Scan - Trivy') {
            steps {
                sh 'trivy image --severity CRITICAL,HIGH --exit-code 1 $ECR_REPO:$IMAGE_TAG || true'
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    docker push $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Update ArgoCD Application') {
            steps {
                script {
                    def appName = ""
                    if (env.BRANCH_NAME == 'dev') {
                        appName = "devsecops-demo-dev"
                    } else if (env.BRANCH_NAME == 'qa') {
                        appName = "devsecops-demo-qa"
                    } else if (env.BRANCH_NAME == 'staging') {
                        appName = "devsecops-demo-staging"
                    } else if (env.BRANCH_NAME == 'main') {
                        appName = "devsecops-demo-prod"
                    } else {
                        error("No ArgoCD application configured for branch: ${env.BRANCH_NAME}")
                    }

                    sh """
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                        kubectl patch application ${appName} -n argocd --type merge -p '{"spec":{"source":{"helm":{"parameters":[{"name":"image.tag","value":"${IMAGE_TAG}"}]}}}}'
                    """
                }
            }
        }
    }
}
