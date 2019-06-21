package com.bandyer.cordova.plugin.input

import org.json.JSONArray
import org.json.JSONObject

import com.bandyer.cordova.plugin.Constants

class HandleNotificationInput {

    var payload: String? = null

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): HandleNotificationInput {
            val handleNotificationInput = HandleNotificationInput()
            try {
                val args = argsArray.get(0) as JSONObject
                val payload = args.getString(Constants.ARG_HANDLE_NOTIFICATION)
                if (payload == null || payload == "") {
                    throw PluginInputNotValidException(Constants.ARG_HANDLE_NOTIFICATION + " cannot be null")
                }
                handleNotificationInput.payload = payload

                return handleNotificationInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on InitInput", t)
            }

        }
    }
}
