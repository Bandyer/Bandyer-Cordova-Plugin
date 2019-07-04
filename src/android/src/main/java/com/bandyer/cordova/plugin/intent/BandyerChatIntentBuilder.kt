package com.bandyer.cordova.plugin.intent

import android.content.Context
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import org.json.JSONArray
import org.json.JSONObject
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_VIDEO
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_CHAT_ONLY
import com.bandyer.cordova.plugin.exception.BandyerCordovaPluginExceptions

class BandyerChatIntentBuilder(
        private val initialContext: Context,
        private val bandyerSDKConfiguration: BandyerSDKConfiguration,
        private val argsArray: JSONArray) {

    @Throws(BandyerCordovaPluginExceptions::class)
    fun build(): BandyerIntent {
        val args = argsArray.get(0) as JSONObject
        val otherChatParticipant = args.optString(BandyerCordovaPluginConstants.ARG_CHAT_USER_ALIAS) ?: null

        if (otherChatParticipant == null || otherChatParticipant == "")
            throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_CHAT_USER_ALIAS + " cannot be null")

        val hasCallRecordingFromChat = if (args.has(BandyerCordovaPluginConstants.ARG_RECORDING)) args.getBoolean(BandyerCordovaPluginConstants.ARG_RECORDING) else false
        val callTypeFromChat = if (args.has(BandyerCordovaPluginConstants.ARG_CALL_TYPE)) args.getString(BandyerCordovaPluginConstants.ARG_CALL_TYPE) else null

        val chatIntentOptions = BandyerIntent.Builder().startWithChat(initialContext).with(otherChatParticipant)
        return applyInCallFeatures(when (callTypeFromChat) {
            VALUE_CALL_TYPE_AUDIO -> chatIntentOptions.withAudioCallCapability(hasCallRecordingFromChat)
            VALUE_CALL_TYPE_AUDIO_UPGRADABLE -> chatIntentOptions.withAudioUpgradableCallCapability(hasCallRecordingFromChat)
            VALUE_CALL_TYPE_AUDIO_VIDEO -> chatIntentOptions.withAudioVideoCallCapability(hasCallRecordingFromChat)
            VALUE_CALL_TYPE_CHAT_ONLY -> return chatIntentOptions.build()
            else -> return chatIntentOptions.build()
        }).build()
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