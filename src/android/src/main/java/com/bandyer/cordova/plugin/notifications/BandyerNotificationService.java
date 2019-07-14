package com.bandyer.cordova.plugin.notifications;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.JobIntentService;

import com.bandyer.android_sdk.client.BandyerSDKClient;

/**
 * @author kristiyan
 */
public class BandyerNotificationService extends JobIntentService {

    @Override
    protected void onHandleWork(@NonNull Intent intent) {
        Bundle extras = intent.getExtras();
        if (extras == null) return;
        String payload = intent.getExtras().getString("payload");
        BandyerSDKClient.getInstance().handleNotification(getApplicationContext(), payload);
    }
}