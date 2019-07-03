package com.bandyer.cordova.plugin.extensions

import android.os.Bundle
import org.json.JSONObject

/**
 *
 * @author kristiyan
 */

fun Bundle.asJSONObject(): JSONObject {
    val json = JSONObject()
    val keys = keySet()

    for (key in keys) {
        try {
            json.put(key, get(key))
        } catch (e: Throwable) {
            e.printStackTrace()
        }
    }
    return json
}
