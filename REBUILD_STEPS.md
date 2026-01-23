# 🔄 STEP-BY-STEP REBUILD INSTRUCTIONS

## ⚠️ **CRITICAL: You MUST Rebuild the App**

The error `MissingPluginException` means the app is still running **old native code**. 

**Hot reload/hot restart WILL NOT fix this** - you need a **FULL REBUILD**.

---

## 📋 **Step-by-Step Instructions**

### **Step 1: Stop the App Completely**

**In Terminal:**
- Press `q` to quit, OR
- Press `Ctrl+C` to stop

**In IDE (VS Code/Android Studio):**
- Click the **red stop button** (🛑)
- Make sure the app is **completely stopped**

### **Step 2: Clean Build (Important!)**

```bash
flutter clean
```

This removes old build artifacts.

### **Step 3: Rebuild and Run**

```bash
flutter run
```

**OR** if you're using an IDE:
- Click the **green play button** (▶️)
- Make sure it says "Run" not "Hot Reload"

### **Step 4: Wait for Full Build**

The build will take 1-3 minutes. You'll see:
```
Running Gradle task 'assembleDebug'...
```

**Wait for it to complete!**

### **Step 5: Verify It Worked**

After the app launches, click **"Check SDK Status"** button.

**You should see:**
```
I/flutter: === Checking SDK Status ===
I/flutter: SDK Status:
I/flutter:   - SDK Loaded: true
I/flutter:   - Assets Copied: true
```

**NOT:**
```
MissingPluginException ❌
```

---

## 🚨 **Common Mistakes**

### ❌ **Mistake 1: Using Hot Reload**
```
Don't press 'r' for hot reload
Don't press 'R' for hot restart
```
These **WON'T** reload native code!

### ❌ **Mistake 2: Not Stopping First**
```
Don't just run flutter run again
Stop the app FIRST, then rebuild
```

### ❌ **Mistake 3: Skipping flutter clean**
```
flutter clean removes old build files
This ensures a fresh build
```

---

## ✅ **Quick Verification**

After rebuilding, check the logs:

**Good (Rebuilt):**
```
D/PassportScanner: === Checking SDK Status ===
D/PassportScanner: SDK Status: {...}
```

**Bad (Not Rebuilt):**
```
MissingPluginException(No implementation found for method checkSDKStatus...)
```

---

## 🎯 **If Still Not Working**

1. **Uninstall the app completely:**
   ```bash
   adb uninstall com.sps.eth.sps_eth_app
   ```

2. **Clean everything:**
   ```bash
   flutter clean
   cd android
   ./gradlew clean
   cd ..
   ```

3. **Rebuild:**
   ```bash
   flutter run
   ```

---

## 📝 **Why This Happens**

- **Flutter Hot Reload**: Only reloads Dart code
- **Native Code Changes**: Require full rebuild
- **MethodChannel**: Part of native code, needs rebuild

**Every time you change:**
- `MainActivity.kt` ✅ Need rebuild
- `IDCardAPI.java` ✅ Need rebuild
- Any Kotlin/Java files ✅ Need rebuild

**You DON'T need rebuild for:**
- Dart files (.dart) ✅ Hot reload works
- UI changes ✅ Hot reload works

---

**Follow these steps exactly and it will work!** ✅
