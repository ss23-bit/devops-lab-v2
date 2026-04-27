**GitHub:**
git clone <url>
git config --global user.name "Your Name" `Sets your identity.`
git log --oneline
git remote add origin <url> `Links your local folder to a GitHub repository.`
git checkout -b <name> `Creates a new branch and switches to it immediately.`
git branch -d <name> `delete git branch`
git push origin --delete <name> `delete github branch`
git reset <file> `Unstages a file (removes it from the Loading Dock).`
*git start up*:
git init
# 1. Rename your main branch to 'main' (standard practice)
git branch -M main
# 2. Link your local folder to the new GitHub repo (Replace YOUR_USERNAME with ss23-bit)
git remote add origin https://github.com/--user--/--repo--
# 3. Push your code to the cloud
git push -u origin main
*git stash*
git stash -u `Hides changes + new files.`
git stash pop
git stash list
git stash clear
git stash save "massage"
git stash apply `Unlike pop, it keeps the copy in the list`

**dependencies**
pip install -r **
pip show ** | grep Version

**Local Testing:**
pip install safety
safety check -r requirements.txt

**AWS:**
aws sts get-caller-identity
aws configure

**Docker**
docker stop $(docker ps -aq) && docker rm $(docker ps -aq) `Clear All containers`
docker system prune -a --volumes `absolute zero`
docker image, volumes, network prune
docker build -t my-app ./app
docker run -d --name my-app my-app-image
docker logs -f <container_id> `or docker-compose`
docker exec -it <container_id> <shell/commands> `-w	Workdir`, `-u User`
**Docker-compose:**
docker compose -f ~/.aws/-key- up -d
docker-compose up --build -d

**Networking:**
curl ifconfig.me

**Terraform:**
terraform fmt
terraform init -upgrade `When change or upgrade provider version`
**SSH:**
eval $(ssh-agent -s) `Create SSH key Agent`
ssh-add ~/.ssh/<ssh key> `Give a key to the Agent`
ssh-add -l `Checking`


**K8s:**
minikub start --driver=docker
kubectl apply -f **.ymal
kubectl describe pod **
kubectl delete pod ** or deployment ** `--all --purge` 
minikube service flask-service --url `built-in Minikube command to map the URL.`
kubectl port-forward service/flask-service (any available port):(service port) `Kubernetes way to map the url`

**Inspect K8s:**
kubectl get pod (--watch`in realtime`)
kubectl get svc
kubectl top nodes
kubectl top pods
kubectl get hpa 
minikube addons enable metrics-server

**Helm:**
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install observability prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl get secret observability-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode ; echo `to get Grafana's password`

**Prometheus:**
Set up Phase:
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

**Grafana**
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

**Query:**
container_cpu_usage_seconds_total
sum(rate(container_cpu_usage_seconds_total{namespace="default", pod=~"flask-deployment.*"}[2m])) by (pod)
 - `{namespace="default", pod=~"flask-deployment.*"}`: This is the filter. The `=~` means "Regex match", so it grabs any pod that starts with the name flask-deployment.
 - `[2m]`: This looks at the data points over a 2-minute rolling window.
 - `rate(...)`: CPU usage in Linux is a continuously growing counter. `rate()` does the calculus to convert that raw counter into a "usage per second" line graph.
 - `sum(...) by (pod)`: If a pod has multiple containers inside it, this adds them together to give you one clean line per pod.
