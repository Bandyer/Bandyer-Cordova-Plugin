package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.cordova.plugin.input.InitInput
import com.bandyer.android_sdk.chat.ChatInfo
import com.bandyer.android_sdk.chat.notification.ChatNotificationListener
import com.bandyer.android_sdk.chat.notification.ChatNotificationStyle
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions
import com.bandyer.android_sdk.intent.chat.IncomingChat
import com.bandyer.android_sdk.notification.NotificationAction

class PluginChatNotificationListener(private val mApplication: Application, private val mInitInput: InitInput) : ChatNotificationListener {

    override fun onChatActivityStartedFromNotificationAction(chatInfo: ChatInfo, chatIntentOptions: ChatIntentOptions) {
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

    override fun onCreateNotification(chatInfo: ChatInfo, notificationStyle: ChatNotificationStyle) {}

    override fun onIncomingChat(chat: IncomingChat, isDnd: Boolean, isScreenLocked: Boolean) {
        chat.asNotification(mApplication).show()
    }

    override fun onNotificationAction(action: NotificationAction) {
        action.execute()
    }
}
