from flask import Flask, jsonify
import os
import psutil

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"Hello": "goodbye"}), 200

@app.route('/health')
def health_check():
    cpu_usage = psutil.cpu_percent()
    mem_usage = psutil.virtual_memory().percent

    status = "Healthy"
    status_code = 200

    if cpu_usage > 95:
        status = "Unhealthy"
        status_code = 503
    
    return jsonify ({
        "status": status,
        "cpu usage": cpu_usage,
        "memory usage": mem_usage
    }), status_code

if __name__ == ("__main__"):
    app.run(host='0.0.0.0', port=5000)
        

