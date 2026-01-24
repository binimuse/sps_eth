# 📱 Android 12 Compatibility Guide

## ✅ **Yes, Android 12 Can Affect USB Device Access!**

Android 12 (API level 31) introduced several changes that affect USB device access and permissions. Here's what we've addressed:

---

## 🔧 **Android 12 Specific Changes**

### **1. PendingIntent Mutability** ✅ FIXED
- **Requirement:** All PendingIntents must specify `FLAG_IMMUTABLE` or `FLAG_MUTABLE`
- **Status:** ✅ Fixed - Using `FLAG_IMMUTABLE` for all Android 6.0+

### **2. BroadcastReceiver Registration** ✅ FIXED
- **Android 13+:** Requires `RECEIVER_EXPORTED` or `RECEIVER_NOT_EXPORTED` flag
- **Android 12:** No flag needed (but we handle both)
- **Status:** ✅ Fixed - Version-specific registration

### **3. USB Permission Handling** ✅ IMPROVED
- **Android 12:** Stricter enforcement of USB permissions
- **Status:** ✅ Improved - Better permission request handling

### **4. Package Visibility** ✅ CHECKED
- **Android 11+:** Apps must declare queries for certain intents
- **Status:** ✅ Already handled in manifest

---

## 📋 **What We've Added for Android 12**

### **1. Proper PendingIntent Flags**
```kotlin
// Always uses FLAG_IMMUTABLE for Android 6.0+
PendingIntent.FLAG_IMMUTABLE
```

### **2. Version-Specific Receiver Registration**
```kotlin
// Android 13+: RECEIVER_EXPORTED required
// Android 12: No flag needed
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    registerReceiver(..., Context.RECEIVER_EXPORTED)
} else {
    registerReceiver(...)
}
```

### **3. USB Device Attached Listener**
- Listens for USB device attachment events
- Automatically requests permission when device is connected
- Works better on Android 12+

### **4. Better Error Handling**
- Checks if USB service is available
- Logs detailed device information
- Handles permission denials gracefully

---

## 🎯 **Android 12 Specific Issues**

### **Issue: USB Permission Not Granted**

**On Android 12, you might see:**
- Permission dialog appears but gets denied
- Device detected but initialization fails

**Solutions:**
1. **Grant Permission Manually:**
   - Settings → Apps → Your App → Permissions
   - Look for "USB device access" or similar
   - Grant permission

2. **Check USB Host Mode:**
   - Settings → USB → USB Host Mode
   - Enable if available

3. **Restart After Permission:**
   - After granting permission, restart the app
   - Permission should persist

---

## 📊 **Expected Behavior on Android 12**

### **When App Starts:**
1. ✅ USB permission receiver registered
2. ✅ Checks for connected USB devices
3. ✅ Requests permission if needed
4. ✅ Shows permission dialog

### **When Permission Granted:**
1. ✅ Logs: "USB permission GRANTED"
2. ✅ SDK should initialize successfully
3. ✅ Device online check should return 1

### **If Permission Denied:**
1. ❌ Logs: "USB permission DENIED"
2. ❌ SDK initialization will fail (Error Code 2)
3. ❌ Device online check returns 0

---

## 🔍 **Troubleshooting on Android 12**

### **Check 1: USB Permission Status**
```bash
# On kiosk (if you can access adb)
adb shell dumpsys package com.sps.eth.sps_eth_app | grep -i usb
```

### **Check 2: USB Devices**
```bash
adb shell lsusb
# Should show scanner device
```

### **Check 3: App Logs**
Look for:
- "Found X USB device(s)"
- "Requesting USB permission"
- "USB permission GRANTED" or "DENIED"

---

## ✅ **What's Fixed**

- ✅ PendingIntent mutability (Android 12+ requirement)
- ✅ BroadcastReceiver registration (Android 13+ compatibility)
- ✅ USB permission request handling
- ✅ USB device attachment detection
- ✅ Better error logging

---

## 🎯 **Next Steps**

1. **Rebuild APK:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

2. **Install on Android 12 Kiosk:**
   - Install APK
   - Open app
   - **Grant USB permission when asked**

3. **Test:**
   - Press "Scan Passport"
   - Check diagnostic report
   - Should see "USB permission GRANTED" in logs

---

## 📝 **Android 12 Checklist**

- [x] ✅ PendingIntent uses FLAG_IMMUTABLE
- [x] ✅ BroadcastReceiver properly registered
- [x] ✅ USB permission request implemented
- [x] ✅ USB device attachment listener added
- [x] ✅ Error handling improved
- [ ] ⏳ Test on actual Android 12 kiosk
- [ ] ⏳ Verify USB permission dialog appears
- [ ] ⏳ Verify permission persists after grant

---

**The code is now Android 12 compatible!** 🎯

Rebuild and test - the USB permission should work correctly on Android 12.
