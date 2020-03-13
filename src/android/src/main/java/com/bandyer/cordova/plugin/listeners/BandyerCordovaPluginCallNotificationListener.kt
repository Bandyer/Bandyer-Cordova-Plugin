package com.bandyer.cordova.plugin.listeners

import android.app.Application
import com.bandyer.android_sdk.call.model.CallInfo
import com.bandyer.android_sdk.call.notification.CallNotificationListener
import com.bandyer.android_sdk.call.notification.CallNotificationStyle
import com.bandyer.android_sdk.call.notification.CallNotificationType
import com.bandyer.android_sdk.intent.call.CallCapabilities
import com.bandyer.android_sdk.intent.call.IncomingCall
import com.bandyer.cordova.plugin.BandyerSDKConfiguration

class BandyerCordovaPluginCallNotificationListener(private val mApplication: Application, private val mInitInput: BandyerSDKConfiguration) : CallNotificationListener {

    override fun onIncomingCall(call: IncomingCall, isDnd: Boolean, isScreenLocked: Boolean) {
        val capabilities = CallCapabilities(mInitInput.isChatEnabled,
                mInitInput.isFileSharingEnabled,
                mInitInput.isScreenSharingEnabled,
                mInitInput.isWhiteboardEnabled)
        call.withCapabilities(capabilities)
        if (!isDnd || isScreenLocked) call.show(mApplication)
        else call.asNotification().show(mApplication)
    }

    override fun onCreateNotification(callInfo: CallInfo, type: CallNotificationType, notificationStyle: CallNotificationStyle) {}
}