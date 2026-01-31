package com.sps.eth.sps_eth_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Starts MainActivity when the device finishes booting.
 * Enables auto-launch on boot for kiosk / dedicated device use.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_BOOT_COMPLETED &&
            intent?.action != "android.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }
        val mainIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
        }
        try {
            context.startActivity(mainIntent)
            Log.d(TAG, "Auto-launched app on boot")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to auto-launch on boot", e)
        }
    }

    companion object {
        private const val TAG = "BootReceiver"
    }
}
