package com.bandyer.cordova.plugin.intent

import android.content.Context
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions
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
            chatIntentOptions.withAudioCallCapability(recording)
        }

        if (args.has(VALUE_CALL_TYPE_AUDIO_UPGRADABLE)) {
            val recording = args.getJSONObject(VALUE_CALL_TYPE_AUDIO_UPGRADABLE).getBoolean(ARG_RECORDING)
            chatIntentOptions.withAudioUpgradableCallCapability(recording)
        }

        if (args.has(VALUE_CALL_TYPE_AUDIO_VIDEO)) {
            val recording = args.getJSONObject(VALUE_CALL_TYPE_AUDIO_VIDEO).getBoolean(ARG_RECORDING)
            chatIntentOptions.withAudioVideoCallCapability(recording)
        }

        return applyInCallFeatures(chatIntentOptions).build()
    }

    private fun applyInCallFeatures(chatIntentOptions: ChatIntentOptions): ChatIntentOptions {
        if (bandyerSDKConfiguration.isWhiteboardEnabled)
            chatIntentOptions.withWhiteboardInCallCapability()

        if (bandyerSDKConfiguration.isFileSharingEnabled)
            chatIntentOptions.withFileSharingInCallCapability()

        if (bandyerSDKConfiguration.isScreenSharingEnabled)
            chatIntentOptions.withScreenSharingInCallCapability()

        return chatIntentOptions
    }
}