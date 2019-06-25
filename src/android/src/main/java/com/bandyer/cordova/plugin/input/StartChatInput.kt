package com.bandyer.cordova.plugin.input

import org.json.JSONArray
import org.json.JSONObject

import java.util.ArrayList

import com.bandyer.cordova.plugin.Constants

import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_VIDEO
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_CHAT_ONLY

class StartChatInput {

    var userAlias: String? = null
    var isRecordingEnabled: Boolean = false
    var callType: CallType? = null

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): StartChatInput {
            val startChatInput = StartChatInput()
            try {
                val args = argsArray.get(0) as JSONObject
                val userAlias = args.getString(Constants.ARG_CHAT_USER_ALIAS)
                if (userAlias == null || userAlias == "") {
                    throw PluginInputNotValidException(Constants.ARG_CHAT_USER_ALIAS + " cannot be null")
                }
                startChatInput.userAlias = userAlias
                val rec = if (args.has(Constants.ARG_RECORDING)) args.getBoolean(Constants.ARG_RECORDING) else false
                startChatInput.isRecordingEnabled = rec
                val type = if (args.has(Constants.ARG_CALL_TYPE)) args.getString(Constants.ARG_CALL_TYPE) else VALUE_CALL_TYPE_AUDIO_VIDEO
                if (VALUE_CALL_TYPE_AUDIO == type) {
                    startChatInput.callType = CallType.AUDIO
                } else if (VALUE_CALL_TYPE_AUDIO_UPGRADABLE == type) {
                    startChatInput.callType = CallType.AUDIO_UPGRADABLE
                } else if (VALUE_CALL_TYPE_CHAT_ONLY == type) {
                    startChatInput.callType = CallType.CHAT_ONLY
                } else {
                    startChatInput.callType = CallType.AUDIO_VIDEO
                }
                return startChatInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on StartChatInput " + t.message, t)
            }

        }
    }
}
