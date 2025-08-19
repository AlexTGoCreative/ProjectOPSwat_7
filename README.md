# Weather VM Automation

This project automates a VM to fetch and display current weather information for a chosen city on startup and at login.

## 🎯 Project Goal
Automate your VM so that it fetches the current weather for a chosen city on startup and shows it at login through the Message of the Day (MOTD).

## 📋 Components

### 1. Environment Configuration
- **File**: `/etc/default/weather`
- **Purpose**: Stores the city name configuration
- **Default**: Timisoara

**Copy the content from `etc_default_weather` file to `/etc/default/weather`**

### 2. Weather Script
- **File**: `/usr/local/sbin/weather.sh`
- **Purpose**: Fetches weather data and updates MOTD
- **Features**: 
  - Installs required packages (curl, jq)
  - Fetches weather from wttr.in
  - Generates clean MOTD
  - Includes bonus features (uptime, disk usage)
  - Logs activities to `/var/log/weather.log`

**Copy the content from `Weather.sh` file to `/usr/local/sbin/weather.sh`**

### 3. Systemd Service
- **File**: `/etc/systemd/system/weather.service`
- **Purpose**: Runs weather script at boot
- **Type**: oneshot with RemainAfterExit=yes

**Copy the content from `weather.service` file to `/etc/systemd/system/weather.service`**

## 🚀 Installation Commands

Run these commands on your AWS Linux VM as root or with sudo:

```bash
# 1. Creeaza fișierele cu conținutul lor
sudo tee /etc/default/weather << 'CONFIG_END'
CITY=Timisoara
CONFIG_END

sudo tee /usr/local/sbin/weather.sh << 'SCRIPT_END'
    **Copy the content from weather.sh**
SCRIPT_END

sudo tee /etc/systemd/system/weather.service << 'SERVICE_END'
    **Copy the content from weatherService**
SERVICE_END

# 2. Set proper permissions
sudo chmod 644 /etc/default/weather
sudo chmod 755 /usr/local/sbin/weather.sh
sudo chmod 644 /etc/systemd/system/weather.service

# 3. Create log file directory and file
sudo touch /var/log/weather.log
sudo chmod 644 /var/log/weather.log

# 4. Reload systemd and enable service
sudo systemctl daemon-reload 
sudo systemctl enable weather.service
sudo systemctl start weather.service

# 5. Verify installation
sudo systemctl status weather.service
cat /etc/motd
```

## 🔍 Verification

### Check Service Status
```bash
sudo systemctl status weather.service
```
Should show: `active (exited)`

### View MOTD
```bash
cat /etc/motd
```

### Expected Output
```
==== Welcome to your Dev VM ====
City: Timisoara
Weather today: ⛅️ +15°C
Hostname: ip-172-31-xx-xx
Time: 2024-01-15 10:30:45
===============================
```

### Test Configuration Changes
```bash
# Change city
sudo sed -i 's/CITY=.*/CITY=Bucharest/' /etc/default/weather

# Restart service to apply changes
sudo systemctl restart weather.service

# Check updated MOTD
cat /etc/motd
```

### View Logs
```bash
sudo tail -f /var/log/weather.log
```

## 🛠️ Troubleshooting

### Service fails to start
```bash
# Check service logs
sudo journalctl -u weather.service -f

# Manual script execution
sudo /usr/local/sbin/weather.sh
```

### Network issues
- Ensure VM has internet connectivity
- Check if wttr.in is accessible: `curl wttr.in/Timisoara?format=3`

### Permission issues
- Verify script is executable: `ls -la /usr/local/sbin/weather.sh`
- Check systemd file permissions: `ls -la /etc/systemd/system/weather.service`

## 🧩 Features

### Core Requirements ✅
- [x] Environment configuration in `/etc/default/weather`
- [x] Weather script reads CITY variable with default fallback
- [x] Installs required packages (curl, jq)
- [x] Fetches weather from wttr.in
- [x] Generates clean MOTD (idempotent)
- [x] systemd service runs at boot
- [x] Service loads environment variables
- [x] Type: oneshot, RemainAfterExit=yes

### Bonus Features ✅
- [x] Uptime information in MOTD
- [x] Disk usage information in MOTD
- [x] Weather fetch logging to `/var/log/weather.log`
- [x] Safe script execution (`set -euo pipefail`)
- [x] Command logging with timestamps

## 🔧 Customization

### Change Default City
Edit `/etc/default/weather`:
```bash
sudo nano /etc/default/weather
# Change CITY=YourCityName
sudo systemctl restart weather.service
```

### Modify MOTD Format
Edit `/usr/local/sbin/weather.sh` and modify the MOTD generation section.

### Add More System Information
Add additional system commands in the weather.sh script before the MOTD generation.
