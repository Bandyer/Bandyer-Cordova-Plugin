package com.bandyer.cordova.plugin.extensions

import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import org.json.JSONArray
import org.json.JSONObject

@Throws(BandyerCordovaPluginExceptions::class)
fun JSONArray.retrieveLoginUserAlias(): String {
    val args = this.get(0) as JSONObject
    val userAlias = args.optString(BandyerCordovaPluginConstants.ARG_USER_ALIAS)
    if (userAlias == "")
        throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_USER_ALIAS + " cannot be null")
    return userAlias
}

@Throws(BandyerCordovaPluginExceptions::class)
fun JSONArray.retrievePushNotificationPayload(): String {
    try {
        val args = this.get(0) as JSONObject
        val payload = args.optString(BandyerCordovaPluginConstants.ARG_HANDLE_NOTIFICATION)
        if (payload == "")
            throw BandyerCordovaPluginExceptions(BandyerCordovaPluginConstants.ARG_HANDLE_NOTIFICATION + " cannot be null")
        return payload
    } catch (t: Throwable) {
        throw BandyerCordovaPluginExceptions("error on BandyerSDKConfiguration", t)
    }
}

fun JSONArray.retrieveUserDetails(): JSONArray {
    return optJSONObject(0).optJSONArray(BandyerCordovaPluginConstants.ARG_USERS_DETAILS) ?: JSONArray()
}