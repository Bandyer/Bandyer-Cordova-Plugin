package com.bandyer.cordova.plugin.extensions

import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject


internal fun SharedPreferences.Editor.putJSONArray(key: String, array: JSONArray): SharedPreferences.Editor {
    putString(key, array.toString())
    return this
}

internal fun SharedPreferences.Editor.putJSONObject(key: String, obj: JSONObject): SharedPreferences.Editor {
    putString(key, obj.toString())
    return this
}

internal fun SharedPreferences.getJSONArray(key: String): JSONArray? {
    val value = getString(key, null) ?: return null
    return JSONArray(value)
}

internal fun SharedPreferences.getJSONObject(key: String): JSONObject? {
    val value = getString(key, null) ?: return null
    return JSONObject(value)
}