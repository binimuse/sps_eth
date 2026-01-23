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
                return
            }
            
            for (device in deviceList.values) {
                val hasPermission = usbManager.hasPermission(device)
                Log.d(TAG, "Device: ${device.deviceName}")
                Log.d(TAG, "  VID: ${device.vendorId}, PID: ${device.productId}")
                Log.d(TAG, "  Has Permission: $hasPermission")
                
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
                                        for ((index, device) in deviceList.values.withIndex()) {
                                            val hasPermission = usbManager.hasPermission(device)
                                            usbDeviceInfo.append("Device ${index + 1}:\n")
                                            usbDeviceInfo.append("  Name: ${device.deviceName}\n")
                                            usbDeviceInfo.append("  VID: 0x${device.vendorId.toString(16).uppercase()} (${device.vendorId})\n")
                                            usbDeviceInfo.append("  PID: 0x${device.productId.toString(16).uppercase()} (${device.productId})\n")
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
                                        usbDeviceInfo.append("❌ No USB devices detected\n")
                                        usbDeviceInfo.append("Check USB/OTG connection\n\n")
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
                            
                            // Recommendations based on error code
                            diagnostics.append("💡 RECOMMENDATIONS:\n")
                            when (initRet) {
                                2 -> {
                                    if (deviceOnline == 1 || currentDevice != "None" && currentDevice != "Unknown") {
                                        diagnostics.append("⚠️ Device DETECTED but init failed!\n")
                                        diagnostics.append("Possible causes:\n")
                                        diagnostics.append("1. USB permissions not granted\n")
                                        diagnostics.append("2. Device driver not loaded\n")
                                        diagnostics.append("3. License/authorization issue\n")
                                        diagnostics.append("4. Device not properly initialized\n")
                                    } else {
                                        diagnostics.append("⚠️ Device NOT detected\n")
                                        diagnostics.append("Check:\n")
                                        diagnostics.append("1. USB/OTG cable connected?\n")
                                        diagnostics.append("2. Scanner powered on?\n")
                                        diagnostics.append("3. USB host mode enabled?\n")
                                        diagnostics.append("4. USB permissions granted?\n")
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
                            
                            val deviceFile = File(kernelPath + "IDCardDevice.dat")
                            diagnostics.append("Device file exists: ${if (deviceFile.exists()) "✅" else "❌"}\n")
                            
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

                        // Detect document
                        Log.d(TAG, "Detecting document...")
                        val detect = api.DetectDocument()
                        Log.d(TAG, "DetectDocument returned: $detect")

                        if (detect != 1) {
                            val errorMsg = when (detect) {
                                0 -> "No document detected - Please place passport in scanner"
                                -1 -> "Document detection failed"
                                else -> "Document detection returned: $detect"
                            }
                            Log.e(TAG, errorMsg)
                            postError(result, "NO_DOC", errorMsg)
                            api.FreeIDCard()
                            return@Thread
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

                        // Save passport image if available
                        try {
                            val imagePath = kernelPath + "passport_image.jpg"
                            val saveRet = api.SaveImageEx(imagePath, 8) // 8 = document image
                            if (saveRet == 0) {
                                passportData["imagePath"] = imagePath
                                Log.d(TAG, "Passport image saved: $imagePath")
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Failed to save image: ${e.message}")
                        }

                        Log.d(TAG, "=== Passport Scan Complete ===")
                        Log.d(TAG, "Passport Data: $passportData")

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
