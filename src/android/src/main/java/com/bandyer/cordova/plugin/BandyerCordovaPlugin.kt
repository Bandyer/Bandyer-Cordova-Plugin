package com.bandyer.cordova.plugin

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.util.Log
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_ADD_USERS_DETAILS
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_CLEAR_USER_CACHE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_HANDLE_NOTIFICATION
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_INITIALIZE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_PAUSE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_REMOVE_USERS_DETAILS
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_RESUME
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_START
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_START_CALL
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_START_CHAT
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_STATE
import com.bandyer.cordova.plugin.BandyerCordovaPluginConstants.METHOD_STOP
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaArgs
import org.apache.cordova.CordovaPlugin
import org.json.JSONArray

class BandyerCordovaPlugin : CordovaPlugin() {

    private var mChatCallback: CallbackContext? = null
    private var mCallCallback: CallbackContext? = null

    private val application: Application
        get() = this.cordova.activity.application

    private var bandyerCordovaPluginManager: BandyerCordovaPluginManager? = null
    private var bandyerCallbackContext: CallbackContext? = null


    override fun execute(action: String?, rawArgs: String?, callbackContext: CallbackContext?): Boolean {
        return super.execute(action, rawArgs, callbackContext)
    }

    override fun execute(action: String?, args: CordovaArgs?, callbackContext: CallbackContext?): Boolean {
        return super.execute(action, args, callbackContext)
    }

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        when (action) {
            METHOD_INITIALIZE -> {
                bandyerCallbackContext = callbackContext
                bandyerCordovaPluginManager?.bandyerCallbackContext = callbackContext
                this.setup(args)
                return true
            }
            METHOD_START -> {
                this.start(args)
                return true
            }
            METHOD_RESUME -> {
                this.resume()
                return true
            }
            METHOD_PAUSE -> {
                this.pause()
                return true
            }
            METHOD_STOP -> {
                this.stop()
                return true
            }
            METHOD_STATE -> {
                this.getCurrentState(callbackContext)
                return true
            }
            METHOD_START_CALL -> {
                this.startCall(args)
                return true
            }
            METHOD_START_CHAT -> {
                this.startChat(args)
                return true
            }
            METHOD_HANDLE_NOTIFICATION -> {
                this.handlePushNotificationPayload(args, callbackContext)
                return true
            }
            METHOD_CLEAR_USER_CACHE -> {
                this.clearUserCache(callbackContext)
                return true
            }
            METHOD_ADD_USERS_DETAILS -> {
                this.addUsersDetails(args, callbackContext)
                return true
            }
            METHOD_REMOVE_USERS_DETAILS -> {
                this.removeUsersDetails(callbackContext)
                return true
            }
            else -> return false
        }
    }

    override fun pluginInitialize() {
        super.pluginInitialize()
        Log.e("CordovaPlugin","pluginInitialize $bandyerCallbackContext")
        bandyerCordovaPluginManager = BandyerCordovaPluginManager(bandyerCallbackContext)
        bandyerCordovaPluginManager!!.setCurrentPlugin(this)
    }

    private fun setup(args: JSONArray) {
        bandyerCordovaPluginManager!!.setup(application, args)
    }

    private fun start(args: JSONArray) {
        bandyerCordovaPluginManager!!.start(args)
    }

    private fun resume() {
        bandyerCordovaPluginManager!!.resume()
    }

    private fun pause() {
        bandyerCordovaPluginManager!!.pause()
    }

    private fun stop() {
        bandyerCordovaPluginManager!!.stop()
    }

    private fun getCurrentState(callbackContext: CallbackContext) {
        try {
            val currentState = bandyerCordovaPluginManager!!.currentState
            callbackContext.success(currentState)
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun clearUserCache(callbackContext: CallbackContext) {
        try {
            bandyerCordovaPluginManager!!.clearUserCache()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun handlePushNotificationPayload(args: JSONArray, callbackContext: CallbackContext) {
        try {
            bandyerCordovaPluginManager!!.handlePushNotificationPayload(application, args)
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun startCall(args: JSONArray) {
        bandyerCordovaPluginManager!!.startCall(this, args)
    }

    private fun startChat(args: JSONArray) {
        bandyerCordovaPluginManager!!.startChat(this, args)
    }

    private fun addUsersDetails(args: JSONArray, callbackContext: CallbackContext) {
        try {
            mCallCallback = callbackContext
            if (args.length() == 0) return
            bandyerCordovaPluginManager!!.addUserDetails(args)
        } catch (e: Throwable) {
            mCallCallback = null
            callbackContext.error(e.message)
        }
    }

    private fun removeUsersDetails(callbackContext: CallbackContext) {
        try {
            bandyerCordovaPluginManager!!.clearUserDetails()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        if (resultCode == Activity.RESULT_CANCELED) {

            if (intent == null) return

            val error = if (intent.extras != null) intent.extras!!.getString("error", "error") else "error"

            if (requestCode == BandyerCordovaPluginConstants.INTENT_REQUEST_CALL_CODE) {

                if (bandyerCordovaPluginManager!!.isLogEnabled)
                    Log.d(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, "Error on call request: $error")

                if (mCallCallback != null) {
                    mCallCallback!!.error(error)
                    mCallCallback = null
                }
            } else if (requestCode == BandyerCordovaPluginConstants.INTENT_REQUEST_CHAT_CODE) {
                if (bandyerCordovaPluginManager!!.isLogEnabled)
                    Log.d(BandyerCordovaPluginConstants.BANDYER_LOG_TAG, "Error on chat request: $error")

                if (mChatCallback != null) {
                    mChatCallback!!.error(error)
                    mChatCallback = null
                }
            }
        } else {
            if (requestCode == BandyerCordovaPluginConstants.INTENT_REQUEST_CALL_CODE) {
                if (mCallCallback != null) {
                    mCallCallback!!.success()
                    mCallCallback = null
                }
            } else if (requestCode == BandyerCordovaPluginConstants.INTENT_REQUEST_CHAT_CODE) {
                if (mChatCallback != null) {
                    mChatCallback!!.success()
                    mChatCallback = null
                }
            }
        }
    }
}
