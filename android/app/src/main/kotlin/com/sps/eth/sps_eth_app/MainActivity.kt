package com.sps.eth.sps_eth_app

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
                                    status["deviceOnline"] = deviceOnline == 1
                                    status["currentDevice"] = currentDevice ?: "None"
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
                                // Initialization failed - expected on tablet
                                status["deviceOnline"] = false
                                status["currentDevice"] = "Hardware not detected (Expected on tablet)"
                                status["hardwareDetected"] = false
                                status["initErrorCode"] = initRet
                                status["initErrorMessage"] = when (initRet) {
                                    2 -> "Device initialization failed - Hardware required"
                                    else -> "Initialization failed with code: $initRet"
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

                        // Check device availability BEFORE initialization (if SDK supports it)
                        // Note: Some SDK versions require initialization first
                        Log.d(TAG, "Checking device availability...")
                        try {
                            val deviceOnline = api.CheckDeviceOnlineEx()
                            val currentDevice = api.GetCurrentDevice()
                            Log.d(TAG, "Device online check: $deviceOnline")
                            Log.d(TAG, "Current device: $currentDevice")
                            
                            if (deviceOnline == 0) {
                                Log.w(TAG, "⚠️ No scanner hardware detected - This is expected on tablet/emulator")
                                Log.w(TAG, "⚠️ Real scanning requires SPS Smart Police Station hardware")
                            }
                        } catch (e: Exception) {
                            Log.w(TAG, "Device check methods not available or require initialization first: ${e.message}")
                        }

                        // Initialize SDK
                        Log.d(TAG, "Initializing SDK...")
                        val initRet = api.InitIDCard("", 1, kernelPath)
                        Log.d(TAG, "InitIDCard returned: $initRet")

                        if (initRet != 0) {
                            val errorMsg = when (initRet) {
                                1 -> "Authorization ID is incorrect"
                                2 -> {
                                    // Error code 2 = Device initialization failed
                                    // This is EXPECTED on tablet/emulator without hardware
                                    val diagnostic = """
                                        ⚠️ Device initialization failed (Error Code: 2)
                                        
                                        This is NORMAL if testing on:
                                        - Android tablet (no scanner hardware)
                                        - Android emulator
                                        - Device without SPS scanner connected
                                        
                                        ✅ This WILL work on:
                                        - SPS Smart Police Station kiosk
                                        - Device with scanner hardware connected
                                        
                                        📋 SDK Status:
                                        - Native libraries loaded: ✅
                                        - Assets copied: ✅
                                        - SDK initialized: ❌ (requires hardware)
                                        
                                        💡 To verify on real hardware:
                                        1. Connect SPS scanner via USB/OTG
                                        2. Ensure scanner is powered on
                                        3. Check device manager for scanner device
                                    """.trimIndent()
                                    Log.w(TAG, diagnostic)
                                    "Device initialization failed - Hardware scanner required (Expected on tablet)"
                                }
                                3 -> "Recognition engine initialization failed - Check assets folder"
                                4 -> "Authorization files not found - Check license files"
                                5 -> "Failed to load templates - Check model files in assets"
                                6 -> "Chip reader initialization failed"
                                7 -> "Chinese ID card reader initialization failed"
                                else -> "Initialization failed with code: $initRet"
                            }
                            Log.e(TAG, "InitIDCard failed: $errorMsg")
                            
                            // For error code 2, provide more helpful message
                            if (initRet == 2) {
                                val diagnosticData = hashMapOf<String, String>(
                                    "errorCode" to "2",
                                    "errorMessage" to errorMsg,
                                    "isTabletTest" to "true",
                                    "requiresHardware" to "true",
                                    "sdkLoaded" to "true",
                                    "assetsCopied" to "true",
                                    "message" to "This error is EXPECTED on tablet. It WILL work on SPS kiosk hardware."
                                )
                                Handler(Looper.getMainLooper()).post {
                                    result.error("INIT_FAIL_HARDWARE_REQUIRED", errorMsg, diagnosticData)
                                }
                            } else {
                                postError(result, "INIT_FAIL", errorMsg)
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
