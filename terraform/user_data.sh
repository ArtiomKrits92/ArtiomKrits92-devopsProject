#!/bin/bash
# ec2 user data script
# runs when instance starts up

set -e

# system update and package installation
echo "Starting system update..."
yum update -y

echo "Installing required packages..."
yum install -y \
    python3 \
    python3-pip \
    git \
    htop \
    wget \
    curl \
    unzip \
    firewalld

# python environment setup
echo "Setting up Python environment..."
mkdir -p /opt/webapp
cd /opt/webapp

# create virtual environment
python3 -m venv venv
source venv/bin/activate

# install python packages
pip install --upgrade pip
pip install flask gunicorn

# create flask application
cat > app.py << 'EOF'
#!/usr/bin/env python3
from flask import Flask, render_template_string
import socket
import platform
import datetime
import os

app = Flask(__name__)

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .info-box {
            background-color: #f8f9fa;
            padding: 15px;
            margin: 10px 0;
            border-left: 4px solid #007bff;
            border-radius: 5px;
        }
        .info-label {
            font-weight: bold;
            color: #495057;
        }
        .info-value {
            color: #6c757d;
            margin-left: 10px;
        }
        .status {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 5px;
            color: #155724;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{ title }}</h1>
        
        <div class="info-box">
            <span class="info-label">Server Hostname:</span>
            <span class="info-value">{{ hostname }}</span>
        </div>
        
        <div class="info-box">
            <span class="info-label">Private IP Address:</span>
            <span class="info-value">{{ private_ip }}</span>
        </div>
        
        <div class="info-box">
            <span class="info-label">Operating System:</span>
            <span class="info-value">{{ os_info }}</span>
        </div>
        
        <div class="info-box">
            <span class="info-label">Python Version:</span>
            <span class="info-value">{{ python_version }}</span>
        </div>
        
        <div class="info-box">
            <span class="info-label">Current Time:</span>
            <span class="info-value">{{ current_time }}</span>
        </div>
        
        <div class="info-box">
            <span class="info-label">Application Port:</span>
            <span class="info-value">{{ app_port }}</span>
        </div>
        
        <div class="status">
            <strong>✅ Application is running successfully!</strong><br>
            <small>This server is part of a load-balanced web application</small>
        </div>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE,
        title=f"Web Server - {socket.gethostname()}",
        hostname=socket.gethostname(),
        private_ip=socket.gethostbyname(socket.gethostname()),
        os_info=f"{platform.system()} {platform.release()}",
        python_version=platform.python_version(),
        current_time=datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        app_port="${app_port}"
    )

@app.route('/health')
def health():
    return {
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat(),
        "hostname": socket.gethostname(),
        "port": "${app_port}"
    }

@app.route('/api/info')
def api_info():
    return {
        "hostname": socket.gethostname(),
        "private_ip": socket.gethostbyname(socket.gethostname()),
        "os": platform.system(),
        "os_version": platform.release(),
        "python_version": platform.python_version(),
        "timestamp": datetime.datetime.now().isoformat(),
        "app_port": "${app_port}",
        "project": "${project_name}"
    }

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=${app_port}, debug=False)
EOF

# make executable
chmod +x app.py

# create systemd service
cat > /etc/systemd/system/webapp.service << EOF
[Unit]
Description=Web Application Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/webapp
Environment=PATH=/opt/webapp/venv/bin
ExecStart=/opt/webapp/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# enable and start service
systemctl daemon-reload
systemctl enable webapp.service
systemctl start webapp.service

# configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=${app_port}/tcp
firewall-cmd --reload

# setup logging
mkdir -p /var/log/webapp
chown ec2-user:ec2-user /var/log/webapp

# test the application
sleep 10
systemctl status webapp.service
curl -f http://localhost:${app_port}/health || echo "Health check failed"

echo "Web application setup completed!"