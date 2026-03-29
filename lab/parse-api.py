import json

api_response = '{"cluster_name": "prod-01", "active_nodes": 12, "healthy": true}'

def parse_aws_data(info):
   try:
      data = json.loads(info)
      info = data["active_nodes"]
      return info
   
   except json.JSONDecodeError:
        return "Error: Invalid JSON format"
   except KeyError:
        return "Error: 'active_nodes' not found in data"
        
print(parse_aws_data(api_response))
        
    