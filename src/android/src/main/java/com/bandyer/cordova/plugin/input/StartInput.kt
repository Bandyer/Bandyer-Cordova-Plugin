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
                val userAlias = args.getString(Constants.ARG_USER_ALIAS)
                if (userAlias == null || userAlias == "") {
                    throw PluginInputNotValidException(Constants.ARG_USER_ALIAS + " cannot be null")
                }
                startInput.userAlias = userAlias

                return startInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on StartInput " + t.message, t)
            }

        }
    }
}
