pipeline {
    agent any

    environment {
        ECR_REPO = "138300868541.dkr.ecr.ap-south-1.amazonaws.com/devsecops-demo"
        AWS_REGION = "ap-south-1"
    }

    stages {
        stage('Checkout') {
            steps {
                retry(3) {
                    checkout scm
                }
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    def commitHash = sh(script: "git rev-parse --short=7 HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = "${env.BRANCH_NAME}-${commitHash}"
                    echo "Using image tag: ${env.IMAGE_TAG}"
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

        stage('Update GitOps Manifest') {
            steps {
                script {
                    def valuesFile = ""
                    if (env.BRANCH_NAME == 'dev') {
                        valuesFile = "values-dev.yaml"
                    } else if (env.BRANCH_NAME == 'qa') {
                        valuesFile = "values-qa.yaml"
                    } else if (env.BRANCH_NAME == 'staging') {
                        valuesFile = "values-staging.yaml"
                    } else if (env.BRANCH_NAME == 'main') {
                        valuesFile = "values-prod.yaml"
                    } else {
                        error("No values file configured for branch: ${env.BRANCH_NAME}")
                    }

                    withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
                        sh """
                            git config user.email "jenkins@ci.local"
                            git config user.name "Jenkins CI"
                            sed -i "s|tag:.*|tag: \\"${IMAGE_TAG}\\"|" helm/devsecops-demo/${valuesFile}
                            git add helm/devsecops-demo/${valuesFile}
                            git commit -m "Update ${valuesFile} image tag to ${IMAGE_TAG} [skip ci]" || echo "No changes to commit"
                            git push https://\${GIT_USER}:\${GIT_TOKEN}@github.com/Vishnu063/devsecops-demo.git HEAD:${env.BRANCH_NAME}
                        """
                    }
                }
            }
        }
    }
}
