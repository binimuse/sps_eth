package com.sps.eth.sps_eth_app

import android.hardware.usb.UsbConstants
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbDeviceConnection
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.util.Log
import java.io.IOException

private const val TAG = "UsbPrint"
private const val CHUNK_SIZE = 16 * 1024 // 16KB
private const val BULK_TIMEOUT_MS = 15000

/**
 * Exception when no USB printer is found.
 */
class NoPrinterException(message: String? = null) : Exception(message ?: "No USB printer found")

/**
 * Exception when USB permission is required (user must grant).
 */
class PermissionRequiredException(message: String? = null) : Exception(message ?: "USB permission required")

/**
 * USB direct print: find first printer-class device and send raw PDF bytes on bulk OUT.
 */
object UsbPrint {

    /**
     * Find the first connected USB device that has a printer-class interface (class 7).
     */
    @Throws(NoPrinterException::class)
    fun findPrinter(usbManager: UsbManager): UsbDevice {
        val deviceList = usbManager.deviceList ?: return throw NoPrinterException("No USB devices")
        for (device in deviceList.values) {
            for (i in 0 until device.interfaceCount) {
                val iface = device.getInterface(i)
                if (iface.interfaceClass == UsbConstants.USB_CLASS_PRINTER) {
                    Log.d(TAG, "Found USB printer: ${device.deviceName}")
                    return device
                }
            }
        }
        throw NoPrinterException("No device with USB printer class (7) found")
    }

    /**
     * Send raw PDF bytes to the printer via bulk OUT endpoint.
     * Runs on caller thread; do not call on main thread.
     * @throws NoPrinterException if no printer found
     * @throws PermissionRequiredException if device exists but permission not granted
     * @throws IOException on open/claim/transfer failure
     */
    @Throws(NoPrinterException::class, PermissionRequiredException::class, IOException::class)
    fun printPdf(usbManager: UsbManager, device: UsbDevice, pdfBytes: ByteArray) {
        if (!usbManager.hasPermission(device)) {
            throw PermissionRequiredException("USB permission not granted for ${device.deviceName}")
        }

        val printerInterface: UsbInterface = (0 until device.interfaceCount)
            .map { device.getInterface(it) }
            .firstOrNull { it.interfaceClass == UsbConstants.USB_CLASS_PRINTER }
            ?: throw IOException("Printer interface (class 7) not found on device")

        val outEndpoint: UsbEndpoint = (0 until printerInterface.endpointCount)
            .map { printerInterface.getEndpoint(it) }
            .firstOrNull { ep ->
                ep.type == UsbConstants.USB_ENDPOINT_XFER_BULK &&
                    ep.direction == UsbConstants.USB_DIR_OUT
            }
            ?: throw IOException("No bulk OUT endpoint on printer interface")
        Log.d(TAG, "Using endpoint: address=${outEndpoint.address}")

        val connection: UsbDeviceConnection = usbManager.openDevice(device)
            ?: throw IOException("Failed to open USB device")

        try {
            if (!connection.claimInterface(printerInterface, true)) {
                throw IOException("Failed to claim printer interface")
            }
            try {
                var offset = 0
                while (offset < pdfBytes.size) {
                    val len = minOf(CHUNK_SIZE, pdfBytes.size - offset)
                    val written = connection.bulkTransfer(outEndpoint, pdfBytes, offset, len, BULK_TIMEOUT_MS)
                    if (written < 0) {
                        throw IOException("bulkTransfer failed at offset $offset (result=$written)")
                    }
                    offset += written
                    Log.d(TAG, "Sent $written bytes, total $offset/${pdfBytes.size}")
                }
            } finally {
                connection.releaseInterface(printerInterface)
            }
        } finally {
            connection.close()
        }
    }
}
