#!/bin/bash
# This script checks available resources (CPU, Memory, and Disk space) to ensure it does not exceed assigned thresholds
# If a threshold is exceeded, a message will appear that indicates which resource
# Define threshold values
CPU_THRESHOLD=60
MEMORY_THRESHOLD=90
DISK_THRESHOLD=70

echo "Checking system resource usage..."

# Check CPU Usage
CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")
CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")
echo "CPU idle: $CPU_IDLE%, CPU usage: $CPU_USAGE%"
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
  echo "CPU usage is above threshold: $CPU_USAGE%"
  exit 1
else
  echo "CPU usage is within limits: $CPU_USAGE%"
fi

# Check Memory Usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
echo "Memory usage: $MEMORY_USAGE%"
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
  echo "Memory usage is above threshold: $MEMORY_USAGE%"
  exit 1
else
  echo "Memory usage is within limits: $MEMORY_USAGE%"
fi

# Check Disk Usage
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
echo "Disk usage: $DISK_USAGE%"
if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
  echo "Disk usage is above threshold: $DISK_USAGE%"
  exit 1
else
  echo "Disk usage is within limits: $DISK_USAGE%"
fi

echo "All system resources are within defined limits."
exit 0

