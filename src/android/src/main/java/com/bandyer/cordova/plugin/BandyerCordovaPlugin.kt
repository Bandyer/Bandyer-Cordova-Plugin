package com.bandyer.cordova.plugin

import android.app.Application
import org.apache.cordova.CallbackContext
import org.apache.cordova.CordovaPlugin
import org.json.JSONArray
import kotlin.reflect.jvm.isAccessible
import kotlin.reflect.jvm.kotlinFunction


@Suppress("unused", "UNUSED_PARAMETER")
class BandyerCordovaPlugin : CordovaPlugin() {

    private var mChatCallback: CallbackContext? = null
    private var mCallCallback: CallbackContext? = null

    private val application: Application
        get() = this.cordova.activity.application

    private var bandyerCordovaPluginManager: BandyerCordovaPluginManager? = null
    private var bandyerCallbackContext: CallbackContext? = null

    fun invoke(functionName: String, params: JSONArray, callbackContext: CallbackContext? = null): Boolean {
        this::class.java.declaredMethods.find { it.name == functionName }?.kotlinFunction?.let { function ->
            function.isAccessible = true
            when {
                params.length() > 0 ->
                    if (callbackContext != null) function.call(this, params, callbackContext)
                    else function.call(this, params)
                else                ->
                    if (callbackContext != null) function.call(this, callbackContext)
                    else function.call(this)
            }
            return true
        }
        return false
    }

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        if (invoke(action, args, callbackContext)) return true
        val error = """Android function not implemented!
                { 
                    "function":"$action",
                    "params":"$args"
                }
            """.trimIndent()
        callbackContext.error(error)
        return false
    }

    override fun pluginInitialize() {
        super.pluginInitialize()
        bandyerCordovaPluginManager = BandyerCordovaPluginManager(bandyerCallbackContext)
    }

    private fun initializeBandyer(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCallbackContext = callbackContext
        bandyerCordovaPluginManager?.bandyerCallbackContext = callbackContext
        bandyerCordovaPluginManager!!.setup(application, args)
        cordova.setActivityResultCallback(this)
    }

    private fun start(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.start(cordova.activity, args)
    }

    private fun resume(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.resume()
    }

    private fun pause(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.pause()
    }

    private fun stop(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.stop()
    }

    private fun state(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        try {
            val currentState = bandyerCordovaPluginManager!!.currentState
            callbackContext.success(currentState)
        }
        catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun clearUserCache(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        try {
            bandyerCordovaPluginManager!!.clearUserCache(cordova.context.applicationContext)
            callbackContext.success()
        }
        catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun handlePushNotificationPayload(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        try {
            bandyerCordovaPluginManager!!.handlePushNotificationPayload(application, args)
            callbackContext.success()
        }
        catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    private fun verifyCurrentCall(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.verifyCurrentCall(args)
    }

    private fun setDisplayModeForCurrentCall(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.setDisplayModeForCurrentCall(args)
    }

    private fun startCall(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.startCall(this, args)
    }

    private fun setUserDetailsFormat(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.setUserDetailsFormat(this, args)
    }

    private fun startChat(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        bandyerCordovaPluginManager!!.startChat(this, args)
    }

    private fun addUsersDetails(args: JSONArray, callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        try {
            mCallCallback = callbackContext
            if (args.length() == 0) return@runOnUiThread
            bandyerCordovaPluginManager!!.addUserDetails(this, args)
        }
        catch (e: Throwable) {
            mCallCallback = null
            callbackContext.error(e.message)
        }
    }

    private fun removeUsersDetails(callbackContext: CallbackContext) = cordova.activity.runOnUiThread {
        try {
            bandyerCordovaPluginManager!!.removeUsersDetails(cordova.context.applicationContext)
            callbackContext.success()
        }
        catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }
}
