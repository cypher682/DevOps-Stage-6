# DevOps Stage 6 - Infrastructure Documentation

## Overview
This directory contains Infrastructure as Code (IaC) for deploying the TODO microservices application on AWS with automated CI/CD pipelines.

## Architecture
- Cloud Provider: AWS (us-east-1)
- Instance Type: t2.micro (Free Tier)
- OS: Ubuntu 22.04 LTS
- Domain: app.cipherpol.xyz
- SSL: Let's Encrypt via Traefik
- State Backend: Terraform Cloud

## Directory Structure
```
infra/
├── terraform/
│   ├── backend.tf          # Terraform Cloud configuration
│   ├── main.tf             # EC2, Security Groups, Key Pair
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Outputs and inventory generation
│   └── inventory.tpl       # Ansible inventory template
└── ansible/
    ├── ansible.cfg         # Ansible configuration
    ├── playbook.yml        # Main playbook
    └── roles/
        ├── dependencies/   # Install Docker, Docker Compose, Git
        └── deploy/         # Clone repo and deploy application
```

## Prerequisites

### 1. AWS Setup
- AWS Account with Free Tier access
- AWS Access Key ID and Secret Access Key
- SSH Key Pair created in AWS EC2 (devops-stage6-key)

### 2. Terraform Cloud Setup
- Organization: cypher682-org
- Workspace: stage6
- API Token configured

### 3. GitHub Secrets
Configure the following secrets in your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SSH_PRIVATE_KEY`
- `TF_CLOUD_TOKEN`
- `GMAIL_USER` (cipherorion682@gmail.com)
- `GMAIL_APP_PASSWORD`
- `ALERT_EMAIL` (cipherorion682@gmail.com)

### 4. Domain Configuration
- Domain: todo.cipherpol.xyz (GoDaddy)
- After deployment, create A record (app.cipherpol.xyz) pointing to EC2 public IP
- Alternative: Use FreeDNS (freedns.afraid.org) for free .com subdomain

## SSH Key Setup

### Generate SSH Key Pair
```bash
ssh-keygen -t rsa -b 4096 -C "cipherorion682@gmail.com" -f ~/.ssh/devops-stage6-key -N ""
```

### Import to AWS
1. Go to AWS Console > EC2 > Key Pairs
2. Click "Import Key Pair"
3. Name: devops-stage6-key
4. Paste content from: `cat ~/.ssh/devops-stage6-key.pub`

### Add to GitHub Secrets
```bash
cat ~/.ssh/devops-stage6-key
```
Copy the entire output and add as `SSH_PRIVATE_KEY` secret.

## Local Deployment

### 1. Configure Terraform Cloud Credentials
```bash
cat > ~/.terraformrc << 'EOF'
credentials "app.terraform.io" {
  token = "YOUR_TERRAFORM_CLOUD_TOKEN"
}
EOF
```

### 2. Initialize and Deploy
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -auto-approve
```

This will:
1. Provision EC2 instance
2. Configure security groups
3. Generate Ansible inventory
4. Run Ansible playbook
5. Deploy the application

### 3. Configure DNS
After deployment, get the instance IP:
```bash
terraform output instance_public_ip
```

Create A record in GoDaddy:
- Type: A
- Name: app
- Value: [EC2 Public IP]
- TTL: 600

Alternative - FreeDNS (free .com):
1. Go to https://freedns.afraid.org
2. Create account and subdomain (e.g., todoapp.mooo.com)
3. Point to EC2 Public IP
4. Update docker-compose.yml with new domain

## CI/CD Workflows

### Infrastructure Workflow
Triggers on changes to:
- `infra/terraform/**`
- `infra/ansible/**`

Process:
1. Terraform Plan (drift detection)
2. Email alert if drift detected
3. Wait for manual approval (production environment)
4. Terraform Apply
5. Ansible Deployment

### Application Workflow
Triggers on changes to:
- Service directories (frontend, auth-api, todos-api, users-api, log-message-processor)
- `docker-compose.yml`
- `.env`

Process:
1. SSH to server
2. Pull latest code
3. Rebuild and restart containers
4. Send deployment notification

## Drift Detection

The infrastructure workflow includes automatic drift detection:
- Runs `terraform plan` on every push
- Detects if infrastructure has changed
- Sends email alert with plan details
- Requires manual approval before applying changes
- If no drift, applies automatically

## Application URLs

After deployment:
- Frontend: https://app.cipherpol.xyz
- Auth API: https://app.cipherpol.xyz/api/auth
- Todos API: https://app.cipherpol.xyz/api/todos
- Users API: https://app.cipherpol.xyz/api/users

## Expected API Responses

### Direct API Access (without authentication):
- Auth API: "Not Found"
- Todos API: "Invalid Token"
- Users API: "Missing or invalid Authorisation header"

### Login Credentials
From `.env` file:
- Username: admin, Password: Admin123
- Username: hng, Password: HngTech
- Username: user, Password: Password

## Troubleshooting

### Check container status
```bash
ssh -i ~/.ssh/devops-stage6-key ubuntu@[INSTANCE_IP]
cd /home/ubuntu/app
docker-compose ps
```

### View logs
```bash
docker-compose logs -f [service-name]
docker logs traefik
```

### Restart services
```bash
docker-compose restart
```

### Rebuild from scratch
```bash
docker-compose down --rmi all
docker-compose up -d --build
```

## Idempotency

Both Terraform and Ansible are configured for idempotent operations:
- Re-running Terraform will not recreate resources unless changes exist
- Re-running Ansible will not restart services unless code has changed
- Docker Compose only rebuilds changed services

## Security

- Security Group allows: SSH (22), HTTP (80), HTTPS (443)
- All HTTP traffic redirected to HTTPS
- SSL certificates auto-renewed by Traefik
- SSH key-based authentication only
- Docker containers run in isolated network

## Monitoring

Check deployment status:
- GitHub Actions: https://github.com/cypher682/DevOps-Stage-6/actions
- Email notifications for drift and deployments
- Traefik dashboard (if enabled)

## Cleanup

To destroy all resources:
```bash
cd infra/terraform
terraform destroy -auto-approve
```

## Support

For issues or questions:
- Email: cipherorion682@gmail.com
- Repository: https://github.com/cypher682/DevOps-Stage-6
