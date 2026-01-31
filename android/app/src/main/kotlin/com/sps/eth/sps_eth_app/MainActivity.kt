package com.sps.eth.sps_eth_app

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import product.idcard.android.IDCardAPI
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "passport_scanner"
    private val TAG = "PassportScanner"
    private val ACTION_USB_PERMISSION = "com.sps.eth.sps_eth_app.USB_PERMISSION"
    
    private val usbPermissionReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_USB_PERMISSION == intent.action) {
                synchronized(this) {
                    val device: UsbDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    }
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        device?.apply {
                            Log.d(TAG, "USB permission granted for device: $deviceName")
                        }
                    } else {
                        Log.e(TAG, "USB permission denied for device: ${device?.deviceName}")
                    }
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Full screen: use whole screen, draw over system bars, keep screen on
        setupFullScreen()

        // Register USB permission receiver
        // Android 13+ (API 33) requires RECEIVER_EXPORTED or RECEIVER_NOT_EXPORTED
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ requires explicit flag
            registerReceiver(usbPermissionReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            // Android 12 and below - no flag needed
            registerReceiver(usbPermissionReceiver, filter)
        }
        
        // Also register for USB device attached events
        val usbAttachedFilter = IntentFilter(UsbManager.ACTION_USB_DEVICE_ATTACHED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(usbPermissionReceiver, usbAttachedFilter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(usbPermissionReceiver, usbAttachedFilter)
        }
        
        // Request USB permissions for connected devices
        requestUSBPermissions()
    }

    /** Full screen: hide status/nav bars, use whole screen, keep screen on. */
    private fun setupFullScreen() {
        val window = window
        window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
        window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.decorView.systemUiVisibility = (
            View.SYSTEM_UI_FLAG_FULLSCREEN
            or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
            or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(usbPermissionReceiver)
        } catch (e: Exception) {
            Log.w(TAG, "Error unregistering USB receiver: ${e.message}")
        }
    }
    
    private fun requestUSBPermissions() {
        try {
            // CRITICAL: Wintone devices require USB folder permissions
            // Try to change /dev/bus/usb permissions (requires root on some devices)
            trySetUSBPermissions()
            
            val usbManager = getSystemService(Context.USB_SERVICE) as? UsbManager
            if (usbManager == null) {
                Log.e(TAG, "USB service not available")
                return
            }
            
            val deviceList = usbManager.deviceList
            Log.d(TAG, "Found ${deviceList.size} USB device(s) on Android ${Build.VERSION.SDK_INT}")
            
            if (deviceList.isEmpty()) {
                Log.w(TAG, "No USB devices found. Check:")
                Log.w(TAG, "  1. USB/OTG cable connected")
                Log.w(TAG, "  2. Scanner powered on")
                Log.w(TAG, "  3. USB host mode enabled")
                Log.w(TAG, "  4. USB folder permissions (Wintone requires chmod 777 /dev/bus/usb/)")
                return
            }
            
            for (device in deviceList.values) {
                val hasPermission = usbManager.hasPermission(device)
                Log.d(TAG, "Device: ${device.deviceName}")
                Log.d(TAG, "  VID: 0x${device.vendorId.toString(16)} (${device.vendorId}), PID: 0x${device.productId.toString(16)} (${device.productId})")
                Log.d(TAG, "  Has Permission: $hasPermission")
                
                // Check if it's a Wintone device
                if (device.vendorId == 0x0828 && (device.productId == 0x1002 || device.productId == 0x1010)) {
                    Log.d(TAG, "  ✅ WINTONE DEVICE DETECTED!")
                }
                
                if (!hasPermission) {
                    Log.d(TAG, "Requesting USB permission for: ${device.deviceName}")
                    
                    // Android 12+ requires FLAG_IMMUTABLE for PendingIntent
                    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        PendingIntent.FLAG_IMMUTABLE
                    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.FLAG_IMMUTABLE
                    } else {
                        @Suppress("DEPRECATION", "UnspecifiedImmutableFlag")
                        0
                    }
                    
                    val permissionIntent = PendingIntent.getBroadcast(
                        this, 0,
                        Intent(ACTION_USB_PERMISSION).apply {
                            putExtra(UsbManager.EXTRA_DEVICE, device)
                        },
                        flags
                    )
                    
                    usbManager.requestPermission(device, permissionIntent)
                    Log.d(TAG, "USB permission request sent for: ${device.deviceName}")
                } else {
                    Log.d(TAG, "✅ USB permission already granted for: ${device.deviceName}")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting USB permissions: ${e.message}", e)
        }
    }
    
    /**
     * Try to set USB folder permissions for Wintone devices
     * This is critical for Wintone EZUsbDevice to work properly
     */
    private fun trySetUSBPermissions() {
        try {
            Log.d(TAG, "=== Checking USB Folder Permissions ===")
            
            // Check if /dev/bus/usb exists
            val usbFolder = File("/dev/bus/usb")
            if (!usbFolder.exists()) {
                Log.w(TAG, "/dev/bus/usb folder does not exist")
                return
            }
            
            Log.d(TAG, "/dev/bus/usb exists: ${usbFolder.canRead()}")
            
            // Try to execute chmod command (requires root or system app)
            try {
                val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", "chmod -R 777 /dev/bus/usb/"))
                val exitCode = process.waitFor()
                
                if (exitCode == 0) {
                    Log.d(TAG, "✅ Successfully changed USB folder permissions")
                } else {
                    Log.w(TAG, "⚠️ chmod command returned: $exitCode (may require root)")
                }
            } catch (e: Exception) {
                Log.w(TAG, "⚠️ Cannot change USB permissions (not root): ${e.message}")
                Log.w(TAG, "   This is CRITICAL for Wintone devices!")
                Log.w(TAG, "   The kiosk may need to:")
                Log.w(TAG, "   1. Run as system app")
                Log.w(TAG, "   2. Have root access")
                Log.w(TAG, "   3. Have USB permissions pre-configured")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking USB permissions: ${e.message}", e)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "checkSDKStatus") {
                // Diagnostic method to check SDK status without requiring hardware
                Thread {
                    try {
                        Log.d(TAG, "=== Checking SDK Status ===")
                        val api = IDCardAPI()
                        val copyUtil = CopyAssetsUtil(this)
                        val kernelPath = copyUtil.copyAssetsToInternal()
                        
                        val status = HashMap<String, Any>()
                        status["sdkLoaded"] = true
                        status["assetsCopied"] = kernelPath != null
                        status["assetsPath"] = kernelPath ?: "Failed"
                        
                        // Get USB device information
                        try {
                            val usbManager = getSystemService(Context.USB_SERVICE) as? UsbManager
                            if (usbManager != null) {
                                val deviceList = usbManager.deviceList
                                if (deviceList.isNotEmpty()) {
                                    val usbDevices = mutableListOf<Map<String, Any>>()
                                    for (device in deviceList.values) {
                                        val hasPermission = usbManager.hasPermission(device)
                                        val deviceInfo = hashMapOf<String, Any>(
                                            "name" to (device.deviceName ?: "Unknown"),
                                            "vendorId" to device.vendorId,
                                            "vendorIdHex" to "0x${device.vendorId.toString(16).uppercase()}",
                                            "productId" to device.productId,
                                            "productIdHex" to "0x${device.productId.toString(16).uppercase()}",
                                            "deviceClass" to device.deviceClass,
                                            "hasPermission" to hasPermission
                                        )
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                            deviceInfo["manufacturer"] = device.manufacturerName ?: "Unknown"
                                            deviceInfo["product"] = device.productName ?: "Unknown"
                                            deviceInfo["serial"] = device.serialNumber ?: "Unknown"
                                        }
                                        usbDevices.add(deviceInfo)
                                    }
                                    status["usbDevices"] = usbDevices
                                    status["usbDeviceCount"] = deviceList.size
                                } else {
                                    status["usbDevices"] = emptyList<Map<String, Any>>()
                                    status["usbDeviceCount"] = 0
                                }
                            }
                        } catch (e: Exception) {
                            status["usbDeviceError"] = e.message ?: "Unknown error"
                        }
                        
                        if (kernelPath != null) {
                            val configFile = File(kernelPath + "IDCardConfig.ini")
                            status["configFileExists"] = configFile.exists()
                            
                            // Try to initialize SDK to check device status
                            // This will fail with error code 2 on tablet (expected)
                            val initRet = api.InitIDCard("", 1, kernelPath)
                            status["initAttempted"] = true
                            status["initResult"] = initRet
                            status["initSuccess"] = initRet == 0
                            
                            if (initRet == 0) {
                                // SDK initialized successfully - check device
                                try {
                                    val deviceOnline = api.CheckDeviceOnlineEx()
                                    val currentDevice = api.GetCurrentDevice()
                                    val deviceType = api.GetDeviceType()
                                    val deviceSN = api.GetDeviceSN()
                                    
                                    status["deviceOnline"] = deviceOnline == 1
                                    status["currentDevice"] = currentDevice ?: "None"
                                    status["deviceType"] = deviceType
                                    status["deviceSN"] = deviceSN ?: "None"
                                    status["hardwareDetected"] = deviceOnline == 1
                                    
                                    api.FreeIDCard()
                                } catch (e: Exception) {
                                    status["deviceOnline"] = false
                                    status["currentDevice"] = "Error checking device"
                                    status["hardwareDetected"] = false
                                    status["deviceCheckError"] = e.message ?: "Unknown"
                                    api.FreeIDCard()
                                }
                            } else {
                                // Initialization failed - try to check device anyway
                                status["initErrorCode"] = initRet
                                status["initErrorMessage"] = when (initRet) {
                                    2 -> "Device initialization failed - Check USB connection and permissions"
                                    else -> "Initialization failed with code: $initRet"
                                }
                                
                                // Try to check device even if init failed
                                try {
                                    val deviceOnline = api.CheckDeviceOnlineEx()
                                    val currentDevice = api.GetCurrentDevice()
                                    val deviceType = api.GetDeviceType()
                                    val deviceSN = api.GetDeviceSN()
                                    
                                    status["deviceOnline"] = deviceOnline == 1
                                    status["currentDevice"] = currentDevice ?: "None"
                                    status["deviceType"] = deviceType
                                    status["deviceSN"] = deviceSN ?: "None"
                                    status["hardwareDetected"] = deviceOnline == 1
                                    
                                    if (deviceOnline == 1 || !currentDevice.isNullOrEmpty()) {
                                        status["initErrorMessage"] = "Device detected but initialization failed - Check permissions/license"
                                    } else {
                                        status["hardwareDetected"] = false
                                        if (initRet == 2) {
                                            status["initErrorMessage"] = "Hardware not detected - Check USB connection"
                                        }
                                    }
                                } catch (e: Exception) {
                                    status["deviceOnline"] = false
                                    status["currentDevice"] = "Cannot check (init failed)"
                                    status["hardwareDetected"] = false
                                    status["deviceCheckError"] = e.message ?: "Unknown"
                                }
                            }
                        }
                        
                        Log.d(TAG, "SDK Status: $status")
                        Handler(Looper.getMainLooper()).post {
                            result.success(status)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "checkSDKStatus error", e)
                        postError(result, "STATUS_ERROR", e.message ?: "Unknown error")
                    }
                }.start()
            } else if (call.method == "scanPassport") {
                Thread {
                    var api: IDCardAPI? = null
                    try {
                        Log.d(TAG, "=== Starting Passport Scan ===")
                        
                        api = IDCardAPI()

                        // Copy assets to internal storage
                        val copyUtil = CopyAssetsUtil(this)
                        val kernelPath = copyUtil.copyAssetsToInternal()

                        if (kernelPath == null) {
                            Log.e(TAG, "Failed to copy assets")
                            postError(result, "ASSET_ERROR", "Assets copy failed")
                            return@Thread
                        }

                        Log.d(TAG, "Assets copied to: $kernelPath")

                        // Initialize SDK FIRST (required before device check)
                        Log.d(TAG, "Initializing SDK...")
                        val initRet = api.InitIDCard("", 1, kernelPath)
                        Log.d(TAG, "InitIDCard returned: $initRet")
                        
                        // If initialization fails, try to get more info
                        if (initRet != 0) {
                            Log.e(TAG, "SDK initialization failed with code: $initRet")
                            
                            // Try to check device status even if init failed (some SDKs allow this)
                            try {
                                val deviceOnline = api.CheckDeviceOnlineEx()
                                val currentDevice = api.GetCurrentDevice()
                                val deviceType = api.GetDeviceType()
                                val deviceSN = api.GetDeviceSN()
                                
                                Log.d(TAG, "Device check after failed init:")
                                Log.d(TAG, "  - Device online: $deviceOnline")
                                Log.d(TAG, "  - Current device: $currentDevice")
                                Log.d(TAG, "  - Device type: $deviceType")
                                Log.d(TAG, "  - Device SN: $deviceSN")
                                
                                if (deviceOnline == 1 || !currentDevice.isNullOrEmpty()) {
                                    Log.w(TAG, "⚠️ Device detected but initialization still failed!")
                                    Log.w(TAG, "⚠️ This might indicate:")
                                    Log.w(TAG, "   1. USB/OTG permissions not granted")
                                    Log.w(TAG, "   2. Device driver not loaded")
                                    Log.w(TAG, "   3. Device not properly connected")
                                    Log.w(TAG, "   4. License/authorization issue")
                                }
                            } catch (e: Exception) {
                                Log.w(TAG, "Device check failed: ${e.message}")
                            }
                        } else {
                            // SDK initialized successfully - check device
                            Log.d(TAG, "SDK initialized successfully, checking device...")
                            try {
                                val deviceOnline = api.CheckDeviceOnlineEx()
                                val currentDevice = api.GetCurrentDevice()
                                val deviceType = api.GetDeviceType()
                                val deviceSN = api.GetDeviceSN()
                                
                                Log.d(TAG, "Device Status:")
                                Log.d(TAG, "  - Device online: $deviceOnline")
                                Log.d(TAG, "  - Current device: $currentDevice")
                                Log.d(TAG, "  - Device type: $deviceType")
                                Log.d(TAG, "  - Device SN: $deviceSN")
                                
                                if (deviceOnline == 0) {
                                    Log.w(TAG, "⚠️ Device online check returned 0 (not detected)")
                                    Log.w(TAG, "⚠️ Check:")
                                    Log.w(TAG, "   1. USB/OTG cable connected")
                                    Log.w(TAG, "   2. Scanner powered on")
                                    Log.w(TAG, "   3. USB permissions granted")
                                    Log.w(TAG, "   4. Device drivers installed")
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error checking device: ${e.message}", e)
                            }
                        }

                        if (initRet != 0) {
                            // Build comprehensive diagnostic information
                            val diagnostics = StringBuilder()
                            diagnostics.append("=== SDK DIAGNOSTIC REPORT ===\n\n")
                            
                            // Basic status
                            diagnostics.append("📋 INITIALIZATION STATUS:\n")
                            diagnostics.append("InitIDCard Result: $initRet\n")
                            diagnostics.append("Assets Path: $kernelPath\n")
                            diagnostics.append("Android Version: ${Build.VERSION.SDK_INT} (${Build.VERSION.RELEASE})\n")
                            diagnostics.append("Device Model: ${Build.MODEL}\n")
                            diagnostics.append("Device Manufacturer: ${Build.MANUFACTURER}\n\n")
                            
                            diagnostics.append("📥 INITIDCARD PARAMETERS:\n")
                            diagnostics.append("AuthID: \"\" (empty string)\n")
                            diagnostics.append("Language: 1 (English)\n")
                            diagnostics.append("Kernel Path: $kernelPath\n\n")
                            
                            val configFile = File(kernelPath + "IDCardConfig.ini")
                            diagnostics.append("Config File: ${if (configFile.exists()) "✅ Found" else "❌ Missing"}\n")
                            diagnostics.append("Config Path: ${configFile.absolutePath}\n\n")
                            
                            // Error code explanation
                            diagnostics.append("❌ ERROR CODE: $initRet\n")
                            val errorExplanation = when (initRet) {
                                1 -> "Authorization ID incorrect"
                                2 -> "Device initialization failed"
                                3 -> "Recognition engine init failed"
                                4 -> "Authorization files not found"
                                5 -> "Failed to load templates"
                                6 -> "Chip reader init failed"
                                7 -> "Chinese ID card reader init failed"
                                else -> "Unknown error"
                            }
                            diagnostics.append("Meaning: $errorExplanation\n\n")
                            
                            // Get USB device information
                            val usbDeviceInfo = StringBuilder()
                            try {
                                val usbManager = getSystemService(Context.USB_SERVICE) as? UsbManager
                                if (usbManager != null) {
                                    val deviceList = usbManager.deviceList
                                    if (deviceList.isNotEmpty()) {
                                        usbDeviceInfo.append("📱 USB DEVICE INFORMATION:\n")
                                        usbDeviceInfo.append("Found ${deviceList.size} USB device(s)\n\n")
                                        for ((index, device) in deviceList.values.withIndex()) {
                                            val hasPermission = usbManager.hasPermission(device)
                                            usbDeviceInfo.append("Device ${index + 1}:\n")
                                            usbDeviceInfo.append("  Name: ${device.deviceName}\n")
                                            usbDeviceInfo.append("  VID: 0x${device.vendorId.toString(16).uppercase()} (${device.vendorId})\n")
                                            usbDeviceInfo.append("  PID: 0x${device.productId.toString(16).uppercase()} (${device.productId})\n")
                                            
                                            // Check if it's a known scanner
                                            val vidHex = device.vendorId.toString(16).uppercase().padStart(4, '0')
                                            val pidHex = device.productId.toString(16).uppercase().padStart(4, '0')
                                            when {
                                                device.vendorId == 0x0638 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: SINOSECU Scanner (VID 0638)\n")
                                                    when (device.productId) {
                                                        0x0AD7 -> usbDeviceInfo.append("     Model: AVA5\n")
                                                        0x1A2A -> usbDeviceInfo.append("     Model: AVA5 Plus\n")
                                                        0x2D53 -> usbDeviceInfo.append("     Model: AVA5+\n")
                                                        0x0A7E -> usbDeviceInfo.append("     Model: AVA6\n")
                                                        0x2DE9 -> usbDeviceInfo.append("     Model: AVA6 Plus2\n")
                                                        0x2B14 -> usbDeviceInfo.append("     Model: AW570\n")
                                                        0x1A76 -> usbDeviceInfo.append("     Model: B660\n")
                                                        0x2E2A -> usbDeviceInfo.append("     Model: B660+\n")
                                                        0x2CD0 -> usbDeviceInfo.append("     Model: B6680\n")
                                                        0x2BF3 -> usbDeviceInfo.append("     Model: D120+\n")
                                                        0x0ADA -> usbDeviceInfo.append("     Model: D300+\n")
                                                        0x2BAE -> usbDeviceInfo.append("     Model: L2230\n")
                                                        0x0ADC -> usbDeviceInfo.append("     Model: D800II\n")
                                                        0x2D56 -> usbDeviceInfo.append("     Model: D800II+\n")
                                                        0x0AC0 -> usbDeviceInfo.append("     Model: DSL3100\n")
                                                        0x2C95 -> usbDeviceInfo.append("     Model: DSL62\n")
                                                        0x2BAB -> usbDeviceInfo.append("     Model: E2000\n")
                                                        0x2B59 -> usbDeviceInfo.append("     Model: L1250\n")
                                                        0x2C00 -> usbDeviceInfo.append("     Model: L1250+\n")
                                                        0x2C60 -> usbDeviceInfo.append("     Model: L7280+\n")
                                                        0x2BAF -> usbDeviceInfo.append("     Model: M110\n")
                                                        0x2C55 -> usbDeviceInfo.append("     Model: M1260\n")
                                                        0x2B15 -> usbDeviceInfo.append("     Model: TR582\n")
                                                        0x2CE6 -> usbDeviceInfo.append("     Model: U350II\n")
                                                        else -> usbDeviceInfo.append("     Model: Unknown (PID: 0x$pidHex)\n")
                                                    }
                                                }
                                                device.vendorId == 0x0AC8 && device.productId == 0xC456 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: Scanner CR620+\n")
                                                }
                                                device.vendorId == 0x0828 && device.productId == 0x1002 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: Wintone Passport Reader\n")
                                                    usbDeviceInfo.append("     Type: EZUsbDevice (1st/2nd Gen Camera)\n")
                                                }
                                                device.vendorId == 0x0828 && device.productId == 0x1003 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: Wintone Passport Reader FR\n")
                                                    usbDeviceInfo.append("     Type: EZUsbDevice (1st/2nd Gen Camera)\n")
                                                }
                                                device.vendorId == 0x3150 && device.productId == 0x3320 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: ID Card Reader Camera FH\n")
                                                }
                                                device.vendorId == 0x0816 && device.productId == 0x0555 -> {
                                                    usbDeviceInfo.append("  ✅ RECOGNIZED: KSJ Camera\n")
                                                }
                                                else -> {
                                                    usbDeviceInfo.append("  ⚠️ UNRECOGNIZED DEVICE\n")
                                                }
                                            }
                                            
                                            usbDeviceInfo.append("  Class: ${device.deviceClass}\n")
                                            usbDeviceInfo.append("  Subclass: ${device.deviceSubclass}\n")
                                            usbDeviceInfo.append("  Protocol: ${device.deviceProtocol}\n")
                                            usbDeviceInfo.append("  Permission: ${if (hasPermission) "✅ Granted" else "❌ Not granted"}\n")
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                                usbDeviceInfo.append("  Manufacturer: ${device.manufacturerName ?: "Unknown"}\n")
                                                usbDeviceInfo.append("  Product: ${device.productName ?: "Unknown"}\n")
                                                usbDeviceInfo.append("  Serial: ${device.serialNumber ?: "Unknown"}\n")
                                            }
                                            usbDeviceInfo.append("\n")
                                        }
                                    } else {
                                        usbDeviceInfo.append("📱 USB DEVICE INFORMATION:\n")
                                        usbDeviceInfo.append("❌ No USB devices detected by Android\n")
                                        usbDeviceInfo.append("\nPossible causes:\n")
                                        usbDeviceInfo.append("1. Scanner not powered on\n")
                                        usbDeviceInfo.append("2. USB cable not connected\n")
                                        usbDeviceInfo.append("3. USB OTG/Host mode disabled\n")
                                        usbDeviceInfo.append("4. Scanner needs kernel driver (not detected by Android)\n")
                                        usbDeviceInfo.append("5. Wrong USB port (try different port)\n\n")
                                    }
                                } else {
                                    usbDeviceInfo.append("📱 USB DEVICE INFORMATION:\n")
                                    usbDeviceInfo.append("❌ USB service not available\n\n")
                                }
                            } catch (e: Exception) {
                                usbDeviceInfo.append("📱 USB DEVICE INFORMATION:\n")
                                usbDeviceInfo.append("❌ Error: ${e.message}\n\n")
                            }
                            
                            // Try to get SDK device information even if init failed
                            var deviceOnline = -1
                            var currentDevice = "Unknown"
                            var deviceType = -1
                            var deviceSN = "Unknown"
                            
                            try {
                                deviceOnline = api.CheckDeviceOnlineEx()
                                currentDevice = api.GetCurrentDevice() ?: "None"
                                deviceType = api.GetDeviceType()
                                deviceSN = api.GetDeviceSN() ?: "None"
                            } catch (e: Exception) {
                                currentDevice = "Error: ${e.message}"
                            }
                            
                            // Add USB device info to diagnostics
                            diagnostics.append(usbDeviceInfo.toString())
                            
                            // SDK Device status
                            diagnostics.append("🔌 SDK DEVICE STATUS:\n")
                            diagnostics.append("Device Online: ${if (deviceOnline == 1) "✅ YES" else "❌ NO ($deviceOnline)"}\n")
                            diagnostics.append("Current Device: $currentDevice\n")
                            diagnostics.append("Device Type: $deviceType\n")
                            diagnostics.append("Device SN: $deviceSN\n\n")
                            
                            // Recommendations based on error code and device type
                            diagnostics.append("💡 RECOMMENDATIONS:\n")
                            when (initRet) {
                                2 -> {
                                    // Check if we have Wintone device detected
                                    try {
                                        val usbManager = getSystemService(Context.USB_SERVICE) as? UsbManager
                                        val deviceList = usbManager?.deviceList
                                        val hasWintone = deviceList?.values?.any { 
                                            it.vendorId == 0x0828 && (it.productId == 0x1002 || it.productId == 0x1003)
                                        } ?: false
                                        
                                        if (hasWintone) {
                                            diagnostics.append("✅ Wintone device DETECTED (VID:0x828, PID:0x1002)\n")
                                            diagnostics.append("⚠️ But InitIDCard failed with error code 2\n\n")
                                            
                                            // Check USB permissions
                                            diagnostics.append("1️⃣ USB PERMISSIONS CHECK:\n")
                                            val wintoneDevice = deviceList?.values?.find { 
                                                it.vendorId == 0x0828 && it.productId == 0x1002 
                                            }
                                            if (wintoneDevice != null) {
                                                val hasPermission = usbManager?.hasPermission(wintoneDevice) ?: false
                                                if (hasPermission) {
                                                    diagnostics.append("   ✅ App USB Permission: GRANTED\n")
                                                } else {
                                                    diagnostics.append("   ❌ App USB Permission: NOT GRANTED\n")
                                                    diagnostics.append("   → ACTION: Grant USB permission when prompted\n")
                                                    diagnostics.append("   → Or manually grant in Settings → Apps → Permissions\n")
                                                }
                                            } else {
                                                diagnostics.append("   ⚠️ Wintone device not in USB device list\n")
                                            }
                                            
                                            // Check USB folder permissions (critical for Wintone)
                                            val usbFolder = File("/dev/bus/usb")
                                            if (usbFolder.exists()) {
                                                if (usbFolder.canRead()) {
                                                    diagnostics.append("   ✅ /dev/bus/usb: Readable\n")
                                                } else {
                                                    diagnostics.append("   ❌ /dev/bus/usb: NOT readable\n")
                                                    diagnostics.append("   → CRITICAL: Wintone needs chmod 777 /dev/bus/usb/\n")
                                                    diagnostics.append("   → Kiosk may need root or system app permissions\n")
                                                }
                                            } else {
                                                diagnostics.append("   ❌ /dev/bus/usb: Folder not found\n")
                                            }
                                            diagnostics.append("\n")
                                            
                                            // Check device driver
                                            diagnostics.append("2️⃣ DEVICE DRIVER CHECK:\n")
                                            diagnostics.append("   SDK Device Type: $deviceType\n")
                                            if (deviceType == 1) {
                                                diagnostics.append("   ✅ SDK recognizes device (Type=1)\n")
                                                diagnostics.append("   → Driver loaded but device init failed\n")
                                            } else if (deviceType == -1 || deviceType == 0) {
                                                diagnostics.append("   ❌ SDK does not recognize device\n")
                                                diagnostics.append("   → ACTION: Device driver may not be loaded\n")
                                                diagnostics.append("   → Check if .so libraries are correct architecture\n")
                                            }
                                            diagnostics.append("\n")
                                            
                                            // Check license
                                            diagnostics.append("3️⃣ LICENSE/AUTHORIZATION CHECK:\n")
                                            val licFile = File(kernelPath + "IDCardLicense.dat")
                                            val deviceDatFile = File(kernelPath + "IDCardDevice.dat")
                                            if (licFile.exists()) {
                                                diagnostics.append("   ✅ IDCardLicense.dat: Found (${licFile.length()} bytes)\n")
                                                // Check if license file is too small (likely invalid)
                                                if (licFile.length() < 100) {
                                                    diagnostics.append("   ⚠️ License file seems too small!\n")
                                                    diagnostics.append("   → ACTION: Verify license file is valid\n")
                                                }
                                            } else {
                                                diagnostics.append("   ❌ IDCardLicense.dat: MISSING\n")
                                                diagnostics.append("   → ACTION: Copy valid license file to assets\n")
                                            }
                                            
                                            if (deviceDatFile.exists()) {
                                                diagnostics.append("   ✅ IDCardDevice.dat: Found (${deviceDatFile.length()} bytes)\n")
                                            } else {
                                                diagnostics.append("   ❌ IDCardDevice.dat: MISSING\n")
                                                diagnostics.append("   → ACTION: Copy device config file to assets\n")
                                            }
                                            diagnostics.append("\n")
                                            
                                            // Check device initialization
                                            diagnostics.append("4️⃣ DEVICE INITIALIZATION CHECK:\n")
                                            diagnostics.append("   Current Device Name: ${if (currentDevice.isEmpty()) "EMPTY" else currentDevice}\n")
                                            diagnostics.append("   Device SN: ${if (deviceSN.isEmpty()) "EMPTY" else deviceSN}\n")
                                            diagnostics.append("   Device Online Status: $deviceOnline\n")
                                            
                                            if (currentDevice.isEmpty() && deviceSN.isEmpty()) {
                                                diagnostics.append("   ❌ Device not properly initialized\n")
                                                diagnostics.append("   → ACTION: Try these steps:\n")
                                                diagnostics.append("      a) Unplug device, wait 5 sec, plug back in\n")
                                                diagnostics.append("      b) Restart the app\n")
                                                diagnostics.append("      c) Check if another app is using the device\n")
                                                diagnostics.append("      d) Power cycle the scanner device\n")
                                            } else {
                                                diagnostics.append("   ⚠️ Device partially initialized but can't fully connect\n")
                                                diagnostics.append("   → May indicate hardware communication issue\n")
                                            }
                                            diagnostics.append("\n")
                                            
                                            diagnostics.append("⚡ WINTONE SPECIFIC NOTES:\n")
                                            diagnostics.append("   • EZUsbDevice type (1st/2nd Gen Camera)\n")
                                            diagnostics.append("   • May require firmware initialization sequence\n")
                                            diagnostics.append("   • Check IDCardConfig.ini has Wintone settings\n")
                                            diagnostics.append("   • Verify Android 12 compatibility\n")
                                        } else if (deviceOnline == 1 || (currentDevice != "None" && currentDevice != "Unknown" && deviceType == 1)) {
                                            diagnostics.append("⚠️ Device DETECTED by SDK but init failed!\n")
                                            diagnostics.append("SDK reports Device Type: $deviceType\n")
                                            diagnostics.append("But Android USB shows: No devices\n\n")
                                            diagnostics.append("Possible causes:\n")
                                            diagnostics.append("1. Device uses kernel driver (bypasses Android USB)\n")
                                            diagnostics.append("2. USB permissions not granted at OS level\n")
                                            diagnostics.append("3. License/authorization file mismatch\n")
                                            diagnostics.append("4. Device needs firmware initialization\n")
                                        } else {
                                            diagnostics.append("⚠️ Device NOT detected\n")
                                            diagnostics.append("Check:\n")
                                            diagnostics.append("1. USB/OTG cable connected?\n")
                                            diagnostics.append("2. Scanner powered on?\n")
                                            diagnostics.append("3. USB host mode enabled?\n")
                                            diagnostics.append("4. USB permissions granted?\n")
                                            diagnostics.append("5. Correct USB port (try different port)?\n")
                                        }
                                    } catch (e: Exception) {
                                        diagnostics.append("⚠️ Error checking device details: ${e.message}\n")
                                    }
                                }
                                4 -> {
                                    diagnostics.append("Check license files:\n")
                                    val licenseFile = File(kernelPath + "IDCardLicense.dat")
                                    diagnostics.append("License file: ${if (licenseFile.exists()) "✅ Found" else "❌ Missing"}\n")
                                }
                                5 -> {
                                    diagnostics.append("Check model files in assets folder\n")
                                    diagnostics.append("Assets path: $kernelPath\n")
                                }
                                else -> {
                                    diagnostics.append("Check SDK documentation for error code: $initRet\n")
                                }
                            }
                            
                            diagnostics.append("\n📁 FILES STATUS:\n")
                            diagnostics.append("Assets copied: ✅\n")
                            diagnostics.append("Config exists: ${if (configFile.exists()) "✅" else "❌"}\n")
                            
                            val licenseFile = File(kernelPath + "IDCardLicense.dat")
                            diagnostics.append("License exists: ${if (licenseFile.exists()) "✅" else "❌"}\n")
                            if (licenseFile.exists()) {
                                diagnostics.append("License size: ${licenseFile.length()} bytes\n")
                            }
                            
                            val deviceFile = File(kernelPath + "IDCardDevice.dat")
                            diagnostics.append("Device file exists: ${if (deviceFile.exists()) "✅" else "❌"}\n")
                            if (deviceFile.exists()) {
                                diagnostics.append("Device file size: ${deviceFile.length()} bytes\n")
                            }
                            
                            // Check for HardWareID.xml
                            val hardwareIdFile = File(kernelPath + "HardWareID.xml")
                            diagnostics.append("HardWareID.xml: ${if (hardwareIdFile.exists()) "✅" else "❌"}\n")
                            
                            // Count model files
                            try {
                                val kernelDir = File(kernelPath)
                                val modelFiles = kernelDir.listFiles()?.size ?: 0
                                diagnostics.append("Total files in kernel: $modelFiles\n")
                            } catch (e: Exception) {
                                diagnostics.append("Could not count files: ${e.message}\n")
                            }
                            
                            val fullDiagnostic = diagnostics.toString()
                            Log.e(TAG, fullDiagnostic)
                            
                            // Return comprehensive error with all diagnostics
                            val diagnosticData = hashMapOf<String, Any>(
                                "errorCode" to initRet.toString(),
                                "errorExplanation" to errorExplanation,
                                "deviceOnline" to deviceOnline,
                                "currentDevice" to currentDevice,
                                "deviceType" to deviceType.toString(),
                                "deviceSN" to deviceSN,
                                "assetsPath" to kernelPath,
                                "configExists" to configFile.exists().toString(),
                                "fullDiagnostic" to fullDiagnostic
                            )
                            
                            Handler(Looper.getMainLooper()).post {
                                result.error("INIT_FAIL_DETAILED", fullDiagnostic, diagnosticData)
                            }
                            return@Thread
                        }

                        // Load configuration
                        val configFile = File(kernelPath + "IDCardConfig.ini")
                        if (configFile.exists()) {
                            api.SetConfigByFile(configFile.absolutePath)
                            Log.d(TAG, "Config file loaded: ${configFile.absolutePath}")
                        } else {
                            Log.w(TAG, "Config file not found: ${configFile.absolutePath}")
                        }

                        // Set language to English (1 = English, 0 = Chinese)
                        api.SetLanguage(1)
                        
                        // CRITICAL: Check device status before detection (from working APK)
                        // This handles device state issues that prevent detection
                        Log.d(TAG, "Checking device status before detection...")
                        val deviceCheckStatus = api.CheckDeviceOnlineEx()
                        Log.d(TAG, "CheckDeviceOnlineEx returned: $deviceCheckStatus")
                        
                        when (deviceCheckStatus) {
                            2 -> {
                                // Device disconnected - need to free and reinit
                                Log.w(TAG, "Device status = 2 (disconnected), reinitializing...")
                                api.FreeIDCard()
                                postError(result, "DEVICE_DISCONNECTED", "Device disconnected. Please reconnect and try again.")
                                return@Thread
                            }
                            3 -> {
                                // Device needs reinitialization
                                Log.w(TAG, "Device status = 3 (needs reinit), reinitializing...")
                                api.FreeIDCard()
                                val reinitRet = api.InitIDCard("", 1, kernelPath)
                                if (reinitRet != 0) {
                                    postError(result, "REINIT_FAIL", "Device reinitialization failed: $reinitRet")
                                    return@Thread
                                }
                                // Reload config after reinit
                                val configFile = File(kernelPath + "IDCardConfig.ini")
                                if (configFile.exists()) {
                                    api.SetConfigByFile(configFile.absolutePath)
                                }
                                api.SetIOStatus(5, 1)
                                Log.d(TAG, "Device reinitialized successfully")
                            }
                            1 -> {
                                Log.d(TAG, "Device status OK (1)")
                            }
                            else -> {
                                Log.w(TAG, "Unexpected device status: $deviceCheckStatus")
                            }
                        }
                        
                        // CRITICAL: Set IO status to enable scanner (Wintone requirement)
                        // SetIOStatus(5, 1) turns on indicator light and enables detection
                        // This is required before DetectDocument() for Wintone devices
                        Log.d(TAG, "Setting IO status (indicator light)...")
                        try {
                            val ioRet = api.SetIOStatus(5, 1)
                            Log.d(TAG, "SetIOStatus(5, 1) returned: $ioRet")
                            if (ioRet != 0) {
                                Log.w(TAG, "⚠️ SetIOStatus failed, but continuing...")
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "⚠️ SetIOStatus not supported or failed: ${e.message}")
                        }

                        // Detect document
                        Log.d(TAG, "=== Document Detection Phase ===")
                        
                        // CRITICAL: TH-AR190 (Device Type 16) is a FEEDER scanner
                        // It may not support DetectDocument() or may need document fed first
                        // Try AutoProcessIDCard directly for feeder-type scanners
                        val deviceTypeCheck = api.GetDeviceType()
                        val currentDeviceCheck = api.GetCurrentDevice()
                        
                        Log.d(TAG, "Device Type: $deviceTypeCheck, Device Name: $currentDeviceCheck")
                        
                        // For TH-AR190 (Device Type 16) feeder scanner, we skip DetectDocument
                        // and proceed directly to AutoProcessIDCard
                        var skipDetection = false
                        if (deviceTypeCheck == 16 || currentDeviceCheck.contains("TH-AR", ignoreCase = true)) {
                            Log.d(TAG, "⚠️ Detected FEEDER-TYPE scanner ($currentDeviceCheck)")
                            Log.d(TAG, "⚠️ Skipping DetectDocument(), proceeding directly to AutoProcessIDCard")
                            Log.d(TAG, "⚠️ USER MUST INSERT DOCUMENT INTO FEEDER BEFORE PRESSING SCAN!")
                            skipDetection = true
                        }
                        
                        if (!skipDetection) {
                            // For camera-based scanners, use DetectDocument first
                            Log.d(TAG, "Calling DetectDocument() for camera-based scanner...")
                            val detect = api.DetectDocument()
                            Log.d(TAG, "DetectDocument returned: $detect")

                            if (detect != 1) {
                            // Build detailed diagnostic for detection failure
                            val detectionDiagnostics = StringBuilder()
                            detectionDiagnostics.append("=== DOCUMENT DETECTION FAILED ===\n\n")
                            
                            detectionDiagnostics.append("📋 DETECTION STATUS:\n")
                            detectionDiagnostics.append("DetectDocument() returned: $detect\n")
                            val detectExplanation = when (detect) {
                                0 -> "No document detected (scanner sees nothing)"
                                -1 -> "Document detection error (SDK/hardware issue)"
                                -2 -> "Device not ready or busy"
                                -3 -> "Detection timeout"
                                else -> "Unknown detection result"
                            }
                            detectionDiagnostics.append("Meaning: $detectExplanation\n")
                            detectionDiagnostics.append("\nReturn Value Guide:\n")
                            detectionDiagnostics.append("  1 = Document detected (success)\n")
                            detectionDiagnostics.append("  0 = No document in scanner view\n")
                            detectionDiagnostics.append(" -1 = Detection error\n")
                            detectionDiagnostics.append(" -2 = Device not ready\n")
                            detectionDiagnostics.append(" -3 = Detection timeout\n\n")
                            
                            // Device information
                            detectionDiagnostics.append("🔌 DEVICE INFORMATION:\n")
                            try {
                                val deviceOnline = api.CheckDeviceOnlineEx()
                                val currentDevice = api.GetCurrentDevice()
                                val deviceType = api.GetDeviceType()
                                val deviceSN = api.GetDeviceSN()
                                
                                detectionDiagnostics.append("Device Online: ${if (deviceOnline == 1) "✅ YES (1)" else "⚠️ $deviceOnline"}\n")
                                detectionDiagnostics.append("Current Device: ${currentDevice ?: "None"}\n")
                                detectionDiagnostics.append("Device Type: $deviceType\n")
                                detectionDiagnostics.append("Device SN: ${deviceSN ?: "None"}\n")
                                
                                // Add interpretation
                                if (deviceOnline != 1) {
                                    detectionDiagnostics.append("\n⚠️ WARNING: Device online status is $deviceOnline (expected 1)\n")
                                    detectionDiagnostics.append("This may indicate device disconnected or busy\n")
                                }
                                detectionDiagnostics.append("\n")
                            } catch (e: Exception) {
                                detectionDiagnostics.append("Error checking device: ${e.message}\n\n")
                            }
                            
                            // Check for Wintone-specific instructions
                            try {
                                val usbManager = getSystemService(Context.USB_SERVICE) as? UsbManager
                                val deviceList = usbManager?.deviceList
                                val hasWintone = deviceList?.values?.any { 
                                    it.vendorId == 0x0828 && (it.productId == 0x1002 || it.productId == 0x1010)
                                } ?: false
                                
                                if (hasWintone) {
                                    detectionDiagnostics.append("📱 WINTONE DEVICE STATUS:\n")
                                    detectionDiagnostics.append("✅ Hardware: Detected (VID:0x828, PID:0x1002)\n")
                                    detectionDiagnostics.append("✅ SDK Init: Success (InitIDCard = 0)\n")
                                    detectionDiagnostics.append("✅ IO Status: Set (SetIOStatus called)\n")
                                    detectionDiagnostics.append("❌ Detection: Failed (DetectDocument = $detect)\n\n")
                                    
                                    // Specific advice based on return value
                                    when (detect) {
                                        0 -> {
                                            detectionDiagnostics.append("💡 DETECTION RETURNED 0 (NO DOCUMENT):\n")
                                            detectionDiagnostics.append("The scanner hardware is working but sees NO document.\n")
                                            detectionDiagnostics.append("This is the most common issue with Wintone scanners.\n\n")
                                            
                                            detectionDiagnostics.append("⚠️ MOST COMMON CAUSES:\n\n")
                                            
                                            detectionDiagnostics.append("1️⃣ DOCUMENT NOT IN CAMERA VIEW (90% of cases)\n")
                                            detectionDiagnostics.append("   → Wintone uses CAMERA, not feeder\n")
                                            detectionDiagnostics.append("   → Document MUST be within camera frame\n")
                                            detectionDiagnostics.append("   → Check if camera has LED indicator/light\n\n")
                                            
                                            detectionDiagnostics.append("2️⃣ SCANNER NOT TRIGGERED\n")
                                            detectionDiagnostics.append("   → Some Wintone models need button press\n")
                                            detectionDiagnostics.append("   → Check for physical scan button\n")
                                            detectionDiagnostics.append("   → Try pressing button BEFORE placing doc\n\n")
                                            
                                            detectionDiagnostics.append("3️⃣ LIGHTING/FOCUS ISSUE\n")
                                            detectionDiagnostics.append("   → Camera may need 2-3 sec to focus\n")
                                            detectionDiagnostics.append("   → Room lighting may be too dark/bright\n")
                                            detectionDiagnostics.append("   → Check if scanner has built-in light source\n\n")
                                            
                                            detectionDiagnostics.append("4️⃣ CONTINUOUS DETECTION MODE\n")
                                            detectionDiagnostics.append("   → DetectDocument() may need to be called\n")
                                            detectionDiagnostics.append("     in a loop until document appears\n")
                                            detectionDiagnostics.append("   → Official sample may use polling loop\n\n")
                                            
                                            detectionDiagnostics.append("🔧 IMMEDIATE ACTIONS TO TRY:\n")
                                            detectionDiagnostics.append("1. Press any physical button on scanner\n")
                                            detectionDiagnostics.append("2. Place ID card FLAT on scanner surface\n")
                                            detectionDiagnostics.append("3. Ensure scanner light/LED is ON\n")
                                            detectionDiagnostics.append("4. Wait 3-5 seconds, press Scan again\n")
                                            detectionDiagnostics.append("5. Try different document position\n")
                                            detectionDiagnostics.append("6. Check if scanner has \"ready\" indicator\n\n")
                                            
                                            detectionDiagnostics.append("📸 CAMERA-BASED SCANNER NOTES:\n")
                                            detectionDiagnostics.append("• Wintone is camera-based (not feeder)\n")
                                            detectionDiagnostics.append("• Document must be visible to camera lens\n")
                                            detectionDiagnostics.append("• May need manual trigger (button/software)\n")
                                            detectionDiagnostics.append("• DetectDocument() checks camera feed\n")
                                            detectionDiagnostics.append("• Returns 0 if camera sees blank/no document\n\n")
                                        }
                                        -1 -> {
                                            detectionDiagnostics.append("💡 DETECTION RETURNED -1:\n")
                                            detectionDiagnostics.append("This indicates a hardware or SDK error.\n\n")
                                            detectionDiagnostics.append("TROUBLESHOOTING:\n")
                                            detectionDiagnostics.append("1. Check device logs for hardware errors\n")
                                            detectionDiagnostics.append("2. Scanner may need power cycle\n")
                                            detectionDiagnostics.append("3. Camera may be blocked or damaged\n")
                                            detectionDiagnostics.append("4. Check USB connection is secure\n\n")
                                        }
                                        -2 -> {
                                            detectionDiagnostics.append("💡 DETECTION RETURNED -2:\n")
                                            detectionDiagnostics.append("Device is busy or not ready.\n\n")
                                            detectionDiagnostics.append("ACTIONS:\n")
                                            detectionDiagnostics.append("1. Wait 5 seconds and try again\n")
                                            detectionDiagnostics.append("2. Scanner may still be initializing\n")
                                            detectionDiagnostics.append("3. Check if another app is using scanner\n\n")
                                        }
                                        else -> {
                                            detectionDiagnostics.append("💡 UNKNOWN RETURN VALUE: $detect\n")
                                            detectionDiagnostics.append("Check SDK documentation for this value.\n\n")
                                        }
                                    }
                                    
                                    detectionDiagnostics.append("💡 POSSIBLE CAUSES:\n")
                                    detectionDiagnostics.append("1. No document (ID/Passport) placed on scanner\n")
                                    detectionDiagnostics.append("2. Document not in scanner's view area\n")
                                    detectionDiagnostics.append("3. Document not flat or aligned correctly\n")
                                    detectionDiagnostics.append("4. Scanner lid not closed (if required)\n")
                                    detectionDiagnostics.append("5. Lighting conditions not optimal\n")
                                    detectionDiagnostics.append("6. Scanner camera may need warm-up time\n")
                                    detectionDiagnostics.append("7. Document type not recognized (ID vs Passport)\n\n")
                                    
                                    detectionDiagnostics.append("🔧 TROUBLESHOOTING STEPS:\n")
                                    detectionDiagnostics.append("• Place ID card or passport on scanner platform\n")
                                    detectionDiagnostics.append("• For ID: Place photo-side facing up\n")
                                    detectionDiagnostics.append("• For Passport: Place photo-page facing up\n")
                                    detectionDiagnostics.append("• Align document with guide marks (if any)\n")
                                    detectionDiagnostics.append("• Check indicator light is on/green\n")
                                    detectionDiagnostics.append("• Wait 2-3 seconds after placing document\n")
                                    detectionDiagnostics.append("• Ensure document is fully within scanner area\n")
                                    detectionDiagnostics.append("• Try pressing scan button (if hardware has one)\n\n")
                                    
                                    detectionDiagnostics.append("⚡ WINTONE CAMERA NOTES:\n")
                                    detectionDiagnostics.append("• Camera-based scanner (not document feeder)\n")
                                    detectionDiagnostics.append("• Document must be visible to camera\n")
                                    detectionDiagnostics.append("• Supports both ID cards and passports\n")
                                    detectionDiagnostics.append("• DetectDocument() checks for any document\n")
                                    detectionDiagnostics.append("• SetIOStatus(5,1) enables detection mode\n\n")
                                    
                                    detectionDiagnostics.append("📋 TEST CHECKLIST:\n")
                                    detectionDiagnostics.append("□ Document is on scanner surface\n")
                                    detectionDiagnostics.append("□ Document is face-up (photo visible)\n")
                                    detectionDiagnostics.append("□ Scanner light/indicator is on\n")
                                    detectionDiagnostics.append("□ Waited 2-3 seconds after placing\n")
                                    detectionDiagnostics.append("□ Document is not bent or damaged\n")
                                } else {
                                    detectionDiagnostics.append("💡 INSTRUCTIONS:\n")
                                    detectionDiagnostics.append("• Place passport on scanner\n")
                                    detectionDiagnostics.append("• Ensure document is properly aligned\n")
                                    detectionDiagnostics.append("• Check scanner is ready\n")
                                }
                            } catch (e: Exception) {
                                detectionDiagnostics.append("Error checking device type: ${e.message}\n")
                            }
                            
                            detectionDiagnostics.append("\n📊 SDK CONFIGURATION:\n")
                            detectionDiagnostics.append("Config loaded: ${configFile.exists()}\n")
                            detectionDiagnostics.append("Language: English (1)\n")
                            detectionDiagnostics.append("Kernel Path: $kernelPath\n")
                            
                            val fullDetectionDiagnostic = detectionDiagnostics.toString()
                            Log.e(TAG, fullDetectionDiagnostic)
                            
                            // Return detailed detection error
                            Handler(Looper.getMainLooper()).post {
                                result.error("NO_DOC_DETAILED", fullDetectionDiagnostic, hashMapOf(
                                    "detectResult" to detect,
                                    "detectExplanation" to detectExplanation
                                ))
                            }
                            api.FreeIDCard()
                            return@Thread
                        }
                        } else {
                            Log.d(TAG, "Feeder-type scanner detected - skipping DetectDocument check")
                        }

                        // Try AutoProcessIDCard first (best for kiosk - auto-detects passport type)
                        Log.d(TAG, "Attempting auto recognition...")
                        val cardType = intArrayOf(-1)
                        var recog = api.AutoProcessIDCard(cardType)
                        Log.d(TAG, "AutoProcessIDCard returned: $recog, CardType: ${cardType[0]}")

                        // If auto-process fails, try MRZ recognition (for passports with MRZ)
                        if (recog <= 0) {
                            Log.d(TAG, "Auto recognition failed, trying MRZ recognition...")
                            // nVIZ = 1 (recognize VIZ), nSaveImageType = 8 (save document image)
                            recog = api.RecogGeneralMRZCard(1, 8)
                            Log.d(TAG, "RecogGeneralMRZCard returned: $recog")
                        }

                        // If MRZ fails, try chip card recognition (for e-passports)
                        if (recog <= 0) {
                            Log.d(TAG, "MRZ recognition failed, trying chip card recognition...")
                            // nDataGroup = 0 (read all), nVIZ = 1, nSaveImageType = 8
                            recog = api.RecogChipCard(0, 1, 8)
                            Log.d(TAG, "RecogChipCard returned: $recog")
                        }

                        if (recog <= 0) {
                            val errorMsg = when (recog) {
                                0 -> "Recognition failed - Unable to read passport"
                                -1 -> "Recognition error occurred"
                                else -> "Recognition failed with code: $recog"
                            }
                            Log.e(TAG, errorMsg)
                            postError(result, "RECOG_FAIL", errorMsg)
                            api.FreeIDCard()
                            return@Thread
                        }

                        Log.d(TAG, "Recognition successful! Reading fields...")

                        // Get scanned document image as base64
                        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        Log.d(TAG, "📸 IMAGE CAPTURE PROCESS STARTING")
                        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        
                        var imageBase64 = ""
                        try {
                            // Try only type 3 (VIZ area) - most reliable for feeder scanners
                            val imageType = 3
                            val typeName = "VIZ area"
                            
                            Log.d(TAG, "Files directory: ${filesDir}")
                            Log.d(TAG, "Files directory exists: ${filesDir.exists()}")
                            Log.d(TAG, "Files directory writable: ${filesDir.canWrite()}")
                            
                            Log.d(TAG, "")
                            Log.d(TAG, "🔍 Attempting Image Type $imageType: $typeName")
                            
                            val tempPath = "${filesDir}/temp_scan_${imageType}.jpg"
                            Log.d(TAG, "Target path: $tempPath")
                            
                            val saveResult = api.SaveImageEx(tempPath, imageType)
                            Log.d(TAG, "SaveImageEx returned: $saveResult")
                            
                            // Log what each error code means
                            when (saveResult) {
                                0 -> Log.d(TAG, "✅ SaveImageEx SUCCESS")
                                -1 -> Log.e(TAG, "❌ SaveImageEx ERROR: Invalid parameter")
                                -2 -> Log.e(TAG, "❌ SaveImageEx ERROR: No image in memory")
                                -3 -> Log.e(TAG, "❌ SaveImageEx ERROR: Image processing failed")
                                -4 -> Log.e(TAG, "❌ SaveImageEx ERROR: File write failed (permissions/path issue)")
                                else -> Log.e(TAG, "❌ SaveImageEx ERROR: Unknown error code $saveResult")
                            }
                            
                            if (saveResult == 0) {
                                val imageFile = File(tempPath)
                                Log.d(TAG, "Checking saved file...")
                                Log.d(TAG, "File exists: ${imageFile.exists()}")
                                
                                if (imageFile.exists()) {
                                    Log.d(TAG, "File size: ${imageFile.length()} bytes")
                                    Log.d(TAG, "File readable: ${imageFile.canRead()}")
                                    
                                    if (imageFile.length() > 0) {
                                        val imageBytes = imageFile.readBytes()
                                        imageBase64 = android.util.Base64.encodeToString(imageBytes, android.util.Base64.NO_WRAP)
                                        
                                        Log.d(TAG, "✅✅✅ IMAGE CAPTURED SUCCESSFULLY! ✅✅✅")
                                        Log.d(TAG, "Image type: $imageType ($typeName)")
                                        Log.d(TAG, "Image bytes: ${imageBytes.size}")
                                        Log.d(TAG, "Base64 length: ${imageBase64.length} chars")
                                        
                                        Log.d(TAG, "")
                                        Log.d(TAG, "🔥🔥🔥 FULL BASE64 STRING BELOW 🔥🔥🔥")
                                        Log.d(TAG, "════════════════════════════════════════════════════════════")
                                        Log.d(TAG, imageBase64)
                                        Log.d(TAG, "════════════════════════════════════════════════════════════")
                                        Log.d(TAG, "🔥🔥🔥 END OF BASE64 STRING 🔥🔥🔥")
                                        Log.d(TAG, "")
                                        
                                        imageFile.delete() // Clean up temp file
                                        Log.d(TAG, "Temp file deleted: $tempPath")
                                    } else {
                                        Log.w(TAG, "⚠️ File is empty (0 bytes)")
                                    }
                                } else {
                                    Log.w(TAG, "⚠️ File was not created at: $tempPath")
                                }
                            } else {
                                Log.e(TAG, "❌ Failed to save image type $imageType")
                            }
                            
                            Log.d(TAG, "")
                            Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            if (imageBase64.isEmpty()) {
                                Log.e(TAG, "❌❌❌ FAILED TO CAPTURE IMAGE ❌❌❌")
                                Log.e(TAG, "Image type 3 (VIZ area) failed. This could mean:")
                                Log.e(TAG, "1. SDK doesn't have image in memory after recognition")
                                Log.e(TAG, "2. File write permissions issue")
                                Log.e(TAG, "3. TH-AR190 doesn't support image capture for this type")
                            } else {
                                Log.d(TAG, "✅✅✅ IMAGE READY FOR FLUTTER ✅✅✅")
                                Log.d(TAG, "Base64 string length: ${imageBase64.length} characters")
                            }
                            Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                            
                        } catch (e: Exception) {
                            Log.e(TAG, "❌ EXCEPTION during image capture: ${e.message}", e)
                            e.printStackTrace()
                        }
                        
                        // Read all fields from SDK
                        val allFields = HashMap<String, String>()
                        val passportData = HashMap<String, String>()

                        // Read up to 100 fields (passports can have many fields)
                        for (i in 0..100) {
                            val fieldName = api.GetFieldName(i)
                            if (fieldName.isNullOrEmpty()) break
                            
                            val fieldValue = api.GetRecogResult(i)
                            if (!fieldValue.isNullOrEmpty()) {
                                allFields[fieldName] = fieldValue
                                Log.d(TAG, "Field[$i]: $fieldName = $fieldValue")
                            }
                        }

                        // Map common passport fields (case-insensitive matching)
                        passportData["passportNumber"] = findField(allFields, listOf(
                            "Passport Number", "Document Number", "Doc Number", 
                            "ID Number", "Number", "Passport No", "MRZ1"
                        ))
                        
                        passportData["fullName"] = findField(allFields, listOf(
                            "Name", "Full Name", "Surname", "Given Name", 
                            "First Name", "Last Name", "English Name", "Name in English"
                        ))
                        
                        passportData["nationality"] = findField(allFields, listOf(
                            "Nationality", "Nationality Code", "Country Code",
                            "Holder Nationality Code", "Nationality in English"
                        ))
                        
                        passportData["dateOfBirth"] = findField(allFields, listOf(
                            "Date of Birth", "Birth Date", "DOB", "Birthday"
                        ))
                        
                        passportData["expiryDate"] = findField(allFields, listOf(
                            "Date of Expiry", "Expiry Date", "Date of Expiration",
                            "Expiration Date", "Valid Until"
                        ))
                        
                        passportData["dateOfIssue"] = findField(allFields, listOf(
                            "Date of Issue", "Issue Date", "Date Issued"
                        ))
                        
                        passportData["sex"] = findField(allFields, listOf(
                            "Sex", "Gender"
                        ))
                        
                        passportData["placeOfBirth"] = findField(allFields, listOf(
                            "Place of Birth", "Birth Place"
                        ))

                        // Include all raw fields for debugging
                        passportData["_allFields"] = allFields.toString()
                        passportData["_cardType"] = cardType[0].toString()
                        passportData["_documentName"] = api.GetIDCardName() ?: ""
                        
                        // Add scanned image as base64
                        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                        Log.d(TAG, "📦 ADDING IMAGE TO PASSPORT DATA")
                        if (imageBase64.isNotEmpty()) {
                            passportData["imageBase64"] = imageBase64
                            Log.d(TAG, "✅✅✅ Document image ADDED to passportData map!")
                            Log.d(TAG, "Key: 'imageBase64'")
                            Log.d(TAG, "Base64 length: ${imageBase64.length} characters")
                            Log.d(TAG, "First 100 chars: ${imageBase64.take(100)}")
                        } else {
                            Log.e(TAG, "❌❌❌ NO IMAGE TO ADD - imageBase64 is empty!")
                            Log.e(TAG, "Flutter will NOT receive any image data")
                        }
                        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

                        Log.d(TAG, "=== Passport Scan Complete ===")
                        Log.d(TAG, "Passport Data keys: ${passportData.keys}")
                        Log.d(TAG, "Has imageBase64: ${passportData.containsKey("imageBase64")}")

                        Handler(Looper.getMainLooper()).post {
                            result.success(passportData)
                        }

                        // Clean up
                        api.FreeIDCard()

                    } catch (e: Exception) {
                        Log.e(TAG, "Exception during scan", e)
                        postError(result, "EXCEPTION", e.message ?: "Unknown error: ${e.javaClass.simpleName}")
                        api?.FreeIDCard()
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Find field value by trying multiple possible field names (case-insensitive)
     */
    private fun findField(fields: HashMap<String, String>, possibleNames: List<String>): String {
        for (name in possibleNames) {
            for ((key, value) in fields) {
                if (key.equals(name, ignoreCase = true)) {
                    return value
                }
            }
        }
        return ""
    }

    private fun postError(
        result: MethodChannel.Result,
        code: String,
        message: String
    ) {
        Handler(Looper.getMainLooper()).post {
            result.error(code, message, null)
        }
    }
}
