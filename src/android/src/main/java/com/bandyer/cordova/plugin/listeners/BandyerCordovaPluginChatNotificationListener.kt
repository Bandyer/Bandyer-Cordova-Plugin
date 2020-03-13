package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.android_sdk.chat.model.ChatInfo
import com.bandyer.android_sdk.chat.notification.ChatNotificationListener
import com.bandyer.android_sdk.chat.notification.ChatNotificationStyle
import com.bandyer.android_sdk.intent.chat.IncomingChat
import com.bandyer.cordova.plugin.BandyerSDKConfiguration

class BandyerCordovaPluginChatNotificationListener(private val mApplication: Application, private val mInitInput: BandyerSDKConfiguration) : ChatNotificationListener {

    override fun onCreateNotification(chatInfo: ChatInfo, notificationStyle: ChatNotificationStyle) {}

    override fun onIncomingChat(chat: IncomingChat, isDnd: Boolean, isScreenLocked: Boolean) {
        chat.asNotification().show(mApplication)
    }
}
