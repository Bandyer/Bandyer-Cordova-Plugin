package com.bandyer.cordova.plugin.listeners;

import android.app.Application;
import com.bandyer.cordova.plugin.input.InitInput;
import com.bandyer.android_sdk.chat.ChatInfo;
import com.bandyer.android_sdk.chat.notification.ChatNotificationListener;
import com.bandyer.android_sdk.chat.notification.ChatNotificationStyle;
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions;
import com.bandyer.android_sdk.intent.chat.IncomingChat;
import com.bandyer.android_sdk.notification.NotificationAction;

public class PluginChatNotificationListener implements ChatNotificationListener {

    private Application mApplication;
    private InitInput mInitInput;

    public PluginChatNotificationListener(Application application, InitInput input) {
        mApplication = application;
        mInitInput = input;
    }

    @Override
    public void onChatActivityStartedFromNotificationAction(ChatInfo chatInfo, ChatIntentOptions chatIntentOptions) {
        // if (mInitInput.isCallEnabled()) {
        //     chatIntentOptions.withAudioCallCapability(false);
        //     chatIntentOptions.withAudioUpgradableCallCapability(false);
        //     chatIntentOptions.withAudioVideoCallCapability(false);
        // }

        // if (mInitInput.isWhiteboardEnabled()) {
        //     chatIntentOptions.withWhiteboardInCallCapability();
        // }
        
        // if (mInitInput.isFileSharingEnabled()) {
        //     chatIntentOptions.withFileSharingInCallCapability();
        // }

        // if (mInitInput.isScreenSharingEnabled()) {
        //     chatIntentOptions.withScreenSharingInCallCapability();
        // }
    }

    @Override
    public void onCreateNotification(ChatInfo chatInfo, ChatNotificationStyle chatNotificationStyle) {
    }

    @Override
    public void onIncomingChat(IncomingChat incomingChat, boolean b, boolean b1) {
        incomingChat.asNotification(mApplication).show();
    }

    @Override
    public void onNotificationAction(NotificationAction notificationAction) {
        notificationAction.execute();
    }
}
