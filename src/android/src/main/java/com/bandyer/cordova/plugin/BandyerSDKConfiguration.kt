package com.bandyer.cordova.plugin

import com.bandyer.cordova.plugin.exception.BandyerCordovaPluginExceptions
import org.json.JSONArray
import org.json.JSONObject

class BandyerSDKConfiguration {

    var appId: String? = null
    var environment: String? = null
    var isCallEnabled: Boolean = false
    var isFileSharingEnabled: Boolean = false
    var isScreenSharingEnabled: Boolean = false
    var isWhiteboardEnabled: Boolean = false
    var isChatEnabled: Boolean = false
    var isLogEnabled: Boolean = false

    val isProdEnvironment: Boolean
        get() = BandyerCordovaPluginConstants.VALUE_ENVIRONMENT_PRODUCTION == environment

    val isSandoboxEnvironment: Boolean
        get() = BandyerCordovaPluginConstants.VALUE_ENVIRONMENT_SANDBOX == environment

    class Builder(private val args: JSONArray) {

        @Throws(BandyerCordovaPluginExceptions::class)
        fun build(): BandyerSDKConfiguration {
            try {
                val bandyerSDKConfiguration = BandyerSDKConfiguration()
                val args = args.get(0) as JSONObject
                val appId = args.optString(BandyerCordovaPluginConstants.ARG_APP_ID)
                if (appId == "")
                    throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_APP_ID + " cannot be null")
                bandyerSDKConfiguration.appId = appId
                bandyerSDKConfiguration.isCallEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_CALL_ENABLED)
                bandyerSDKConfiguration.isChatEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_CHAT_ENABLED)
                bandyerSDKConfiguration.environment = args.getString(BandyerCordovaPluginConstants.ARG_ENVIRONMENT)
                bandyerSDKConfiguration.isFileSharingEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_FILE_SHARING_ENABLED)
                bandyerSDKConfiguration.isWhiteboardEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_WHITEBOARD_ENABLED)
                bandyerSDKConfiguration.isScreenSharingEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_SCREENSHARING_ENABLED)
                bandyerSDKConfiguration.isLogEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_ENABLE_LOG)
                return bandyerSDKConfiguration
            } catch (t: Throwable) {
                throw BandyerCordovaPluginExceptions("error on BandyerSDKConfiguration " + t.message, t)
            }
        }
    }
}
