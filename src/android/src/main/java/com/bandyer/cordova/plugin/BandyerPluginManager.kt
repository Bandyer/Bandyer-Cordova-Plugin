package com.bandyer.cordova.plugin

import android.app.Application
import android.util.Log
import com.bandyer.android_sdk.BandyerSDK
import com.bandyer.android_sdk.Environment
import com.bandyer.android_sdk.call.CallModule
import com.bandyer.android_sdk.chat.ChatModule
import com.bandyer.android_sdk.client.BandyerSDKClient
import com.bandyer.android_sdk.client.BandyerSDKClientObserver
import com.bandyer.android_sdk.client.BandyerSDKClientOptions
import com.bandyer.android_sdk.client.BandyerSDKClientState
import com.bandyer.android_sdk.intent.BandyerIntent
import com.bandyer.android_sdk.intent.call.CallIntentOptions
import com.bandyer.android_sdk.module.BandyerModule
import com.bandyer.android_sdk.module.BandyerModuleObserver
import com.bandyer.android_sdk.module.BandyerModuleStatus
import com.bandyer.android_sdk.utils.BandyerSDKLogger
import com.bandyer.android_sdk.utils.provider.OnUserInformationProviderListener
import com.bandyer.android_sdk.utils.provider.UserContactProvider
import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_ALIAS
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_EMAIL
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_FIRSTNAME
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_IMAGEURL
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_LASTNAME
import com.bandyer.cordova.plugin.Constants.ARG_USER_DETAILS_NICKNAME
import com.bandyer.cordova.plugin.Constants.BANDYER_LOG_TAG
import com.bandyer.cordova.plugin.extensions.toCordovaModuleStatus
import com.bandyer.cordova.plugin.input.*
import com.bandyer.cordova.plugin.listeners.PluginCallNotificationListener
import com.bandyer.cordova.plugin.listeners.PluginChatNotificationListener
import org.json.JSONArray
import java.util.*

object BandyerPluginManager {

    private var myInitInput: InitInput? = null
    private val usersDetailMap = HashMap<String, UserDetails>()

    private val moduleObserver = object : BandyerModuleObserver {
        override fun onModuleReady(module: BandyerModule) {}
        override fun onModulePaused(module: BandyerModule) {}
        override fun onModuleFailed(module: BandyerModule, throwable: Throwable) {}
        override fun onModuleStatusChanged(module: BandyerModule, moduleStatus: BandyerModuleStatus) {
            moduleStatus.toCordovaModuleStatus()?.let { cordovaModuleStatus ->
                notifyStatusChange(module, cordovaModuleStatus)
            }
        }
    }
    private var currentBandyerPlugin: BandyerPlugin? = null

    val currentState: String
        get() = convertToString(BandyerSDKClient.getInstance().state)

    val isLogEnabled: Boolean
        get() = myInitInput != null && myInitInput!!.isLogEnabled

