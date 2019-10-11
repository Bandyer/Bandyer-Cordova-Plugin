package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.android_sdk.call.model.CallInfo
import com.bandyer.android_sdk.call.notification.CallNotificationListener
import com.bandyer.android_sdk.call.notification.CallNotificationStyle
import com.bandyer.android_sdk.call.notification.CallNotificationType
import com.bandyer.android_sdk.intent.call.CallCapabilities
import com.bandyer.android_sdk.intent.call.IncomingCall
import com.bandyer.android_sdk.intent.call.IncomingCallIntentOptions
import com.bandyer.android_sdk.notification.NotificationAction
import com.bandyer.cordova.plugin.BandyerSDKConfiguration

class BandyerCordovaPluginCallNotificationListener(private val mApplication: Application, private val mInitInput: BandyerSDKConfiguration) : CallNotificationListener {

    override fun onIncomingCall(call: IncomingCall, isDnd: Boolean, isScreenLocked: Boolean) {
        if (!isDnd || isScreenLocked) call.show(mApplication)
        else call.asNotification().show(mApplication)
    }

    override fun onCallActivityStartedFromNotificationAction(callInfo: CallInfo, callIntentOptions: IncomingCallIntentOptions) {
        val capabilities = CallCapabilities(mInitInput.isChatEnabled,
                mInitInput.isFileSharingEnabled,
                mInitInput.isScreenSharingEnabled,
                mInitInput.isWhiteboardEnabled)
        callIntentOptions.withCapabilities(capabilities)
    }

    override fun onCreateNotification(callInfo: CallInfo, type: CallNotificationType, notificationStyle: CallNotificationStyle) {}

    override fun onNotificationAction(action: NotificationAction) {
        // Here you can execute your own code before executing the default action of the notification
        action.execute()
    }
}