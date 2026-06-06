# Wisecow Application

A fun web application that serves random "cow wisdom" quotes using ASCII art cows.

## What It Does

- Runs a simple HTTP server on port 4499
- Uses `fortune-mod` and `cowsay` to generate random quotes
- Serves them as HTML with ASCII art

## Project Structure
wisecow/
├── Dockerfile              # Container image definition
├── k8s/
│   ├── namespace.yaml      # Kubernetes namespace
│   ├── deployment.yaml     # App deployment (2 replicas)
│   ├── service.yaml        # Service exposure (NodePort)
│   └── ingress.yaml        # TLS-enabled ingress
└── wisecow.sh              # Application source code


## Dockerization

The Dockerfile:
- Uses Ubuntu 22.04 as base
- Installs `fortune-mod`, `cowsay`, `netcat-openbsd`
- Converts line endings and makes the script executable
- Exposes port 4499
- Runs the application

Build locally:
```bash
docker build -t wisecow:latest .
docker run -p 4499:4499 wisecow:latest

Kubernetes Deployment
Deploy to any Kubernetes cluster:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

Access via port-forward:
bash
kubectl port-forward svc/wisecow-service -n wisecow 8080:80
# Open http://localhost:8080

CI/CD Pipeline
GitHub Actions workflow (.github/workflows/ci-cd.yaml):
Triggers: On every push to master
Build: Creates Docker image from ./wisecow context
Push: Uploads image to GitHub Container Registry (GHCR)
Image: ghcr.io/gaurav152002/assignment/wisecow:latest
TLS Implementation
Self-signed TLS certificate generated with OpenSSL
Stored as Kubernetes secret wisecow-tls
NGINX Ingress Controller handles HTTPS termination
Access via https://wisecow.local (add to hosts file)
Continuous Deployment — Challenge Goal
Status: Pipeline configured but requires cloud infrastructure.
The Challenge:
GitHub Actions runs on cloud servers (Azure data centers). The current Kubernetes cluster runs locally on the developer's laptop, which is:
Behind a home router/firewall
On a private IP address
Not accessible from the internet
Why CD Fails:
The deploy job tries to run kubectl set image from GitHub's runner, but it cannot connect to localhost:8080 on the developer's machine.
Solutions for Production:
Cloud Kubernetes Cluster: Use EKS, GKE, AKS, or Oracle Cloud Free Tier
Self-Hosted Runner: Install GitHub Actions runner on the K8s node
GitOps: Use ArgoCD or Flux to watch the repo and auto-deploy
Current Implementation:
The CI/CD pipeline is fully configured. The CD step is commented out with documentation explaining the infrastructure requirement. Once a cloud cluster is available, uncommenting the deploy job will enable full continuous deployment.

How to Run This Project
Clone the repo
Build Docker image: docker build -t wisecow:latest ./wisecow
Deploy to Kubernetes: kubectl apply -f wisecow/k8s/
Access the app: kubectl port-forward svc/wisecow-service -n wisecow 8080:80
Open browser: http://localhost:8080