    fun setup(application: Application, input: InitInput) {
        val builder = BandyerSDK.Builder(application, input.appId!!)
        if (input.isProdEnvironment) {
            builder.setEnvironment(Environment.production())
        } else if (input.isSandoboxEnvironment) {
            builder.setEnvironment(Environment.sandbox())
        }
        if (input.isCallEnabled) {
            builder.withCallEnabled(PluginCallNotificationListener(application, input))
        }
        if (input.isWhiteboardEnabled) {
            builder.withWhiteboardEnabled()
        }
        if (input.isFileSharingEnabled) {
            builder.withFileSharingEnabled()
        }
        if (input.isScreenSharingEnabled) {
            builder.withScreenSharingEnabled()
        }


        if (input.isChatEnabled) {
            builder.withChatEnabled(PluginChatNotificationListener(application, input))
        }
        if (input.isLogEnabled) {
            builder.setLogger(object : BandyerSDKLogger() {

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
        }
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

        myInitInput = input
        BandyerSDK.init(builder)
    }

    fun start(input: StartInput) {
        if (BandyerSDKClient.getInstance().state != BandyerSDKClientState.UNINITIALIZED) {
            return
        }
        val options = BandyerSDKClientOptions.Builder()
                .keepListeningForEventsInBackground(false)
                .build()
        addObservers()
        BandyerSDKClient.getInstance().init(input.userAlias!!, options)
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
        BandyerSDKClient.getInstance().addModuleObserver(moduleObserver)
    }

    private fun removeObservers() {
        BandyerSDKClient.getInstance().removeModuleObserver(moduleObserver)
    }

    fun handlePushNotificationPayload(application: Application, payload: String) {
        BandyerSDKClient.getInstance().handleNotification(application, payload)
    }

    @Throws(PluginMethodNotValidException::class)
    fun startCall(bandyerPlugin: BandyerPlugin, input: StartCallInput) {
        if (myInitInput == null) {
            throw PluginMethodNotValidException("A setup method call is needed before a call operation")
        }
        val isCallEnabled = myInitInput!!.isCallEnabled
        val isChatEnabled = myInitInput!!.isChatEnabled
        val isWhiteboardEnabled = myInitInput!!.isWhiteboardEnabled
        val isFileSharingEnabled = myInitInput!!.isFileSharingEnabled
        val isScreenSharingEnabled = myInitInput!!.isScreenSharingEnabled
        if (isCallEnabled) {
            val isJoinCall = input.hasJoinUrl()
            val builder = BandyerIntent.Builder()
            val options: CallIntentOptions
            if (isJoinCall) {
                options = builder.startFromJoinCallUrl(bandyerPlugin.cordova.activity, input.joinUrl!!)
            } else {
                val calleeList = input.calleeList
                if (input.callType == CallType.AUDIO) {
                    options = builder.startWithAudioCall(bandyerPlugin.cordova.activity,
                            input.isRecordingEnabled)
                            .with(calleeList)
                } else if (input.callType == CallType.AUDIO_UPGRADABLE) {
                    options = builder.startWithAudioUpgradableCall(bandyerPlugin.cordova.activity,
                            input.isRecordingEnabled)
                            .with(calleeList)
                } else {
                    options = builder
                            .startWithAudioVideoCall(bandyerPlugin.cordova.activity,
                                    input.isRecordingEnabled /* call recording */)
                            .with(calleeList)
                }
            }
            if (isChatEnabled) {
                options.withChatCapability()
            }
            if (isWhiteboardEnabled) {
                options.withWhiteboardCapability()
            }
            if (isFileSharingEnabled) {
                options.withFileSharingCapability()
            }
            if (isScreenSharingEnabled) {
                options.withScreenSharingCapability()
            }
            val callBackIntent = options.build()
            bandyerPlugin.cordova.activity.startActivityForResult(callBackIntent, Constants.INTENT_REQUEST_CALL_CODE)
        } else {
            throw PluginMethodNotValidException("Cannot manage a 'start call' request: call feature is not enabled!")
        }

    }

    @Throws(PluginMethodNotValidException::class)
    fun startChat(bandyerPlugin: BandyerPlugin, input: StartChatInput) {
        if (myInitInput == null) {
            throw PluginMethodNotValidException("A setup method call is needed before a chat operation")
        }
        val chatEnabled = myInitInput!!.isChatEnabled
        val callEnabled = myInitInput!!.isCallEnabled
        val whiteboardEnabled = myInitInput!!.isWhiteboardEnabled
        val fileSharingEnabled = myInitInput!!.isFileSharingEnabled
        val screenSharingEnabled = myInitInput!!.isScreenSharingEnabled
        if (chatEnabled) {
            val userAlias = input.userAlias
            val intentOptions = BandyerIntent.Builder()
                    .startWithChat(bandyerPlugin.cordova.activity)
                    .with(userAlias)

            if (input.callType == CallType.AUDIO) {
                if (callEnabled) {
                    intentOptions.withAudioCallCapability(input.isRecordingEnabled)
                }
            } else if (input.callType == CallType.AUDIO_UPGRADABLE) {
                if (callEnabled) {
                    intentOptions.withAudioUpgradableCallCapability(input.isRecordingEnabled)
                }
            } else if (input.callType == CallType.AUDIO_VIDEO) {
                if (callEnabled) {
                    intentOptions.withAudioVideoCallCapability(input.isRecordingEnabled)
                }
            } else {
                //chat only
            }

            if (whiteboardEnabled) {
                intentOptions.withWhiteboardInCallCapability()
            }
            if (fileSharingEnabled) {
                intentOptions.withFileSharingInCallCapability()
            }
            if (screenSharingEnabled) {
                intentOptions.withScreenSharingInCallCapability()
            }
            val callBackIntent = intentOptions.build()
            bandyerPlugin.cordova.activity.startActivityForResult(callBackIntent, Constants.INTENT_REQUEST_CHAT_CODE)
        } else {
            throw PluginMethodNotValidException("Cannot manage a 'start chat' request: chat feature is not enabled!")
        }
    }

    fun addUserDetails(input: JSONArray) {
        loop@ for (i in 0 until input.length()) {
            val userJsonDetails = input.getJSONObject(i)

            val userAlias = userJsonDetails.optString(ARG_USER_DETAILS_ALIAS)

            if (userAlias == "") continue@loop

            val userDetailsBuilder = UserDetails.Builder(userAlias)

            userJsonDetails?.optString(ARG_USER_DETAILS_NICKNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withNickName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_FIRSTNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withFirstName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_LASTNAME)?.takeIf { it != "" }?.let { userDetailsBuilder.withLastName(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_EMAIL)?.takeIf { it != "" }?.let { userDetailsBuilder.withEmail(it) }
            userJsonDetails?.optString(ARG_USER_DETAILS_IMAGEURL)?.takeIf { it != "" }?.let { userDetailsBuilder.withImageUrl(it) }

            usersDetailMap[userAlias] = userDetailsBuilder.build()
        }
    }

    fun clearUserDetails() {
        usersDetailMap.clear()
    }

    private fun notifyStatusChange(bandyerModule: BandyerModule, cordovaModuleStatus: CordovaModuleStatus) {
        currentBandyerPlugin ?: return
        currentBandyerPlugin!!.cordova.activity.runOnUiThread {
            when (bandyerModule) {
                is ChatModule -> currentBandyerPlugin!!.webView.loadUrl("javascript:window.BandyerPlugin.chatClientListener('${cordovaModuleStatus.name.toLowerCase()}')")
                is CallModule -> currentBandyerPlugin!!.webView.loadUrl("javascript:window.BandyerPlugin.callClientListener('${cordovaModuleStatus.name.toLowerCase()}')")
            }
        }
    }

    fun setCurrentPlugin(bandyerPlugin: BandyerPlugin) {
        currentBandyerPlugin = bandyerPlugin
    }
}