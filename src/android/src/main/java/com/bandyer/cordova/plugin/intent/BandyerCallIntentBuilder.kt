package com.bandyer.cordova.plugin.intent

import android.content.Context
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.call.CallIntentOptions
import org.json.JSONArray
import org.json.JSONObject
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_VIDEO
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions

class BandyerCallIntentBuilder(
        private val initialContext: Context,
        private val bandyerSDKConfiguration: BandyerSDKConfiguration,
        private val argsArray: JSONArray) {

    @Throws(BandyerCordovaPluginExceptions::class)
    fun build(): BandyerIntent {
        val args = argsArray.get(0) as JSONObject
        val callType = args.optString(BandyerCordovaPluginConstants.ARG_CALL_TYPE, null) ?: VALUE_CALL_TYPE_AUDIO_VIDEO
        val callees = (if (args.has(BandyerCordovaPluginConstants.ARG_CALLEE)) args.getJSONArray(BandyerCordovaPluginConstants.ARG_CALLEE) else JSONArray())
        val hasCallees = callees != null && callees.length() > 0
        val joinUrl = if (args.has(BandyerCordovaPluginConstants.ARG_JOIN_URL)) args.getString(BandyerCordovaPluginConstants.ARG_JOIN_URL) else ""
        val hasJoinUrl = joinUrl != null && joinUrl != ""
        val recording = if (args.has(BandyerCordovaPluginConstants.ARG_RECORDING)) args.getBoolean(BandyerCordovaPluginConstants.ARG_RECORDING) else false

        if (!hasCallees && !hasJoinUrl)
            throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_CALLEE + "and " + BandyerCordovaPluginConstants.ARG_JOIN_URL + " cannot be null")

        val bandyerIntentBuilder: BandyerIntent.Builder = BandyerIntent.Builder()

        if (hasJoinUrl)
            return applyInCallFeatures(bandyerIntentBuilder.startFromJoinCallUrl(initialContext, joinUrl)).build()

        with(when {
            VALUE_CALL_TYPE_AUDIO == callType -> bandyerIntentBuilder.startWithAudioCall(initialContext, recording)
            VALUE_CALL_TYPE_AUDIO_UPGRADABLE == callType -> bandyerIntentBuilder.startWithAudioUpgradableCall(initialContext, recording)
            VALUE_CALL_TYPE_AUDIO_VIDEO == callType -> bandyerIntentBuilder.startWithAudioVideoCall(initialContext, recording)
            else -> throw BandyerCordovaPluginExceptions("Missing parameter for BandyerIntent build. Please specify a call type or a join url.")
        }) {

            return applyInCallFeatures(this.with(ArrayList<String>().apply {
                    for (i in 0 until callees.length()) {
                        this.add(callees.getString(i))
                    }
            })).build()
        }
    }

    private fun applyInCallFeatures(callIntentOptions: CallIntentOptions): CallIntentOptions {
        if (bandyerSDKConfiguration.isChatEnabled)
            callIntentOptions.withChatCapability()

        if (bandyerSDKConfiguration.isWhiteboardEnabled)
            callIntentOptions.withWhiteboardCapability()

        if (bandyerSDKConfiguration.isFileSharingEnabled)
            callIntentOptions.withFileSharingCapability()

        if (bandyerSDKConfiguration.isScreenSharingEnabled)
            callIntentOptions.withScreenSharingCapability()

        return callIntentOptions
    }
}
