package com.bandyer.cordova.plugin.notifications

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.JobIntentService
import com.bandyer.android_sdk.BandyerSDK
import com.bandyer.android_sdk.client.BandyerSDKClient
import com.bandyer.android_sdk.utils.provider.OnUserDetailsListener
import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.android_sdk.utils.provider.UserDetailsProvider
import com.bandyer.cordova.plugin.BandyerCordovaPluginManager
import com.bandyer.cordova.plugin.BandyerSDKConfiguration
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginMethodNotValidException
import com.bandyer.cordova.plugin.extensions.createBuilder
import com.bandyer.cordova.plugin.extensions.getJSONArray
import com.bandyer.cordova.plugin.repository.UserDetailsDB.Companion.getInstance
import com.bandyer.cordova.plugin.utils.IO
import com.bandyer.cordova.plugin.utils.toUserDetails
import java.util.*

/**
 * @author kristiyan
 */
class BandyerNotificationService : JobIntentService() {

    companion object {

        fun enqueueWork(context: Context, componentName: ComponentName, intent: Intent) {
            enqueueWork(context, componentName, BandyerNotificationReceiver::class.java.simpleName.hashCode(), intent)
        }
    }


    override fun onHandleWork(intent: Intent) {
        val extras = intent.extras ?: return
        val payload = extras.getString("payload") ?: return
        try {

            val sharedPref = applicationContext.getSharedPreferences(BandyerCordovaPluginManager.BANDYER_CORDOVA_PLUGIN_PREF, Context.MODE_PRIVATE)

            val args = sharedPref.getJSONArray(BandyerCordovaPluginManager.BANDYER_CORDOVA_PLUGIN_SETUP)
                    ?: throw BandyerCordovaPluginMethodNotValidException("Failed to setup the BandyerSDK to handle notifications")

            val bandyerSDKConfiguration = BandyerSDKConfiguration.Builder(args).build()
            val builder = BandyerSDK.createBuilder(application, bandyerSDKConfiguration)

            val db = getInstance(applicationContext)

            builder.withUserDetailsProvider(object : UserDetailsProvider {
                override fun onUserDetailsRequested(userAliases: List<String>, onUserDetailsListener: OnUserDetailsListener) {
                    IO {
                        try {
                            val users = db!!.userDao()!!.loadAllByUserAliases(userAliases.toTypedArray())
                            val userDetails: MutableList<UserDetails> = ArrayList()
                            for (user in users!!) userDetails.add(user!!.toUserDetails())
                            onUserDetailsListener.provide(userDetails)
                        } catch (e: Throwable) {
                            e.printStackTrace()
                        }
                    }
                }
            })

            BandyerSDK.init(builder)
            BandyerSDKClient.getInstance().handleNotification(applicationContext, payload)
        } catch (exception: Throwable) {
            Log.e("BandyerNotService", "" + exception.message)
        }
    }
}