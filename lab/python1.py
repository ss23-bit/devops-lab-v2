available_regions = ["us-east-1", "eu-central-1", "ap-southeast-1"]
app_status = {
    "name": "flask-app",
    "replicas": 2,
    "is_healthy": True
}

available_regions.append("us-west-2")
app_status["replicas"] = 10 

print(f"App {app_status["name"]} has {app_status["replicas"]} replicas. It is available in {available_regions[2]}.")
