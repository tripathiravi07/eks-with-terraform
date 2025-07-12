from flask import Flask, request
import logging
import json
import time
import os
import signal
import sys

app = Flask(__name__)

# Configure logging to STDOUT in structured format
logging.basicConfig(level=logging.INFO, format='%(message)s')

# Flag to track termination state
is_terminating = False

# Handle SIGTERM for graceful shutdown
def handle_sigterm(signum, frame):
    global is_terminating
    is_terminating = True
    shutdown_log = {
        "timestamp": int(time.time()),
        "level": "INFO",
        "event": "shutdown",
        "message": "SIGTERM received, shutting down gracefully"
    }
    app.logger.info(json.dumps(shutdown_log))
    # Simulate cleanup (e.g., closing DB, flushing logs)
    time.sleep(5)
    sys.exit(0)

# Register the signal handler
signal.signal(signal.SIGTERM, handle_sigterm)

@app.route("/")
def index():
    if is_terminating:
        draining_log = {
            "timestamp": int(time.time()),
            "level": "WARN",
            "event": "draining",
            "message": "Request received during termination phase",
            "client_ip": request.remote_addr,
            "status": 503
        }
        app.logger.warning(json.dumps(draining_log))
        return "Service is shutting down. Please try again later.\n", 503

    log_entry = {
        "timestamp": int(time.time()),
        "level": "INFO",
        "event": "home_page_visited",
        "message": "Home page was accessed",
        "client_ip": request.remote_addr,
        "status": 200
    }
    app.logger.info(json.dumps(log_entry))
    return "Welcome to Zero Downtime App!\n"

@app.route("/healthz")
def healthz():
    return "OK", 200

@app.route("/error")
def error():
    log_entry = {
        "timestamp": int(time.time()),
        "level": "ERROR",
        "event": "internal_error",
        "message": "Simulated error occurred",
        "status": 500
    }
    app.logger.error(json.dumps(log_entry))
    return "Internal Server Error\n", 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)