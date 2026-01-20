package com.sps.eth.sps_eth_app

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import product.idcard.android.IDCardAPI

class MainActivity : FlutterActivity() {

    private val CHANNEL = "passport_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            if (call.method == "scanPassport") {
                Thread {
                    try {
                        val api = IDCardAPI()

                        val copyUtil = CopyAssetsUtil(this)
                        val kernelPath = copyUtil.copyAssetsToInternal()

                        if (kernelPath == null) {
                            postError(result, "ASSET_ERROR", "Assets copy failed")
                            return@Thread
                        }

                        val initRet = api.InitIDCard(
                            "",
                            1,
                            kernelPath
                        )

                        if (initRet != 0) {
                            postError(result, "INIT_FAIL", "InitIDCard failed: $initRet")
                            return@Thread
                        }

                        api.SetConfigByFile(kernelPath + "IDCardConfig.ini")

                        val detect = api.DetectDocument()
                        if (detect != 1) {
                            postError(result, "NO_DOC", "No document detected")
                            return@Thread
                        }

                        val recog = api.RecogIDCard()
                        if (recog != 0) {
                            postError(result, "RECOG_FAIL", "Recognition failed: $recog")
                            return@Thread
                        }

                        // Read ALL fields safely
                        val data = HashMap<String, String>()

                        for (i in 0..50) {
                            val name = api.GetFieldName(i) ?: break
                            val value = api.GetRecogResult(i)
                            if (!value.isNullOrEmpty()) {
                                data[name] = value
                            }
                        }

                        Handler(Looper.getMainLooper()).post {
                            result.success(data)
                        }

                    } catch (e: Exception) {
                        postError(result, "EXCEPTION", e.message ?: "Unknown error")
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }
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
