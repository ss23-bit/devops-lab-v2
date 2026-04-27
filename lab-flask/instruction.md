**Bash**
pip install flask gunicorn

**Python**
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Flask is running behind Nginx!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)

`Before touching Nginx, make sure Gunicorn can talk to your app:`
**Bash**
gunicorn --bind 0.0.0.0:5000 app:app

`Now, tell Nginx to "point" at that Gunicorn process.`
sudo nano /etc/nginx/sites-available/flask_app
**Nginx**
server {
    listen 80;
    server_name your_public_ip_or_localhost;

    location / {
        include proxy_params;
        proxy_pass http://127.0.0.1:5000;
    }
}

**Bash**
sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/ 
sudo nginx -t `check the typo`
sudo systemctl restart nginx

*Details*
sudo ln -s /etc/nginx/sites-available/flask_app /etc/nginx/sites-enabled/

This creates a "pointer" in the `sites-enabled` folder that points back to the real file in `sites-available`. It’s like putting a shortcut on your Windows desktop that points to a file in your Documents folder.

/etc/nginx/sites-available/:  `Storage` configuration files
/etc/nginx/sites-enabled/:  `Active` folder

docker build -t my-flask-app:v1 .
docker run -d -p 8080:5000 --name my-app my-flask-app:v1                                   	Running your Flask app in the background.
docker run -it --rm python:3.11-slim /bin/bash                                              Practicing Linux commands in a safe, temporary sandbox.
docker stop <name>	                                                                        Gracefully shutting down the app.
docker rm -f <name>                             	                                        Force-deleting a container you don't need anymore.
docker exec -it ... bash                         	                                        You are "inside" the live app environment.
docker run -it --rm ... bash                       	                                        A temporary sandbox that disappears after use.
docker exec <id> ls -l /app                     	                                        Runs one command and returns to your host terminal.

from flask import Flask, jsonify
import os
import psutil

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"Hello": "World!", "Goodbye": "World!"})

@app.route('/health')
def healt_check():
    cpu_usage = psutil.cpu_percent()
    mem_usage = psutil.virtual_memory().percent

    health_status = "Healthy"
    status_code = 200

    # if a health check returns 503, Kubernetes or an AWS Load Balancer will kill the container and restart it
    if cpu_usage > 95:
        health_status = "Unhealthy"
        status_code = 503
    
    return jsonify ({
        "status": health_status,
        "cpu usage": cpu_usage,
        "memory usage": mem_usage
    }), status_code

if __name__ == ("__main__"):
    app.run(host='0.0.0.0', port=5000)