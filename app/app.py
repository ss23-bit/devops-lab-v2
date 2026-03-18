from flask import Flask, jsonify
import redis
import os
import socket

app = Flask(__name__)

redis_host = os.environ.get("REDIS_HOST", "localhost")
redis_port = int(os.environ.get("REDIS_PORT", "6379"))
r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)

@app.route('/')
def home():
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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)


           