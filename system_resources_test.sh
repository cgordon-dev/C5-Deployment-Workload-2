#!/bin/bash
# This script checks available resources (CPU, Memory, and Disk space) to ensure it does not exceed assigned thresholds
# If a threshold is exceeded, a message will appear that indicates which resource
# Define threshold values
CPU_THRESHOLD=60   # 60% CPU usage
MEMORY_THRESHOLD=70  # 70% Memory usage
DISK_THRESHOLD=70   # 70% Disk usage

# Check CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
  echo "CPU usage is above threshold: $CPU_USAGE%"
  exit 1
else
  echo "CPU usage is within limits: $CPU_USAGE%"
fi

# Check Memory Usage
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
  echo "Memory usage is above threshold: $MEMORY_USAGE%"
  exit 1
else
  echo "Memory usage is within limits: $MEMORY_USAGE%"
fi

# Check Disk Usage (Root Partition)
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
  echo "Disk usage is above threshold: $DISK_USAGE%"
  exit 1
else
  echo "Disk usage is within limits: $DISK_USAGE%"
fi

# If all checks pass
echo "All system resources are within defined limits."
exit 0
