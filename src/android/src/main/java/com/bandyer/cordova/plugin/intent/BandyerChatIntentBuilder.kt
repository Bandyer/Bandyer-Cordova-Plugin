package com.bandyer.cordova.plugin.intent

import android.annotation.SuppressLint
import android.content.Context
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.call.CallCapabilities
import com.bandyer.android_sdk.intent.call.CallOptions
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_RECORDING
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_VIDEO
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import org.json.JSONArray
import org.json.JSONObject

class BandyerChatIntentBuilder(
        private val initialContext: Context,
        private val bandyerSDKConfiguration: BandyerSDKConfiguration,
        private val argsArray: JSONArray) {

    @SuppressLint("NewApi")
    @Throws(BandyerCordovaPluginExceptions::class)
    fun build(): BandyerIntent {

        val args = argsArray.get(0) as JSONObject

        val otherChatParticipant = args.optString(BandyerCordovaPluginConstants.ARG_CHAT_USER_ALIAS)
                ?: null

        if (otherChatParticipant == null || otherChatParticipant == "")
            throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_CHAT_USER_ALIAS + " cannot be null")

        val chatIntentOptions = BandyerIntent.Builder().startWithChat(initialContext).with(otherChatParticipant)


        if (args.has(VALUE_CALL_TYPE_AUDIO)) {
            val recording = args.getJSONObject(VALUE_CALL_TYPE_AUDIO).getBoolean(ARG_RECORDING)
            val callOptions = CallOptions(recordingEnabled = recording, backCameraAsDefault = false, disableProximitySensor = false)
            chatIntentOptions.withAudioCallCapability(getCallCapabilities(), callOptions)
        }

        if (args.has(VALUE_CALL_TYPE_AUDIO_UPGRADABLE)) {
            val recording = args.getJSONObject(VALUE_CALL_TYPE_AUDIO_UPGRADABLE).getBoolean(ARG_RECORDING)
            val callOptions = CallOptions(recordingEnabled = recording, backCameraAsDefault = false, disableProximitySensor = false)
            chatIntentOptions.withAudioUpgradableCallCapability(getCallCapabilities(), callOptions)
        }

        if (args.has(VALUE_CALL_TYPE_AUDIO_VIDEO)) {
            val recording = args.getJSONObject(VALUE_CALL_TYPE_AUDIO_VIDEO).getBoolean(ARG_RECORDING)
            val callOptions = CallOptions(recordingEnabled = recording, backCameraAsDefault = false, disableProximitySensor = false)
            chatIntentOptions.withAudioVideoCallCapability(getCallCapabilities(), callOptions)
        }

        return chatIntentOptions.build()
    }

    private fun getCallCapabilities(): CallCapabilities {
        return CallCapabilities(
                bandyerSDKConfiguration.isChatEnabled,
                bandyerSDKConfiguration.isFileSharingEnabled,
                bandyerSDKConfiguration.isScreenSharingEnabled,
                bandyerSDKConfiguration.isWhiteboardEnabled)
    }
}