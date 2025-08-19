#!/bin/bash

# Set strict error handling
set -euo pipefail

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Load environment variables from config file
if [[ -f /etc/default/weather ]]; then
    source /etc/default/weather
    log_message "Loaded configuration from /etc/default/weather"
else
    log_message "Configuration file not found, using default city"
fi

# Default to Timisoara if CITY is not set
CITY=${CITY:-"Timisoara"}
log_message "Using city: $CITY"

# Install required packages if missing (AWS Linux compatible)
install_packages() {
    local packages=("curl" "jq")
    local missing_packages=()

    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        log_message "Installing missing packages: ${missing_packages[*]}"
        # Use yum for Amazon Linux 2 or dnf for Amazon Linux 2023
        if command -v dnf &> /dev/null; then
            dnf update -y -q
            dnf install -y "${missing_packages[@]}"
        elif command -v yum &> /dev/null; then
            yum update -y -q
            yum install -y "${missing_packages[@]}"
        else
            log_message "Error: No package manager found (yum/dnf)"
            return 1
        fi
        log_message "Packages installed successfully"
    else
        log_message "All required packages are already installed"
    fi
}

# Fetch weather information
fetch_weather() {
    local weather_info

    # Fetch weather with timeout and retry
    if weather_info=$(timeout 10 curl -s "wttr.in/$CITY?format=3" 2>/dev/null); then
        if [[ -n "$weather_info" && "$weather_info" != *"Unknown location"* ]]; then
            echo "$weather_info"
            #log_message "Weather fetched successfully"
        else
            echo "Weather unavailable for $CITY"
            log_message "Weather service returned invalid data"
        fi
    else
        echo "Weather service unavailable"
        log_message "Failed to fetch weather data"
    fi
}

# Generate MOTD
generate_motd() {
    local weather_info="$1"
    local hostname=$(hostname)
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    log_message "Generating MOTD"

    # Create clean MOTD (overwrite, not append)
    cat > /etc/motd << MOTD_END
====================================
     Welcome to your Dev VM
====================================

City: $CITY
Weather today: $weather_info
Hostname: $hostname
Time: $current_time

====================================
MOTD_END

    log_message "MOTD generated successfully"
}

# Main execution
main() {
    log_message "Starting weather script"

    # Install packages if needed
    install_packages

    # Fetch weather
    local weather=$(fetch_weather)

    # Generate MOTD
    generate_motd "$weather"

    log_message "Weather script completed successfully"
}

# Run main function
main "$@"