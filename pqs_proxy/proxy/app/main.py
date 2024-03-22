from http.server import BaseHTTPRequestHandler, HTTPServer

import requests


class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        url = self.path[1:]
        print(url)
        self.send_response(200)
        self.end_headers()
        try:
            r = requests.get(url)
            self.wfile.write(r.content)
        except Exception as e:
            self.send_error(400, str(e))


def run_server(port=8081):
    print(f"Starting server on port {port}...")
    server_address = ('', port)
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
    print("Server is running. Press Ctrl+C to stop.")
    httpd.serve_forever()


if __name__ == '__main__':
    run_server()
