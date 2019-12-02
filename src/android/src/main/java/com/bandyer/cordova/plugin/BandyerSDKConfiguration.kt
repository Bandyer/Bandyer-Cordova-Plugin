package com.bandyer.cordova.plugin

import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import org.json.JSONArray
import org.json.JSONObject

data class BandyerSDKConfiguration(val appId: String? = null,
                                   val environment: String? = null,
                                   val isCallEnabled: Boolean = false,
                                   val isChatEnabled: Boolean = false,
                                   val isFileSharingEnabled: Boolean = false,
                                   val isScreenSharingEnabled: Boolean = false,
                                   val isWhiteboardEnabled: Boolean = false,
                                   val isLogEnabled: Boolean = false) {

    val isProdEnvironment: Boolean
        get() = BandyerCordovaPluginConstants.VALUE_ENVIRONMENT_PRODUCTION == environment

    val isSandboxEnvironment: Boolean
        get() = BandyerCordovaPluginConstants.VALUE_ENVIRONMENT_SANDBOX == environment

    class Builder(private val args: JSONArray) {

        @Throws(BandyerCordovaPluginExceptions::class)
        fun build(): BandyerSDKConfiguration {
            try {
                val args = args.get(0) as JSONObject
                val appId = args.optString(BandyerCordovaPluginConstants.ARG_APP_ID)
                if (appId == "")
                    throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_APP_ID + " cannot be null")
                return BandyerSDKConfiguration(appId,
                        environment = args.getString(BandyerCordovaPluginConstants.ARG_ENVIRONMENT),
                        isCallEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_CALL_ENABLED),
                        isChatEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_CHAT_ENABLED),
                        isFileSharingEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_FILE_SHARING_ENABLED),
                        isWhiteboardEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_WHITEBOARD_ENABLED),
                        isScreenSharingEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_SCREENSHARING_ENABLED),
                        isLogEnabled = args.getBoolean(BandyerCordovaPluginConstants.ARG_ENABLE_LOG)
                )
            } catch (t: Throwable) {
                throw BandyerCordovaPluginExceptions("error on BandyerSDKConfiguration " + t.message, t)
            }
        }
    }
}
