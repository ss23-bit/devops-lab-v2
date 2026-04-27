import json

# This string is what you get from a 'curl' or a Web Request
json_data = '[{"id": 1, "name": "Piyapoom"}, {"id": 2, "name": "Agoda"}]'

# Convert string into a Python List of Dictionaries
users = json.loads(json_data)

# Now you can use it like a normal list
print(users[1]["id"])
