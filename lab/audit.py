files = ["web:v1", "db:latest", "cache:v2", "proxy:latest"]
blacklist = []

for file in files:
    if ":latest" in file:
        blacklist.append(file)

print(f"Found {blacklist}")
        
        