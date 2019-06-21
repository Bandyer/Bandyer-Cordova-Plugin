package com.bandyer.cordova.plugin

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.util.Log

import com.bandyer.android_sdk.client.BandyerSDKClientObserver
import com.bandyer.android_sdk.client.BandyerSDKClientState
import com.bandyer.android_sdk.module.BandyerModule
import com.bandyer.android_sdk.module.BandyerModuleObserver
import com.bandyer.android_sdk.module.BandyerModuleStatus

import org.apache.cordova.CordovaInterface
import org.apache.cordova.CordovaPlugin
import org.apache.cordova.CallbackContext

import org.apache.cordova.CordovaWebView
import org.json.JSONArray

import com.bandyer.cordova.plugin.input.HandleNotificationInput
import com.bandyer.cordova.plugin.input.InitInput
import com.bandyer.cordova.plugin.input.StartCallInput
import com.bandyer.cordova.plugin.input.StartChatInput
import com.bandyer.cordova.plugin.input.StartInput
import com.bandyer.cordova.plugin.input.UserContactDetailInput

import com.bandyer.cordova.plugin.Constants.METHOD_ADD_CALL_CLIENT_LISTENER
import com.bandyer.cordova.plugin.Constants.METHOD_CLEAR_USER_CACHE
import com.bandyer.cordova.plugin.Constants.METHOD_CLEAR_USER_DETAILS
import com.bandyer.cordova.plugin.Constants.METHOD_HANDLE_NOTIFICATION
import com.bandyer.cordova.plugin.Constants.METHOD_HANDLE_SET_USER_DETAILS
import com.bandyer.cordova.plugin.Constants.METHOD_INITIALIZE
import com.bandyer.cordova.plugin.Constants.METHOD_MAKE_CALL
import com.bandyer.cordova.plugin.Constants.METHOD_MAKE_CHAT
import com.bandyer.cordova.plugin.Constants.METHOD_PAUSE
import com.bandyer.cordova.plugin.Constants.METHOD_REMOVE_CALL_CLIENT_LISTENER
import com.bandyer.cordova.plugin.Constants.METHOD_RESUME
import com.bandyer.cordova.plugin.Constants.METHOD_START
import com.bandyer.cordova.plugin.Constants.METHOD_STATE
import com.bandyer.cordova.plugin.Constants.METHOD_STOP

class BandyerPlugin : CordovaPlugin() {

    private var mChatCallback: CallbackContext? = null
    private var mCallCallback: CallbackContext? = null

    private val application: Application
        get() = this.cordova.activity.application

    override fun execute(action: String, args: JSONArray, callbackContext: CallbackContext): Boolean {
        if (action == METHOD_INITIALIZE) {
            this.setup(args, callbackContext)
            return true
        } else if (action == METHOD_ADD_CALL_CLIENT_LISTENER) {
            this.addObservers(callbackContext)
            return true
        } else if (action == METHOD_REMOVE_CALL_CLIENT_LISTENER) {
            this.removeObservers(callbackContext)
            return true
        } else if (action == METHOD_START) {
            this.start(args, callbackContext)
            return true
        } else if (action == METHOD_RESUME) {
            this.resume(callbackContext)
            return true
        } else if (action == METHOD_PAUSE) {
            this.pause(callbackContext)
            return true
        } else if (action == METHOD_STOP) {
            this.stop(callbackContext)
            return true
        } else if (action == METHOD_STATE) {
            this.getCurrentState(callbackContext)
            return true
        } else if (action == METHOD_MAKE_CALL) {
            this.startCall(args, callbackContext)
            return true
        } else if (action == METHOD_MAKE_CHAT) {
            this.startChat(args, callbackContext)
            return true
        } else if (action == METHOD_HANDLE_NOTIFICATION) {
            this.handleNotification(args, callbackContext)
            return true
        } else if (action == METHOD_CLEAR_USER_CACHE) {
            this.clearUserCache(callbackContext)
            return true
        } else if (action == METHOD_HANDLE_SET_USER_DETAILS) {
            this.setUserDetails(args, callbackContext)
            return true
        } else if (action == METHOD_CLEAR_USER_DETAILS) {
            this.clearUserDetails(callbackContext)
            return true
        }
        return false
    }

    override fun pluginInitialize() {
        super.pluginInitialize()
        BandyerPluginManager.setCurrentPlugin(this)
    }

    private fun setup(args: JSONArray, callbackContext: CallbackContext) {
        val application = application
        try {
            BandyerPluginManager.setup(application, InitInput.createFrom(args))
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun start(args: JSONArray, callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.start(StartInput.createFrom(args))
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun resume(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.resume()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun pause(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.pause()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun stopListening(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.stopListening()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun stop(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.stop()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun getCurrentState(callbackContext: CallbackContext) {
        try {
            val currentState = BandyerPluginManager.currentState
            callbackContext.success(currentState)
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun clearUserCache(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.clearUserCache()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun clearUserDetails(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.clearUserDetails()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun addObservers(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.addObservers()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun removeObservers(callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.removeObservers()
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun handleNotification(args: JSONArray, callbackContext: CallbackContext) {
        try {
            BandyerPluginManager.handleNotification(application, HandleNotificationInput.createFrom(args))
            callbackContext.success()
        } catch (e: Throwable) {
            callbackContext.error(e.message)
        }

    }

    private fun startCall(args: JSONArray, callbackContext: CallbackContext) {
        try {
            mCallCallback = callbackContext
            BandyerPluginManager.startCall(this,
                    StartCallInput.createFrom(args))
        } catch (e: Throwable) {
            mCallCallback = null
            callbackContext.error(e.message)
        }

    }

    private fun startChat(args: JSONArray, callbackContext: CallbackContext) {
        try {
            mCallCallback = callbackContext
            BandyerPluginManager.startChat(this,
                    StartChatInput.createFrom(args))
        } catch (e: Throwable) {
            mCallCallback = null
            callbackContext.error(e.message)
        }

    }

    private fun setUserDetails(args: JSONArray, callbackContext: CallbackContext) {
        try {
            mCallCallback = callbackContext
            BandyerPluginManager.setUserDetails(UserContactDetailInput.createFrom(args))
        } catch (e: Throwable) {
            mCallCallback = null
            callbackContext.error(e.message)
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?) {
        super.onActivityResult(requestCode, resultCode, intent)
        if (resultCode == Activity.RESULT_CANCELED) {
            if (intent == null) {
                return
            }
            val error = if (intent.extras != null) intent.extras!!.getString("error", "error") else "error"
            if (requestCode == Constants.INTENT_REQUEST_CALL_CODE) {
                if (BandyerPluginManager.isLogEnabled) {
                    Log.d(Constants.BANDYER_LOG_TAG, "Error on call request: $error")
                }
                if (mCallCallback != null) {
                    mCallCallback!!.error(error)
                    mCallCallback = null
                }
            } else if (requestCode == Constants.INTENT_REQUEST_CHAT_CODE) {
                if (BandyerPluginManager.isLogEnabled) {
                    Log.d(Constants.BANDYER_LOG_TAG, "Error on chat request: $error")
                }
                if (mChatCallback != null) {
                    mChatCallback!!.error(error)
                    mChatCallback = null
                }
            }
        } else {
            if (requestCode == Constants.INTENT_REQUEST_CALL_CODE) {
                if (mCallCallback != null) {
                    mCallCallback!!.success()
                    mCallCallback = null
                }
            } else if (requestCode == Constants.INTENT_REQUEST_CHAT_CODE) {
                if (mChatCallback != null) {
                    mChatCallback!!.success()
                    mChatCallback = null
                }
            }
        }
    }
}
