import yaml

def audit_container_image(data):
    try:
        # 1. Dig through the "rooms" of the YAML house
        # Most K8s manifests follow this path:
        container_list = data["spec"]["template"]["spec"]["containers"]
        
        for container in container_list:
            image_name = container["image"] # e.g. "nginx:latest"
            
            # 2. Check if the "poison" string is inside the image name
            if ":latest" in image_name:
                return f"FAIL: Unstable image [{image_name}] found!"
            elif ":v" in image_name:
                return f"PASS: Stable image [{image_name}] detected."
        
        return "AUDIT COMPLETE: No obvious issues."
        
    except KeyError as e:
        return f"ERROR: YAML structure is missing a key: {e}"

# Load the real file
with open("app.yaml", "r") as f:
    config_data = yaml.safe_load(f)

# Run the audit
result = audit_container_image(config_data)
print(result)