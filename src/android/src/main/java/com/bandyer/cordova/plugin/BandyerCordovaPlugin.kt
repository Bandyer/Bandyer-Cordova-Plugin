package com.bandyer.cordova.plugin

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.util.Log
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
                else ->
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

    private fun initializeBandyer(args: JSONArray, callbackContext: CallbackContext) {
        bandyerCallbackContext = callbackContext
        bandyerCordovaPluginManager?.bandyerCallbackContext = callbackContext
        bandyerCordovaPluginManager!!.setup(application, args)
        cordova.setActivityResultCallback(this)
    }

    private fun start(args: JSONArray, callbackContext: CallbackContext) {
        bandyerCordovaPluginManager!!.start(args)
    }

    private fun resume(callbackContext: CallbackContext) {
        bandyerCordovaPluginManager!!.resume()
    }

    private fun pause(callbackContext: CallbackContext) {
        bandyerCordovaPluginManager!!.pause()
    }

    private fun stop(callbackContext: CallbackContext) {
        bandyerCordovaPluginManager!!.stop()
    }

    private fun state(callbackContext: CallbackContext) {
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

    private fun startCall(args: JSONArray, callbackContext: CallbackContext) {
        bandyerCordovaPluginManager!!.startCall(this, args)
    }

    private fun startChat(args: JSONArray, callbackContext: CallbackContext) {
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

    private fun clearUsersDetails(callbackContext: CallbackContext) {
        try {
            bandyerCordovaPluginManager!!.clearUserDetails()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        intent ?: return
        if (resultCode != Activity.RESULT_CANCELED) return
        val error = intent.extras?.getString("error", "error") ?: "error"
        Log.e("onActivityResult", "requestCode: $requestCode, resultCode: $resultCode, error: $error")
        when (requestCode) {
            BandyerCordovaPluginConstants.INTENT_REQUEST_CALL_CODE -> {
                bandyerCordovaPluginManager?.callError(error)
            }
            BandyerCordovaPluginConstants.INTENT_REQUEST_CHAT_CODE -> {
                bandyerCordovaPluginManager?.chatError(error)
            }
        }
    }
}
