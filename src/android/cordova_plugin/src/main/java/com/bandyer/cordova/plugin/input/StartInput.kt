package com.bandyer.cordova.plugin.input

import org.json.JSONArray
import org.json.JSONObject

import com.bandyer.cordova.plugin.Constants

class StartInput {

    var userAlias: String? = null

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): StartInput {
            val startInput = StartInput()
            try {
                val args = argsArray.get(0) as JSONObject
                val username = args.getString(Constants.ARG_USER_ALIAS)
                if (username == null || username == "") {
                    throw PluginInputNotValidException(Constants.ARG_USER_ALIAS + " cannot be null")
                }
                startInput.userAlias = username

                return startInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on StartInput " + t.message, t)
            }

        }
    }
}
