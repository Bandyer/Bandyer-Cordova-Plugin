package com.bandyer.cordova.plugin.notifications

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import com.bandyer.cordova.plugin.extensions.asJSONObject
import org.json.JSONObject

/**
 * @author kristiyan
 */
class BandyerNotificationReceiver : BroadcastReceiver() {

    companion object {
        private val GCM_RECEIVE_ACTION = "com.google.android.c2dm.intent.RECEIVE"
        private val GCM_TYPE = "gcm"
        private val MESSAGE_TYPE_EXTRA_KEY = "message_type"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val bundle = intent.extras
        // check if is from gcm/fcm, else return because it is not a notification
        if (bundle == null || "google.com/iid" == bundle.getString("from")) return
        if (!isGcmMessage(intent)) {
            if (isOrderedBroadcast) resultCode = Activity.RESULT_OK
            return
        }

        // check if a bandyer notification service was defined in the manifest
        val serviceIntent = Intent().setAction("com.bandyer.NotificationEvent").setPackage(context.packageName)
        val resolveInfo = context.packageManager.queryIntentServices(serviceIntent, PackageManager.GET_RESOLVED_FILTER)
        if (resolveInfo.size < 1) return

        val bandyerPayloadPath: String
        try {
            bandyerPayloadPath = resolveInfo[0].filter.getDataPath(0).path
        } catch (e: Throwable) {
            throw NotificationPayloadDataPathNotDefined("You have not defined data path in your intent-filter!! Bandyer requires it to know where to find the payload!")
        }

        val payload = getBandyerPayload(intent, bandyerPayloadPath)
        // if bandyer can handle payload proceed
        if (payload == null) {
            resultCode = Activity.RESULT_OK
            return
        }

        val component = ComponentName(context, resolveInfo[0].serviceInfo.name)

        serviceIntent.component = component
        serviceIntent.putExtra("payload", payload)

        BandyerNotificationService.enqueueWork(context, component, BandyerNotificationReceiver::class.java.simpleName.hashCode(), serviceIntent)

        if (isOrderedBroadcast) abortBroadcast()
        resultCode = Activity.RESULT_OK
    }

    private fun getBandyerPayload(intent: Intent, bandyerPayloadPath: String): String? {
        try {
            val jsonObjects = bandyerPayloadPath.split("\\.".toRegex()).dropLastWhile { it.isEmpty() }.toTypedArray()
            val payload = intent.extras!!.asJSONObject()
            if (!payload.has(jsonObjects[0]))
                throw NotificationKeyNotFound("\nRequired jsonObject:" + jsonObjects[0] + " is not contained in " + payload.keys().asString())
            var bandyerData = payload.getString(jsonObjects[0])
            for (i in 1 until jsonObjects.size) {
                val data = JSONObject(bandyerData)
                if (!data.has(jsonObjects[i]))
                    throw NotificationKeyNotFound("\nRequired jsonObject:" + jsonObjects[i] + " is not contained in " + payload.keys().asString())
                bandyerData = JSONObject(bandyerData).getString(jsonObjects[i])
            }
            return bandyerData
        } catch (e: Throwable) {
            if (e is NotificationKeyNotFound) {
                Log.w("BandyerNotReceiver", "Failed to handle notification!!!" + e.message +
                        "\nThis notification will not be handled by Bandyer!" +
                        "\nBandyer payload not found in the following path: " + bandyerPayloadPath)
            } else
                Log.w("BandyerNotReceiver", "Failed to handle notification!!!" +
                        "\nThis notification will not be handled by Bandyer!" +
                        e.localizedMessage!!)
        }

        return null
    }

    private fun Iterator<String>.asString(): String {
        val value = StringBuilder()
        value.append("<")
        while (hasNext()) {
            value.append(next())
            if (hasNext()) value.append(",")
        }
        value.append(">")
        return value.toString()
    }

    private fun isBandyerNotification(intent: Intent): Boolean {
        intent.extras!!.asJSONObject().toString().contains("bandyer");
        return false
    }

    private fun isGcmMessage(intent: Intent): Boolean {
        if (GCM_RECEIVE_ACTION == intent.action) {
            val messageType = intent.getStringExtra(MESSAGE_TYPE_EXTRA_KEY)
            return messageType == null || GCM_TYPE == messageType
        }
        return false
    }


}

