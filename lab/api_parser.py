import json

raw_response = '{"cluster": "prod-asia", "active_nodes": 5, "healthy": true}'

def parse_cloud_data(json_text):
    
    return json.loads(json_text)

response = parse_cloud_data(raw_response)
print(f"The cluster has {response["active_nodes"]} active nodes.")
    
