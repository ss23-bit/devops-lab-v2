from http.server import BaseHTTPRequestHandler, HTTPServer
class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Hello from Python!")

    def do_POST(self):
        self.send_response(201)
        self.send_header('content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b"Data recieved by Python!")

print("Server starting from port 8080...")
HTTPServer(('0.0.0.0', 8080), Handler).serve_forever()
