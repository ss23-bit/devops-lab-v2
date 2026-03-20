from flask import Flask, jsonify, request, Response
import redis
import os
import socket

# We import the tools needed to create metrics
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

redis_host = os.environ.get('REDIS_HOST', 'localhost')
redis_port = int(os.environ.get('REDIS_PORT', 6379))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

# 1. DEFINE THE METRIC: 
# A "Counter" is a metric that only goes up (perfect for counting total visitors).
# We also track labels like 'method' (GET/POST) and 'endpoint' to filter data later.
REQUEST_COUNT = Counter(
    'flask_app_requests_total',
    'Total number of requests received by the Flask app',
    ['method', 'endpoint']
)

@app.route('/')
def home():
    # 2. RECORD THE METRIC:
    # Every time someone visits '/', we increase the counter by 1.
    REQUEST_COUNT.labels(method=request.method, endpoint='/').inc()

    try:
        hits = r.incr('hit_counter')
    except redis.RedisError:
        hits = "Redis not connected"

    return jsonify({
        "message": "Welcome to DevOps Lab v2! Nginx is routing this traffic.",
        "hits": hits,
        "pod_name": socket.gethostname(),
        "version": "2.0.0"
    })

# 3. EXPOSE THE DATA:
# This creates the secret http://app:5000/metrics page.
# Prometheus will visit this page every 15 seconds to download the data.
@app.route('/metrics')
def metrics():
    # Response = Explicit send raw text # generate_latest = Translator. # mimetype = "Label on the Box" # CONTENT_TYPE_LATEST = "This is Prometheus Text Version 0.0.4."
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
           