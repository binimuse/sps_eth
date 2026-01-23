# 📱 QR Code Pairing for Wireless Debugging

## ✅ **Yes! QR Code Pairing is Easier**

Android 11+ supports QR code pairing for wireless debugging. This is often more reliable than manual IP/port entry.

---

## 🔧 **Step 1: Enable Wireless Debugging on Kiosk**

### **On the Kiosk Device:**

1. **Enable Developer Options** (if not already):
   - Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable Wireless Debugging:**
   - Settings → Developer Options
   - Find "Wireless debugging"
   - Enable it
   - Tap on "Wireless debugging" to open it

3. **Start Pairing:**
   - In Wireless debugging settings
   - Tap "Pair device with pairing code"
   - You'll see:
     - **QR Code** on screen
     - **Pairing code** (6 digits)
     - **IP Address** and **Port**

---

## 📸 **Step 2: Pair Using QR Code**

### **Option A: Scan QR Code (Easiest)**

1. **On your computer**, run:
   ```bash
   adb pair
   ```
   This will show a prompt asking for pairing code or will try to scan QR code

2. **Or use scrcpy** (if installed):
   ```bash
   scrcpy --tcpip
   ```

3. **Or manually pair:**
   ```bash
   adb pair <IP>:<PAIRING_PORT>
   ```
   Then enter the 6-digit pairing code when prompted

### **Option B: Manual Pairing Code**

If QR code doesn't work:

1. **On kiosk:** Note the pairing code (6 digits) and IP:Port
2. **On computer:**
   ```bash
   adb pair <IP>:<PAIRING_PORT>
   ```
3. **Enter the 6-digit code** when prompted

---

## 🔌 **Step 3: Connect After Pairing**

After successful pairing:

```bash
# Connect to the device
adb connect <IP>:<CONNECTION_PORT>

# Verify connection
adb devices
```

**Note:** The connection port is usually different from the pairing port!

---

## 🎯 **Step-by-Step Example**

### **On Kiosk:**
1. Settings → Developer Options → Wireless debugging
2. Tap "Pair device with pairing code"
3. You'll see:
   ```
   Pairing code: 123456
   IP address: 192.168.1.100
   Port: 12345
   ```
   (And a QR code)

### **On Your Computer:**
```bash
# Pair using the code
adb pair 192.168.1.100:12345

# When prompted, enter: 123456

# After pairing, connect (note: port might be different!)
adb connect 192.168.1.100:5555

# Verify
adb devices
```

---

## 📋 **What I Need From You**

### **After Pairing, Share:**

1. **Connection Status:**
   ```bash
   adb devices
   ```
   (Should show your device)

2. **Test and Get Logs:**
   ```bash
   # Real-time logs
   adb logcat | grep -E "PassportScanner|IDCard|InitIDCard|CheckDevice|Device online|Current device|Error|Failed"
   ```

3. **Or Save Logs:**
   ```bash
   # Clear old logs first
   adb logcat -c
   
   # Then test on kiosk (click Check SDK Status, Scan Passport)
   
   # Save logs
   adb logcat -d > kiosk_logs.txt
   ```

---

## 🚨 **Troubleshooting QR Code Pairing**

### **Issue: QR Code Not Scanning**

**Solution 1: Use Manual Pairing Code**
```bash
adb pair <IP>:<PAIRING_PORT>
# Enter 6-digit code manually
```

**Solution 2: Check ADB Version**
```bash
adb version
# Should be 1.0.41 or higher for QR code support
```

**Solution 3: Update ADB**
```bash
# On Mac:
brew install android-platform-tools

# Or download from:
# https://developer.android.com/studio/releases/platform-tools
```

---

## ✅ **Quick Checklist**

- [ ] Wireless debugging enabled on kiosk
- [ ] "Pair device with pairing code" opened
- [ ] QR code or pairing code visible
- [ ] `adb pair` command run on computer
- [ ] Pairing code entered (if manual)
- [ ] `adb connect` run after pairing
- [ ] `adb devices` shows device connected
- [ ] Ready to capture logs!

---

## 🎯 **Once Connected**

**Run this to see logs in real-time:**
```bash
adb logcat | grep -E "PassportScanner|IDCard|InitIDCard|CheckDevice|Device online|Current device|Error|Failed|USB"
```

**Or save to file:**
```bash
adb logcat -d | grep -E "PassportScanner|IDCard|InitIDCard|CheckDevice|Device online|Current device" > kiosk_logs.txt
```

---

**Share the logs and we'll see exactly what's happening with the hardware!** 🎯
