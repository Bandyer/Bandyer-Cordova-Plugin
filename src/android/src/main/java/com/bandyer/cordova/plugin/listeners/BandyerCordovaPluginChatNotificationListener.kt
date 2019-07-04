package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.android_sdk.chat.ChatInfo
import com.bandyer.android_sdk.chat.notification.ChatNotificationListener
import com.bandyer.android_sdk.chat.notification.ChatNotificationStyle
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions
import com.bandyer.android_sdk.intent.chat.IncomingChat
import com.bandyer.android_sdk.notification.NotificationAction

class BandyerCordovaPluginChatNotificationListener(private val mApplication: Application, private val mInitInput: BandyerSDKConfiguration) : ChatNotificationListener {

    override fun onChatActivityStartedFromNotificationAction(chatInfo: ChatInfo, chatIntentOptions: ChatIntentOptions) {}

    override fun onCreateNotification(chatInfo: ChatInfo, notificationStyle: ChatNotificationStyle) {}

    override fun onIncomingChat(chat: IncomingChat, isDnd: Boolean, isScreenLocked: Boolean) {
        chat.asNotification(mApplication).show()
    }

    override fun onNotificationAction(action: NotificationAction) {
        action.execute()
    }
}
