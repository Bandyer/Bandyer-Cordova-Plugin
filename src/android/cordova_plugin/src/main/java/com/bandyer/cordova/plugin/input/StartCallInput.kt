package com.bandyer.cordova.plugin.input

import org.json.JSONArray
import org.json.JSONObject

import java.util.ArrayList

import com.bandyer.cordova.plugin.Constants

import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_VIDEO

class StartCallInput private constructor() {

    val calleeList: ArrayList<String>
    var joinUrl: String? = null
    var isRecordingEnabled: Boolean = false
    var callType: CallType? = null

    init {
        calleeList = ArrayList()
    }

    fun addCallee(callee: String) {
        calleeList.add(callee)
    }

    fun hasJoinUrl(): Boolean {
        return joinUrl != null && joinUrl!!.length > 0
    }

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): StartCallInput {
            val startInput = StartCallInput()
            try {
                val args = argsArray.get(0) as JSONObject
                val callee = if (args.has(Constants.ARG_CALLEE)) args.getJSONArray(Constants.ARG_CALLEE) else JSONArray()
                val joinUrl = if (args.has(Constants.ARG_JOIN_URL)) args.getString(Constants.ARG_JOIN_URL) else ""
                val isThereACallee = callee != null && callee.length() > 0
                val isThereAJoinUrl = joinUrl != null && joinUrl != ""
                if (!isThereACallee && !isThereAJoinUrl) {
                    throw PluginInputNotValidException(Constants.ARG_CALLEE + "and " + Constants.ARG_JOIN_URL + " cannot be null")
                }
                if (isThereACallee) {
                    val len = callee.length()
                    for (i in 0 until len) {
                        startInput.addCallee(callee.getString(i))
                    }
                }
                if (isThereAJoinUrl) {
                    startInput.joinUrl = joinUrl
                }
                val rec = if (args.has(Constants.ARG_RECORDING)) args.getBoolean(Constants.ARG_RECORDING) else false
                startInput.isRecordingEnabled = rec
                val type = if (args.has(Constants.ARG_CALL_TYPE)) args.getString(Constants.ARG_CALL_TYPE) else VALUE_CALL_TYPE_AUDIO_VIDEO
                if (VALUE_CALL_TYPE_AUDIO == type) {
                    startInput.callType = CallType.AUDIO
                } else if (VALUE_CALL_TYPE_AUDIO_UPGRADABLE == type) {
                    startInput.callType = CallType.AUDIO_UPGRADABLE
                } else {
                    startInput.callType = CallType.AUDIO_VIDEO
                }
                return startInput
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on InitInput " + t.message, t)
            }

        }
    }
}
