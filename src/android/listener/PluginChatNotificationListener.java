package com.bandyer.cordova.plugin.listener;

import android.app.Application;

import com.bandyer.android_sdk.chat.ChatInfo;
import com.bandyer.android_sdk.chat.notification.ChatNotificationListener;
import com.bandyer.android_sdk.chat.notification.ChatNotificationStyle;
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions;
import com.bandyer.android_sdk.intent.chat.IncomingChat;
import com.bandyer.android_sdk.notification.NotificationAction;

import com.bandyer.cordova.plugin.input.InitInput;

public class PluginChatNotificationListener implements ChatNotificationListener {

    private final Application mApplication;
    private final boolean mIsCallENabled, mIsWhiteboardEnabled;

    public PluginChatNotificationListener(Application application, InitInput input) {
        mApplication = application;
        mIsCallENabled = input.isCallEnabled();
        mIsWhiteboardEnabled = input.isWhiteboardEnabled();
    }

    @Override
    public void onChatActivityStartedFromNotificationAction(ChatInfo chatInfo, ChatIntentOptions chatIntentOptions) {
        chatIntentOptions
                .withAudioCallCapability(false, true)
                .withWhiteboardInCallCapability()
                .withAudioVideoCallCapability(false);
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
