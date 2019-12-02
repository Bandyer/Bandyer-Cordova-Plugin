package com.bandyer.cordova.plugin.notifications;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.JobIntentService;

import com.bandyer.android_sdk.BandyerSDK;
import com.bandyer.android_sdk.client.BandyerSDKClient;
import com.bandyer.cordova.plugin.BandyerSDKConfiguration;
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginMethodNotValidException;
import com.bandyer.cordova.plugin.extensions.BandyerSDKExtensionsKt;
import com.bandyer.cordova.plugin.extensions.SharedPrefExtensionsKt;

import org.json.JSONArray;

import static com.bandyer.cordova.plugin.BandyerCordovaPluginManager.BANDYER_CORDOVA_PLUGIN_PREF;
import static com.bandyer.cordova.plugin.BandyerCordovaPluginManager.BANDYER_CORDOVA_PLUGIN_SETUP;

/**
 * @author kristiyan
 */
public class BandyerNotificationService extends JobIntentService {

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
        Bundle extras = intent.getExtras();
        if (extras == null) return;
        String payload = intent.getExtras().getString("payload");
        try {
            if (payload == null) return;
            SharedPreferences sharedPref = getApplicationContext().getSharedPreferences(BANDYER_CORDOVA_PLUGIN_PREF, Context.MODE_PRIVATE);
            JSONArray args = SharedPrefExtensionsKt.getJSONArray(sharedPref, BANDYER_CORDOVA_PLUGIN_SETUP);
            if (args == null)
                throw new BandyerCordovaPluginMethodNotValidException("Failed to setup the BandyerSDK to handle notifications");

            BandyerSDKConfiguration bandyerSDKConfiguration = new BandyerSDKConfiguration.Builder(args).build();

            BandyerSDK.Builder builder = BandyerSDKExtensionsKt.createBuilder(BandyerSDK.Companion, getApplication(), bandyerSDKConfiguration);

            BandyerSDK.init(builder);

            BandyerSDKClient.getInstance().handleNotification(getApplicationContext(), payload);
        } catch (Throwable exception) {
            Log.e("BandyerNotService", "" + exception.getMessage());
        }
    }
}
