#!/bin/bash

# Quick script to pair and connect via wireless debugging

echo "=== Wireless Debugging Setup ==="
echo ""
echo "Step 1: On Kiosk Device"
echo "  - Settings → Developer Options → Wireless debugging"
echo "  - Tap 'Pair device with pairing code'"
echo "  - Note the IP address, port, and pairing code"
echo ""
echo "Step 2: Pair Device"
read -p "Enter IP address: " IP
read -p "Enter pairing port: " PAIRING_PORT
echo ""
echo "Running: adb pair $IP:$PAIRING_PORT"
adb pair $IP:$PAIRING_PORT
echo ""
read -p "Enter the 6-digit pairing code: " CODE
echo ""
echo "Step 3: Connect"
read -p "Enter connection port (usually 5555): " CONNECTION_PORT
echo ""
echo "Running: adb connect $IP:$CONNECTION_PORT"
adb connect $IP:$CONNECTION_PORT
echo ""
echo "Step 4: Verify Connection"
adb devices
echo ""
echo "=== Ready to Capture Logs ==="
echo "Run: adb logcat | grep -E 'PassportScanner|IDCard|InitIDCard|CheckDevice'"
