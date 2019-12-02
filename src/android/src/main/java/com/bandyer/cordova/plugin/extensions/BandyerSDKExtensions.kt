package com.bandyer.cordova.plugin.extensions

import android.app.Application
import android.util.Log
import com.bandyer.android_common.logging.BaseLogger
import com.bandyer.android_sdk.BandyerSDK
import com.bandyer.android_sdk.Environment
import com.bandyer.android_sdk.utils.BandyerSDKLogger
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.cordova.plugin.listeners.BandyerCordovaPluginCallNotificationListener
import com.bandyer.cordova.plugin.listeners.BandyerCordovaPluginChatNotificationListener

/**
 *
 * @author kristiyan
 */

fun BandyerSDK.Companion.createBuilder(application: Application, configuration: BandyerSDKConfiguration): BandyerSDK.Builder {
    val builder = BandyerSDK.Builder(application, configuration.appId!!)
    when {
        configuration.isProdEnvironment -> builder.setEnvironment(Environment.production())
        configuration.isSandboxEnvironment -> builder.setEnvironment(Environment.sandbox())
    }

    if (configuration.isCallEnabled)
        builder.withCallEnabled(BandyerCordovaPluginCallNotificationListener(application, configuration))
    if (configuration.isWhiteboardEnabled)
        builder.withWhiteboardEnabled()
    if (configuration.isFileSharingEnabled)
        builder.withFileSharingEnabled()
    if (configuration.isScreenSharingEnabled)
        builder.withScreenSharingEnabled()
    if (configuration.isChatEnabled)
        builder.withChatEnabled(BandyerCordovaPluginChatNotificationListener(application, configuration))
    if (configuration.isLogEnabled)
        builder.setLogger(object : BandyerSDKLogger(BaseLogger.VERBOSE) {
            override fun warn(tag: String, message: String) {
                Log.w(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, message)
            }

            override fun verbose(tag: String, message: String) {
                Log.v(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, message)
            }

            override fun info(tag: String, message: String) {
                Log.i(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, message)
            }

            override fun error(tag: String, message: String) {
                Log.e(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, message)
            }

            override fun debug(tag: String, message: String) {
                Log.d(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, message)
            }
        })
    builder.allowSDKInitFromActivity()
    return builder
}