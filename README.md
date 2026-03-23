# 🚀 Scalable Microservices & Observability Architecture Lab

A production-ready DevOps environment demonstrating CI/CD, Infrastructure as Code (IaC), Kubernetes orchestration, and full-stack observability. 

This project simulates an enterprise-grade web architecture, transitioning from a localized Docker Compose stack to a highly available, auto-scaling Kubernetes cluster monitored by a custom Prometheus/Grafana stack.

## 🏗️ Architecture & Tech Stack

* **Application:** Python (Flask), Redis (Stateful Caching)
* **CI/CD:** GitHub Actions, Docker Hub
* **Infrastructure as Code:** Terraform, AWS (EC2, Security Groups, IAM)
* **Container Orchestration:** Kubernetes (Minikube), Docker
* **Edge Routing:** Nginx Ingress Controller
* **Observability:** Helm, Prometheus, Grafana, PromQL

## ⚙️ Key Features Implemented

* **Automated CI/CD Pipeline:** Configured GitHub Actions to automatically lint, build, and push multi-architecture Docker images to Docker Hub upon merge.
* **Immutable Cloud Infrastructure:** Provisioned AWS EC2 instances, SSH key pairs, and strict Security Group firewalls entirely through Terraform state management.
* **Kubernetes High Availability:** Migrated from single-node Docker Compose to K8s Deployments and Services, ensuring zero-downtime rolling updates and internal DNS routing.
* **Horizontal Pod Autoscaling (HPA):** Implemented dynamic CPU-based autoscaling limits, allowing the cluster to automatically provision and terminate pods during simulated traffic spikes.
* **Enterprise Observability:** Deployed the `kube-prometheus-stack` via Helm, bypassing default dashboards to write custom PromQL queries that visualize pod-level CPU/Memory telemetry and HPA scaling events in real-time.

## 🚀 Deployment Guide

### Phase 1: AWS Cloud Provisioning
cd terraform
terraform init
terraform apply -auto-approve

### Phase 2: Local Kubernetes Cluster & Edge Routing
minikube start --driver=docker
minikube addons enable ingress
minikube addons enable metrics-server
kubectl apply -f k8s/
minikube tunnel # Binds the Ingress to localhost

### Phase 3: Observability Stack via Helm
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm install observability prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl port-forward svc/observability-grafana 8080:80 -n monitoring

### Load Testing the Architecture
*To trigger the Horizontal Pod Autoscaler and view real-time scaling telemetry in Grafana:*
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c