package com.bandyer.cordova.plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.content.Context
import com.bandyer.android_sdk.BandyerSDK
import com.bandyer.android_sdk.call.CallModule
import com.bandyer.android_sdk.chat.ChatModule
import com.bandyer.android_sdk.client.BandyerSDKClient
import com.bandyer.android_sdk.client.BandyerSDKClientObserver
import com.bandyer.android_sdk.client.BandyerSDKClientOptions
import com.bandyer.android_sdk.client.BandyerSDKClientState
import com.bandyer.android_sdk.intent.call.CallDisplayMode
import com.bandyer.android_sdk.module.BandyerModule
import com.bandyer.android_sdk.module.BandyerModuleObserver
import com.bandyer.android_sdk.module.BandyerModuleStatus
import com.bandyer.android_sdk.utils.provider.OnUserDetailsListener
import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.android_sdk.utils.provider.UserDetailsProvider
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_ALIAS
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_EMAIL
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_FIRSTNAME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_IMAGEURL
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_LASTNAME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_NICKNAME
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginMethodNotValidException
import com.bandyer.cordova.plugin.extensions.createBuilder
import com.bandyer.cordova.plugin.extensions.putJSONArray
import com.bandyer.cordova.plugin.extensions.toCordovaModuleStatus
import com.bandyer.cordova.plugin.intent.BandyerCallIntentBuilder
import com.bandyer.cordova.plugin.intent.BandyerChatIntentBuilder
import org.apache.cordova.CallbackContext
import org.apache.cordova.PluginResult
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class BandyerCordovaPluginManager(var bandyerCallbackContext: CallbackContext?) {

    private var bandyerSDKConfiguration: BandyerSDKConfiguration? = null

    private val usersDetailMap = HashMap<String, UserDetails>()

    companion object {
        const val BANDYER_CORDOVA_PLUGIN_PREF = "BANDYER_CORDOVA_PLUGIN_PREF"
        const val BANDYER_CORDOVA_PLUGIN_SETUP = "BANDYER_CORDOVA_PLUGIN_SETUP"
    }

    private val moduleObserver = object : BandyerModuleObserver {
        override fun onModuleReady(module: BandyerModule) = Unit
        override fun onModulePaused(module: BandyerModule) = Unit
        override fun onModuleFailed(module: BandyerModule, throwable: Throwable) {
            if (module is CallModule) sendEvent(Events.CallError.name, throwable.localizedMessage)
            if (module is ChatModule) sendEvent(Events.ChatError.name, throwable.localizedMessage)
        }

        override fun onModuleStatusChanged(module: BandyerModule, moduleStatus: BandyerModuleStatus) {
            moduleStatus.toCordovaModuleStatus()?.let { cordovaModuleStatus ->
                notifyStatusChange(module, cordovaModuleStatus)
            }
        }
    }

    private val clientObserver = object : BandyerSDKClientObserver {
        override fun onClientError(throwable: Throwable) {
            sendEvent(Events.SetupError.name, throwable.localizedMessage)
        }

        override fun onClientReady() = Unit
        override fun onClientStatusChange(state: BandyerSDKClientState) = Unit
        override fun onClientStopped() = Unit

    }

    fun sendEvent(event: String, vararg args: Any?) {
        val message = JSONObject()
        message.put("event", event)
        val data = JSONArray().apply {
            args.forEach { put(it) }
        }
        message.put("args", data)
        val pluginResult = PluginResult(PluginResult.Status.OK, message)
        pluginResult.keepCallback = true
        bandyerCallbackContext?.sendPluginResult(pluginResult)
    }

    val currentState: String
        get() = convertToString(BandyerSDKClient.getInstance().state)

    @SuppressLint("NewApi")
    @Throws(BandyerCordovaPluginExceptions::class)
    fun setup(application: Application, args: JSONArray) {

        bandyerSDKConfiguration = BandyerSDKConfiguration.Builder(args).build()

        if (bandyerSDKConfiguration == null)
            throw BandyerCordovaPluginMethodNotValidException("A setup method call is needed before a call operation")

        val builder = BandyerSDK.createBuilder(application, bandyerSDKConfiguration!!)

        builder.withUserDetailsProvider(object : UserDetailsProvider {
            override fun onUserDetailsRequested(userAliases: List<String>, onUserDetailsListener: OnUserDetailsListener) {
                // provide results on the OnUserInformationProviderListener object
                val details = mutableListOf<UserDetails>()
                userAliases.forEach { userAlias ->
                    if (usersDetailMap.containsKey(userAlias)) details.add(usersDetailMap[userAlias]!!)
                    else details.add(UserDetails.Builder(userAlias).build())
                }
                onUserDetailsListener.provide(details)
            }
        })

        BandyerSDK.init(builder)

        val pref = application.getSharedPreferences(BANDYER_CORDOVA_PLUGIN_PREF, Context.MODE_PRIVATE)
        pref.edit().putJSONArray(BANDYER_CORDOVA_PLUGIN_SETUP, args).apply()
    }

    @Throws(BandyerCordovaPluginExceptions::class)
    fun start(activity: Activity, args: JSONArray) {
        if (BandyerSDKClient.getInstance().state != BandyerSDKClientState.UNINITIALIZED) {
            clearUserCache(activity)
        }

        val options = BandyerSDKClientOptions.Builder()
                .keepListeningForEventsInBackground(false)
                .build()

        addObservers()

        val userAlias = args.getJSONObject(0).optString(BandyerCordovaPluginConstants.ARG_USER_ALIAS)

        BandyerSDKClient.getInstance().init(userAlias, options)

        startListening()
    }

    fun resume() {
        BandyerSDKClient.getInstance().resume()
        startListening()
    }

    fun pause() {
        stopListening()
        BandyerSDKClient.getInstance().pause()
    }

    fun stop() {
        stopListening()
        BandyerSDKClient.getInstance().dispose()
        removeObservers()
    }

    private fun startListening() {
        BandyerSDKClient.getInstance().startListening()
    }

    private fun stopListening() {
        BandyerSDKClient.getInstance().stopListening()
    }

    fun clearUserCache(activity: Activity) {
        activity.application.getSharedPreferences(BANDYER_CORDOVA_PLUGIN_PREF, Context.MODE_PRIVATE).edit().clear().apply()
        BandyerSDKClient.getInstance().clearUserCache()
        BandyerSDKClient.getInstance().dispose()
    }

    private fun convertToString(state: BandyerSDKClientState): String {
        return when (state) {
            BandyerSDKClientState.UNINITIALIZED -> "stopped"
            BandyerSDKClientState.INITIALIZING -> "resuming"
            BandyerSDKClientState.PAUSED -> "paused "
            else -> "running"
        }
    }

    private fun addObservers() {
        BandyerSDKClient.getInstance().addObserver(clientObserver)
        BandyerSDKClient.getInstance().addModuleObserver(moduleObserver)
    }

    private fun removeObservers() {
        BandyerSDKClient.getInstance().removeModuleObserver(moduleObserver)
    }

    fun handlePushNotificationPayload(application: Application, args: JSONArray) {
        val payload = args.getJSONObject(0).optString(BandyerCordovaPluginConstants.ARG_HANDLE_NOTIFICATION)
        BandyerSDKClient.getInstance().handleNotification(application, payload)
    }

    @Throws(BandyerCordovaPluginMethodNotValidException::class)
    fun startCall(bandyerCordovaPlugin: BandyerCordovaPlugin, args: JSONArray) {
        if (bandyerSDKConfiguration == null)
            throw BandyerCordovaPluginMethodNotValidException("A setup method call is needed before a call operation")

        if (!bandyerSDKConfiguration!!.isCallEnabled)
            throw BandyerCordovaPluginMethodNotValidException("Cannot manage a 'start call' request: call feature is not enabled!")

        val bandyerCallIntent = BandyerCallIntentBuilder(bandyerCordovaPlugin.cordova.activity, bandyerSDKConfiguration!!, args).build()
        bandyerCordovaPlugin.cordova.startActivityForResult(bandyerCordovaPlugin, bandyerCallIntent, BandyerCordovaPluginConstants.INTENT_REQUEST_CALL_CODE)
    }

    @Throws(BandyerCordovaPluginMethodNotValidException::class)
    fun startChat(bandyerCordovaPlugin: BandyerCordovaPlugin, args: JSONArray) {
        if (bandyerSDKConfiguration == null)
            throw BandyerCordovaPluginMethodNotValidException("A setup method call is needed before a chat operation")

        if (!bandyerSDKConfiguration!!.isChatEnabled)
            throw BandyerCordovaPluginMethodNotValidException("Cannot manage a 'start chat' request: chat feature is not enabled!")

        val bandyerChatIntent = BandyerChatIntentBuilder(bandyerCordovaPlugin.cordova.activity, bandyerSDKConfiguration!!, args).build()
        bandyerCordovaPlugin.cordova.startActivityForResult(bandyerCordovaPlugin, bandyerChatIntent, BandyerCordovaPluginConstants.INTENT_REQUEST_CHAT_CODE)
    }

    fun addUserDetails(args: JSONArray) {
        val userDetails = args.optJSONObject(0).optJSONArray(BandyerCordovaPluginConstants.ARG_USERS_DETAILS)
                ?: JSONArray()

        addUserDetailsLoop@ for (i in 0 until userDetails.length()) {
            val userJsonDetails = userDetails.getJSONObject(i)

            val userAlias = userJsonDetails.optString(ARG_USER_DETAILS_ALIAS)

            if (userAlias == "") continue@addUserDetailsLoop

            val userDetailsBuilder = UserDetails.Builder(userAlias)

            userJsonDetails?.optString(ARG_USER_DETAILS_NICKNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withNickName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_FIRSTNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withFirstName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_LASTNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withLastName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_EMAIL)?.takeIf { it != "" }?.let { userDetailsBuilder.withEmail(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_IMAGEURL)?.takeIf { it != "" }?.let { userDetailsBuilder.withImageUrl(it) }

            usersDetailMap[userAlias] = userDetailsBuilder.build()
        }
    }

    fun callError(reason: String) = sendEvent(Events.CallError.name, reason)

    fun chatError(reason: String) = sendEvent(Events.ChatError.name, reason)

    fun clearUserDetails() = usersDetailMap.clear()


    private fun notifyStatusChange(bandyerModule: BandyerModule, cordovaPluginStatus: BandyerCordovaPluginStatus) {
        when (bandyerModule) {
            is ChatModule -> sendEvent(Events.ChatModuleStatusChanged.name, cordovaPluginStatus.name.toLowerCase())
            is CallModule -> sendEvent(Events.CallModuleStatusChanged.name, cordovaPluginStatus.name.toLowerCase())
        }
    }
}