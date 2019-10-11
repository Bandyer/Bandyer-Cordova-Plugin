package com.bandyer.cordova.plugin

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.util.Log
import com.bandyer.android_common.logging.BaseLogger
import com.bandyer.android_sdk.BandyerSDK
import com.bandyer.android_sdk.Environment
import com.bandyer.android_sdk.call.CallModule
import com.bandyer.android_sdk.chat.ChatModule
import com.bandyer.android_sdk.client.BandyerSDKClient
import com.bandyer.android_sdk.client.BandyerSDKClientObserver
import com.bandyer.android_sdk.client.BandyerSDKClientOptions
import com.bandyer.android_sdk.client.BandyerSDKClientState
import com.bandyer.android_sdk.module.BandyerModule
import com.bandyer.android_sdk.module.BandyerModuleObserver
import com.bandyer.android_sdk.module.BandyerModuleStatus
import com.bandyer.android_sdk.utils.BandyerSDKLogger
import com.bandyer.android_sdk.utils.provider.OnUserInformationProviderListener
import com.bandyer.android_sdk.utils.provider.UserContactProvider
import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_ALIAS
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_EMAIL
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_FIRSTNAME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_IMAGEURL
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_LASTNAME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.ARG_USER_DETAILS_NICKNAME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.BANDYER_LOG_TAG
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginExceptions
import com.bandyer.cordova.plugin.exceptions.BandyerCordovaPluginMethodNotValidException
import com.bandyer.cordova.plugin.extensions.toCordovaModuleStatus
import com.bandyer.cordova.plugin.intent.BandyerCallIntentBuilder
import com.bandyer.cordova.plugin.intent.BandyerChatIntentBuilder
import com.bandyer.cordova.plugin.listeners.BandyerCordovaPluginCallNotificationListener
import com.bandyer.cordova.plugin.listeners.BandyerCordovaPluginChatNotificationListener
import org.apache.cordova.CallbackContext
import org.apache.cordova.PluginResult
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class BandyerCordovaPluginManager(var bandyerCallbackContext: CallbackContext?) {

    private var bandyerSDKConfiguration: BandyerSDKConfiguration? = null

    private val usersDetailMap = HashMap<String, UserDetails>()

    private val moduleObserver = object : BandyerModuleObserver {
        override fun onModuleReady(module: BandyerModule) {}
        override fun onModulePaused(module: BandyerModule) {}
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

        override fun onClientReady() {

        }

        override fun onClientStatusChange(state: BandyerSDKClientState) {

        }

        override fun onClientStopped() {

        }

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

        val builder = BandyerSDK.Builder(application, bandyerSDKConfiguration!!.appId!!)
        if (bandyerSDKConfiguration!!.isProdEnvironment) {
            builder.setEnvironment(Environment.production())
        } else if (bandyerSDKConfiguration!!.isSandoboxEnvironment) {
            builder.setEnvironment(Environment.sandbox())
        }

        if (bandyerSDKConfiguration!!.isCallEnabled)
            builder.withCallEnabled(BandyerCordovaPluginCallNotificationListener(application, bandyerSDKConfiguration!!))

        if (bandyerSDKConfiguration!!.isWhiteboardEnabled)
            builder.withWhiteboardEnabled()

        if (bandyerSDKConfiguration!!.isFileSharingEnabled)
            builder.withFileSharingEnabled()

        if (bandyerSDKConfiguration!!.isScreenSharingEnabled)
            builder.withScreenSharingEnabled()

        if (bandyerSDKConfiguration!!.isChatEnabled)
            builder.withChatEnabled(BandyerCordovaPluginChatNotificationListener(application, bandyerSDKConfiguration!!))

        if (bandyerSDKConfiguration!!.isLogEnabled)
            builder.setLogger(object : BandyerSDKLogger(BaseLogger.VERBOSE) {
                override fun warn(tag: String, message: String) {
                    Log.w(BANDYER_LOG_TAG, message)
                }

                override fun verbose(tag: String, message: String) {
                    Log.v(BANDYER_LOG_TAG, message)
                }

                override fun info(tag: String, message: String) {
                    Log.i(BANDYER_LOG_TAG, message)
                }

                override fun error(tag: String, message: String) {
                    Log.e(BANDYER_LOG_TAG, message)
                }

                override fun debug(tag: String, message: String) {
                    Log.d(BANDYER_LOG_TAG, message)
                }
            })

        builder.withUserContactProvider(object : UserContactProvider {
            override fun provideUserDetails(userAliases: List<String>, onProviderListener: OnUserInformationProviderListener<UserDetails>) {
                // provide results on the OnUserInformationProviderListener object
                val details = mutableListOf<UserDetails>()
                userAliases.forEach { userAlias ->
                    if (usersDetailMap.containsKey(userAlias)) details.add(usersDetailMap[userAlias]!!)
                    else details.add(UserDetails.Builder(userAlias).build())
                }
                onProviderListener.onProvided(details)
            }
        })
        BandyerSDK.init(builder)
    }

    @Throws(BandyerCordovaPluginExceptions::class)
    fun start(activity: Activity, args: JSONArray) {
        if (BandyerSDKClient.getInstance().state != BandyerSDKClientState.UNINITIALIZED) {
            clearUserCache()
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

    fun clearUserCache() {
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

    fun callError(reason: String) {
        sendEvent(Events.CallError.name, reason)
    }

    fun chatError(reason: String) {
        sendEvent(Events.ChatError.name, reason)
    }

    fun clearUserDetails() {
        usersDetailMap.clear()
    }

    private fun notifyStatusChange(bandyerModule: BandyerModule, cordovaPluginStatus: BandyerCordovaPluginStatus) {
        when (bandyerModule) {
            is ChatModule -> sendEvent(Events.ChatModuleStatusChanged.name, cordovaPluginStatus.name.toLowerCase())
            is CallModule -> sendEvent(Events.CallModuleStatusChanged.name, cordovaPluginStatus.name.toLowerCase())
        }
    }
}