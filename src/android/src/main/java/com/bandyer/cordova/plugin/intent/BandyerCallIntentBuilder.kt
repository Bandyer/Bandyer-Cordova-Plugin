package com.bandyer.cordova.plugin.intent

import android.content.Context
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.call.CallCapabilities
import com.bandyer.android_sdk.intent.call.CallOptions
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.VALUE_CALL_TYPE_AUDIO_VIDEO
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import org.json.JSONArray
import org.json.JSONObject

class BandyerCallIntentBuilder(
        private val initialContext: Context,
        private val bandyerSDKConfiguration: BandyerSDKConfiguration,
        private val argsArray: JSONArray) {

    @Throws(BandyerCordovaPluginExceptions::class)
    fun build(): BandyerIntent {
        val args = argsArray.get(0) as JSONObject
        val callType = args.optString(BandyerCordovaPluginConstants.ARG_CALL_TYPE, null)
                ?: VALUE_CALL_TYPE_AUDIO_VIDEO
        val callees = (if (args.has(BandyerCordovaPluginConstants.ARG_CALLEE)) args.getJSONArray(BandyerCordovaPluginConstants.ARG_CALLEE) else JSONArray())
        val hasCallees = callees != null && callees.length() > 0
        val joinUrl = if (args.has(BandyerCordovaPluginConstants.ARG_JOIN_URL)) args.getString(BandyerCordovaPluginConstants.ARG_JOIN_URL) else ""
        val hasJoinUrl = joinUrl != null && joinUrl != ""
        val recording = if (args.has(BandyerCordovaPluginConstants.ARG_RECORDING)) args.getBoolean(BandyerCordovaPluginConstants.ARG_RECORDING) else false

        if (!hasCallees && !hasJoinUrl)
            throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_CALLEE + "and " + BandyerCordovaPluginConstants.ARG_JOIN_URL + " cannot be null")

        val bandyerIntentBuilder: BandyerIntent.Builder = BandyerIntent.Builder()

        if (hasJoinUrl)
            return bandyerIntentBuilder.startFromJoinCallUrl(initialContext, joinUrl).withCapabilities(getCallCapabilities()).build()

        return with(when {
            VALUE_CALL_TYPE_AUDIO == callType -> bandyerIntentBuilder.startWithAudioCall(initialContext)
            VALUE_CALL_TYPE_AUDIO_UPGRADABLE == callType -> bandyerIntentBuilder.startWithAudioUpgradableCall(initialContext)
            VALUE_CALL_TYPE_AUDIO_VIDEO == callType -> bandyerIntentBuilder.startWithAudioVideoCall(initialContext)
            else -> throw BandyerCordovaPluginExceptions("Missing parameter for BandyerIntent build. Please specify a call type or a join url.")
        }) {
            with(ArrayList<String>().apply {
                for (i in 0 until callees.length()) {
                    this.add(callees.getString(i))
                }
            })
                    .withCapabilities(getCallCapabilities())
                    .withOptions(CallOptions(recordingEnabled = recording,
                            backCameraAsDefault = false,
                            disableProximitySensor = false)).build()
        }

    }

    private fun getCallCapabilities(): CallCapabilities {
        return CallCapabilities(
                bandyerSDKConfiguration.isChatEnabled,
                bandyerSDKConfiguration.isFileSharingEnabled,
                bandyerSDKConfiguration.isScreenSharingEnabled,
                bandyerSDKConfiguration.isWhiteboardEnabled)
    }
}
