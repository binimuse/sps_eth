# 📡 Wireless Debugging Setup Guide

## ✅ **Great! Let's Connect Wirelessly**

This will let us see real-time logs from the kiosk machine and diagnose the hardware issue.

---

## 🔧 **Step 1: Enable Wireless Debugging on Kiosk**

### **On the Kiosk Device:**

1. **Enable Developer Options** (if not already):
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer options will appear

2. **Enable Wireless Debugging:**
   - Settings → Developer Options
   - Find "Wireless debugging" or "ADB over network"
   - Enable it

3. **Get Connection Info:**
   - Tap "Wireless debugging"
   - You'll see:
     - **IP Address:** (e.g., 192.168.1.100)
     - **Port:** (usually 5555)
     - Or a **Pairing Code** and **Port**

---

## 🔌 **Step 2: Connect from Your Computer**

### **Option A: Using IP and Port (Android 11+)**

```bash
# Connect to kiosk
adb connect <IP_ADDRESS>:<PORT>

# Example:
adb connect 192.168.1.100:5555
```

### **Option B: Using Pairing Code (Android 11+)**

```bash
# First, pair using code
adb pair <IP_ADDRESS>:<PAIRING_PORT>

# Then connect
adb connect <IP_ADDRESS>:<CONNECTION_PORT>
```

### **Verify Connection:**
```bash
adb devices
# Should show your device listed
```

---

## 📊 **Step 3: Get Real-Time Logs**

### **Watch Passport Scanner Logs:**
```bash
adb logcat | grep -E "PassportScanner|IDCard|USB|InitIDCard|CheckDevice"
```

### **Or Get All Logs:**
```bash
adb logcat > kiosk_logs.txt
# Press Ctrl+C to stop
```

---

## 🎯 **Step 4: Test and Capture Logs**

1. **On Kiosk:** Open the app
2. **On Kiosk:** Navigate to Visitor ID screen
3. **On Kiosk:** Click "Check SDK Status" button
4. **On Kiosk:** Click "Scan Passport" button
5. **On Computer:** Watch the logs in real-time

---

## 📋 **What I Need From You**

### **1. Connection Info:**
- IP Address: `_____________`
- Port: `_____________`
- (Or pairing code if using that method)

### **2. Logs After Testing:**
Run these commands and share the output:

```bash
# Get SDK initialization logs
adb logcat -d | grep -E "PassportScanner|InitIDCard" > init_logs.txt

# Get device detection logs
adb logcat -d | grep -E "Device|CheckDevice|USB" > device_logs.txt

# Get all relevant logs
adb logcat -d | grep -E "PassportScanner|IDCard|USB|InitIDCard|CheckDevice|Device online|Current device" > all_logs.txt
```

### **3. Device Info:**
```bash
# Check USB devices
adb shell lsusb

# Check device info
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```

---

## 🚀 **Quick Start Commands**

**Once connected, run this to see logs in real-time:**

```bash
# Real-time filtered logs
adb logcat | grep -E "PassportScanner|IDCard|InitIDCard|CheckDevice|Device online|Current device|Error|Failed"
```

---

## ✅ **What We're Looking For**

In the logs, we need to see:

1. **SDK Initialization:**
   ```
   InitIDCard returned: X
   ```
   - What error code? (0 = success, 2 = device init failed, etc.)

2. **Device Detection:**
   ```
   Device online check: X
   Current device: [name]
   Device type: X
   Device SN: [serial]
   ```
   - Is device online 0 or 1?
   - Does it show a device name?

3. **Any Errors:**
   ```
   Error: ...
   Failed: ...
   Exception: ...
   ```

---

## 📝 **Share These Files:**

1. `init_logs.txt` - SDK initialization logs
2. `device_logs.txt` - Device detection logs  
3. `all_logs.txt` - All relevant logs
4. Output of `adb shell lsusb` - USB devices list

---

**Once you share the IP/port, I'll help you connect and we'll see exactly what's happening!** 🎯
