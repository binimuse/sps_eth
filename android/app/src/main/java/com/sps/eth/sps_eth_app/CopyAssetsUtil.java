package com.sps.eth.sps_eth_app;

import android.content.Context;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class CopyAssetsUtil {

    private final Context context;

    public CopyAssetsUtil(Context context) {
        this.context = context;
    }

    /**
     * Copies idcardocr assets → app private storage
     * /data/data/<package>/files/IDCardProdTest/
     */
    public String copyAssetsToInternal() {
        try {
            File baseDir = new File(context.getFilesDir(), "IDCardProdTest");
            if (!baseDir.exists()) {
                baseDir.mkdirs();
            }

            copyAssetFolder("idcardocr", baseDir);

            return baseDir.getAbsolutePath() + File.separator;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void copyAssetFolder(String assetPath, File destDir) throws Exception {
        String[] assets = context.getAssets().list(assetPath);
        if (assets == null) return;

        for (String asset : assets) {
            String fullAssetPath = assetPath + "/" + asset;
            File outFile = new File(destDir, asset);

            if (context.getAssets().list(fullAssetPath).length > 0) {
                outFile.mkdirs();
                copyAssetFolder(fullAssetPath, outFile);
            } else {
                copyAssetFile(fullAssetPath, outFile);
            }
        }
    }

    private void copyAssetFile(String assetPath, File outFile) throws Exception {
        InputStream in = context.getAssets().open(assetPath);
        FileOutputStream out = new FileOutputStream(outFile);

        byte[] buffer = new byte[4096];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }

        in.close();
        out.flush();
        out.close();
    }
}
