**ECR (Elastic Container Registry)**
1. *Create the Repository*
aws ecr create-repository \
    --repository-name ss23-task-tracker \
    --image-scanning-configuration scanOnPush=true \  # check your code for security holes (vulnerabilities)
    --region ap-southeast-1

2. *Authenticate Docker to AWS*
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.ap-southeast.1.amazonaws.com

3. *Tag Your Image*
docker tag task-tracker:v1 123456789012.dkr.ecr.ap-southeast.amazonaws.com/ss23-task-tracker:v1

4. *The Big Push*
docker push 123456789012.dkr.ecr.ap-southeast-1.amazonaws.com/ss23-task-tracker:v1

**MiniKube**
*"Temporary Key" from AWS*
TOKEN=$(aws ecr get-login-password --region ap-southeast-1)

*Create the Kubernetes Secret*
kubectl create secret docker-registry ecr-registry-key \
  --docker-server=599476212560.dkr.ecr.ap-southeast-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$TOKEN \
  --namespace=default

`ecr-registry-key`: This is the name we gave to the "Key."
`docker-username=AWS`: For ECR, the username is always AWS
`docker-password=$TOKEN`: This uses the 12-hour password

If fail: kubectl delete secret ecr-registry-key 