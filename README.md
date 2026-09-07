test gitops flow
test gitops
confirm auto-trigger
test again
# End-to-end pipeline test Mon Sep  7 20:13:16 UTC 2026

## Setup Instructions

### Prerequisites
- AWS account with an IAM role attached to the EC2 instance (least-privilege, see `terraform/` for required policies)
- An EC2 instance (Ubuntu 24.04+, minimum 20GB disk)

### 1. Install core tools
```bash
sudo apt update
sudo apt install -y fontconfig openjdk-21-jdk-headless maven awscli docker.io gnupg software-properties-common
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

### 2. Install Jenkins
```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install -y jenkins
sudo usermod -aG docker jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

### 3. Install Terraform
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
```

### 4. Install security scan tools
```bash
sudo apt install -y gitleaks
sudo apt install -y pipx
pipx install semgrep

# Trivy
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt update
sudo apt install -y trivy
```

### 5. Install kubectl and Helm
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 6. Provision AWS infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### 7. Connect kubectl to the new cluster
```bash
aws eks update-kubeconfig --region ap-south-1 --name devsecops-demo-cluster
kubectl create namespace dev qa staging prod
```

### 8. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 9. Configure Jenkins
- Retrieve initial admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- Create a Multibranch Pipeline job pointing to this repository (GitHub branch source)
- Add a GitHub credential (Personal Access Token) with ID `github-token`
- Add a GitHub webhook: `http://<jenkins-ip>:8080/github-webhook/`

### 10. Create ArgoCD Applications
For each environment (`dev`, `qa`, `staging`, `prod`), create an ArgoCD Application pointing to `helm/devsecops-demo`, using the corresponding `values-{env}.yaml`, with auto-sync enabled.
