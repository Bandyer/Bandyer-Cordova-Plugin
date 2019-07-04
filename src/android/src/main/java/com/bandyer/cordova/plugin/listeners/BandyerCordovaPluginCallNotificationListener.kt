package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.android_sdk.call.model.CallInfo
import com.bandyer.android_sdk.call.notification.CallNotificationListener
import com.bandyer.android_sdk.call.notification.CallNotificationStyle
import com.bandyer.android_sdk.call.notification.CallNotificationType
import com.bandyer.android_sdk.intent.call.CallIntentOptions
import com.bandyer.android_sdk.intent.call.IncomingCall
import com.bandyer.android_sdk.notification.NotificationAction

class BandyerCordovaPluginCallNotificationListener(private val mApplication: Application, private val mInitInput: BandyerSDKConfiguration) : CallNotificationListener {

    override fun onIncomingCall(call: IncomingCall, isDnd: Boolean, isScreenLocked: Boolean) {
        if (!isDnd || isScreenLocked)
            mApplication.startActivity(call.asActivityIntent(mApplication))
        else
            call.asNotification(mApplication).show()
    }

    override fun onCallActivityStartedFromNotificationAction(callInfo: CallInfo, callIntentOptions: CallIntentOptions) {
        if (mInitInput.isChatEnabled)
            callIntentOptions.withChatCapability()

        if (mInitInput.isWhiteboardEnabled)
            callIntentOptions.withWhiteboardCapability()

        if (mInitInput.isFileSharingEnabled)
            callIntentOptions.withFileSharingCapability()

        if (mInitInput.isScreenSharingEnabled)
            callIntentOptions.withScreenSharingCapability()
    }

    override fun onCreateNotification(callInfo: CallInfo, type: CallNotificationType, notificationStyle: CallNotificationStyle) {}

    override fun onNotificationAction(action: NotificationAction) {
        // Here you can execute your own code before executing the default action of the notification
        action.execute()
    }
}