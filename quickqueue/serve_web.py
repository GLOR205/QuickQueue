"""Serve build/web with cache disabled so browsers always fetch fresh JS after a rebuild."""
import functools
import http.server
import os
import socketserver
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 5061
WEB_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "build", "web")


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


Handler = functools.partial(NoCacheHandler, directory=WEB_DIR)

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving build/web on port {PORT} with caching disabled")
    httpd.serve_forever()
