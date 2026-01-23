# 🔧 Hardware Detection Troubleshooting Guide

## ⚠️ **Issue: Hardware Not Detected on SPS Kiosk**

If you're running on the actual SPS Smart Police Station hardware but still getting "hardware not found", follow these steps:

---

## 🔍 **Step 1: Check USB Connection**

### **Physical Checks:**
1. ✅ **USB/OTG Cable Connected?**
   - Check if cable is firmly connected
   - Try a different USB port
   - Try a different cable

2. ✅ **Scanner Powered On?**
   - Check scanner power indicator
   - Ensure scanner is fully booted

3. ✅ **USB Host Mode Enabled?**
   - Some devices need USB host mode enabled
   - Check device settings → USB → USB Host Mode

---

## 🔍 **Step 2: Check USB Permissions**

### **On the Kiosk Device:**

1. **Check USB Device List:**
   ```bash
   adb shell lsusb
   # or
   adb shell ls /dev/bus/usb/
   ```

2. **Check if Scanner Appears:**
   ```bash
   adb shell dmesg | grep -i usb
   ```

3. **Grant USB Permissions:**
   - Go to Settings → Apps → Your App
   - Permissions → USB → Allow
   - Or check "USB device access" permission

---

## 🔍 **Step 3: Check Logs**

### **Get Detailed Logs:**
```bash
adb logcat | grep PassportScanner
```

**Look for:**
- `InitIDCard returned: X` (what code?)
- `Device online check: X` (0 or 1?)
- `Current device: [device name]`
- Any USB permission errors

---

## 🔍 **Step 4: Common Issues & Solutions**

### **Issue 1: Error Code 2 (Device initialization failed)**

**Possible Causes:**
- USB not connected properly
- USB permissions not granted
- Device driver not loaded
- Scanner not powered on

**Solutions:**
1. Reconnect USB cable
2. Grant USB permissions in app settings
3. Restart scanner
4. Check if device appears in `lsusb`

---

### **Issue 2: Device Check Returns 0**

**Even after successful initialization:**

**Possible Causes:**
- Device not properly enumerated
- USB host mode not enabled
- Device needs specific initialization sequence

**Solutions:**
1. Enable USB host mode in device settings
2. Try unplugging and replugging USB
3. Restart the kiosk device
4. Check device manager for scanner device

---

### **Issue 3: Permission Denied Errors**

**Solutions:**
1. **Grant USB Permission:**
   ```bash
   adb shell pm grant com.sps.eth.sps_eth_app android.permission.USB_PERMISSION
   ```

2. **Check Manifest:**
   - Ensure `USB_PERMISSION` is in manifest ✅
   - Ensure `android.hardware.usb.host` feature declared ✅

3. **Runtime Permission:**
   - Some Android versions need runtime USB permission
   - Check app settings → Permissions

---

## 🔍 **Step 5: Verify Device Detection**

### **Use "Check SDK Status" Button:**

After clicking, check the logs for:
```
Device Status:
  - Device online: 1 (should be 1, not 0)
  - Current device: [device name] (should show device name)
  - Device type: [type]
  - Device SN: [serial number]
```

**If all are "None" or 0:**
- Hardware not detected
- Check USB connection
- Check permissions

---

## 🔍 **Step 6: SDK-Specific Checks**

### **Check SDK Configuration:**

1. **Verify License:**
   - `IDCardLicense.dat` present? ✅
   - License valid for this device?

2. **Check Hardware ID:**
   - `HardWareID.xml` matches device?
   - Hardware ID registered?

3. **Verify Device Type:**
   - SDK supports this scanner model?
   - Check SDK documentation for supported devices

---

## 🔍 **Step 7: Advanced Diagnostics**

### **Check USB Devices:**
```bash
# List USB devices
adb shell lsusb

# Check USB permissions
adb shell ls -l /dev/bus/usb/

# Check dmesg for USB events
adb shell dmesg | tail -50
```

### **Check App Permissions:**
```bash
# List app permissions
adb shell dumpsys package com.sps.eth.sps_eth_app | grep permission
```

### **Check SDK Logs:**
```bash
# Filter for SDK-related logs
adb logcat | grep -E "PassportScanner|IDCard|USB"
```

---

## 📋 **Checklist**

- [ ] USB cable connected firmly
- [ ] Scanner powered on
- [ ] USB host mode enabled (if required)
- [ ] USB permissions granted
- [ ] Device appears in `lsusb`
- [ ] SDK initialized (check logs)
- [ ] Device check returns 1 (not 0)
- [ ] Device name appears in logs
- [ ] License file present and valid
- [ ] Hardware ID matches device

---

## 🆘 **Still Not Working?**

### **Contact SDK Vendor:**
1. Provide device model
2. Provide scanner model
3. Provide error logs
4. Ask about:
   - USB connection requirements
   - Permission requirements
   - Device-specific initialization
   - License/authorization issues

### **Check SDK Documentation:**
- USB connection requirements
- Permission requirements
- Device initialization sequence
- Troubleshooting guide

---

## 📝 **What to Report**

If you need help, provide:
1. **Error Code:** (from InitIDCard)
2. **Device Check Result:** (0 or 1)
3. **Device Name:** (from GetCurrentDevice)
4. **USB Status:** (from lsusb)
5. **Full Logs:** (adb logcat | grep PassportScanner)
6. **Device Model:** (SPS kiosk model)
7. **Scanner Model:** (scanner hardware model)

---

**Most Common Fix:** USB permissions not granted or USB host mode not enabled! 🔌
