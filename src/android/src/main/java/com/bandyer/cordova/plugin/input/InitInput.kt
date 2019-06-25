package com.bandyer.cordova.plugin.input

import org.json.JSONArray
import org.json.JSONObject
import android.util.Log

import com.bandyer.cordova.plugin.Constants

class InitInput {

    var appId: String? = null
    var environment: String? = null
    var isCallEnabled: Boolean = false
    var isFileSharingEnabled: Boolean = false
    var isScreenSharingEnabled: Boolean = false
    var isWhiteboardEnabled: Boolean = false
    var isChatEnabled: Boolean = false
    var isLogEnabled: Boolean = false


    val isProdEnvironment: Boolean
        get() = Constants.VALUE_ENVIRONMENT_PRODUCTION == environment

    val isSandoboxEnvironment: Boolean
        get() = Constants.VALUE_ENVIRONMENT_SANDBOX == environment

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): InitInput {
            val initInput = InitInput()
            try {
                val args = argsArray.get(0) as JSONObject
                val appId = args.getString(Constants.ARG_APP_ID)
                if (appId == null || appId == "") {
                    throw PluginInputNotValidException(Constants.ARG_APP_ID + " cannot be null")
                }
                initInput.appId = appId
                initInput.isCallEnabled = args.getBoolean(Constants.ARG_CALL_ENABLED)
                initInput.isChatEnabled = args.getBoolean(Constants.ARG_CHAT_ENABLED)
                initInput.environment = args.getString(Constants.ARG_ENVIRONMENT)
                initInput.isFileSharingEnabled = args.getBoolean(Constants.ARG_FILE_SHARING_ENABLED)
                initInput.isWhiteboardEnabled = args.getBoolean(Constants.ARG_WHITEBOARD_ENABLED)
                initInput.isScreenSharingEnabled = args.getBoolean(Constants.ARG_SCREENSHARING_ENABLED)



                initInput.isLogEnabled = args.getBoolean(Constants.ARG_ENABLE_LOG)
                return initInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on InitInput " + t.message, t)
            }

        }
    }
}
