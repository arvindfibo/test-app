FROM python:3.11-slim

WORKDIR /app

# Create a simple web server
RUN echo 'from http.server import HTTPServer, BaseHTTPRequestHandler\n\
import json\n\
import os\n\
\n\
class Handler(BaseHTTPRequestHandler):\n\
    def do_GET(self):\n\
        if self.path == "/health":\n\
            self.send_response(200)\n\
            self.send_header("Content-type", "application/json")\n\
            self.end_headers()\n\
            self.wfile.write(json.dumps({"status": "healthy"}).encode())\n\
        else:\n\
            self.send_response(200)\n\
            self.send_header("Content-type", "text/html")\n\
            self.end_headers()\n\
            version = os.getenv("APP_VERSION", "1.0.0")\n\
            html = f"""<html><head><title>Test App</title></head><body>\n\
                <h1>Test App</h1>\n\
                <p>Version: {version}</p>\n\
                <p>This is a test application for CI/CD pipeline.</p>\n\
                <p><a href="/health">Health Check</a></p>\n\
                </body></html>"""\n\
            self.wfile.write(html.encode())\n\
    def log_message(self, format, *args):\n\
        pass\n\
\n\
if __name__ == "__main__":\n\
    port = int(os.getenv("PORT", "8080"))\n\
    server = HTTPServer(("0.0.0.0", port), Handler)\n\
    print(f"Server running on port {port}")\n\
    server.serve_forever()' > server.py

EXPOSE 8080

CMD ["python", "server.py"]

