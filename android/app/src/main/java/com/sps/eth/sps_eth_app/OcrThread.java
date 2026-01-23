package com.sps.eth.sps_eth_app;

import android.content.Context;
import android.os.Environment;
import android.util.Log;

import product.idcard.android.IDCardAPI;

import java.io.File;

/**
 * CLEAN OCR THREAD
 * - Image based passport / MRZ scanning
 * - NO chip reader
 * - NO OTG
 * - NO demo UI dependencies
 */
public class OcrThread extends Thread {

    private final Context context;
    private final IDCardAPI idCardAPI;
    public boolean isFinished = false;

    private final String basePath =
            Environment.getExternalStorageDirectory().getAbsolutePath()
                    + "/AndroidIDCard/";

    public OcrThread(Context context) {
        this.context = context;
        this.idCardAPI = new IDCardAPI();
    }

    @Override
    public void run() {
        try {
            prepareFolders();

            // 1️⃣ Init SDK
            int init = idCardAPI.InitIDCard("", 1, basePath);
            if (init != 0) {
                Log.e("OCR", "InitIDCard failed: " + init);
                isFinished = true;
                return;
            }

            // Optional config file (if vendor provided)
            File cfg = new File(basePath + "IDCardConfig.ini");
            if (cfg.exists()) {
                idCardAPI.SetConfigByFile(cfg.getAbsolutePath());
            }

            // 2️⃣ Detect document
            int detected = idCardAPI.DetectDocument();
            if (detected != 1) {
                Log.e("OCR", "No document detected");
                isFinished = true;
                return;
            }

            // 3️⃣ Auto recognize passport / MRZ
            int[] cardType = new int[]{-1};
            int recog = idCardAPI.AutoProcessIDCard(cardType);

            if (recog <= 0) {
                Log.e("OCR", "Recognition failed: " + recog);
                isFinished = true;
                return;
            }

            // 4️⃣ Save result image
            idCardAPI.SaveImageEx(basePath + "result.jpg", 31);

            Log.i("OCR", "Passport scanned successfully");

        } catch (Exception e) {
            Log.e("OCR", "Scan error", e);
        } finally {
            isFinished = true;
        }
    }

    private void prepareFolders() {
        File dir = new File(basePath);
        if (!dir.exists()) dir.mkdirs();
    }
    public String getField(int index) {
        try {
            return idCardAPI.GetRecogResult(index);
        } catch (Exception e) {
            return "";
        }
    }
    
}
