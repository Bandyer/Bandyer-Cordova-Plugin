package com.bandyer.cordova.plugin.listeners;

import android.app.Application;
import com.bandyer.cordova.plugin.input.InitInput;
import com.bandyer.android_sdk.call.model.CallInfo;
import com.bandyer.android_sdk.call.notification.CallNotificationListener;
import com.bandyer.android_sdk.call.notification.CallNotificationStyle;
import com.bandyer.android_sdk.call.notification.CallNotificationType;
import com.bandyer.android_sdk.intent.call.CallIntentOptions;
import com.bandyer.android_sdk.intent.call.IncomingCall;
import com.bandyer.android_sdk.notification.NotificationAction;

public class PluginCallNotificationListener implements CallNotificationListener {

    private Application mApplication;
    private InitInput mInitInput;

    public PluginCallNotificationListener(Application application, InitInput initInput) {
        mApplication = application;
        mInitInput = initInput;
    }

    public void onIncomingCall(IncomingCall call, boolean isDnd, boolean isScreenLocked) {
        if (!isDnd || isScreenLocked) {
            mApplication.startActivity(call.asActivityIntent(mApplication));
        } else {
            call.asNotification(mApplication).show();
        }
    }

    public void onCallActivityStartedFromNotificationAction(CallInfo callInfo, CallIntentOptions callIntentOptions) {
        if (mInitInput.isChatEnabled()) {
            callIntentOptions.withChatCapability();
        }
        if (mInitInput.isWhiteboardEnabled()) {
            callIntentOptions.withWhiteboardCapability();
        }
        if (mInitInput.isFileSharingEnabled()) {
            callIntentOptions.withFileSharingCapability();
        }
        if (mInitInput.isScreenSharingEnabled()) {
            callIntentOptions.withScreenSharingCapability();
        }
    }

    public void onCreateNotification(CallInfo callInfo, CallNotificationType type, CallNotificationStyle notificationStyle) {
    }

    public void onNotificationAction(NotificationAction action) {
        // Here you can execute your own code before executing the default action of the notification
        action.execute();
    }
}