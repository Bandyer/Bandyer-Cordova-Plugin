package com.bandyer.cordova.plugin.utils

import android.os.HandlerThread
import com.badoo.mobile.util.WeakHandler

/**
 * @suppress
 * @author kristiyan
 */

internal val ioThread by lazy {
    val mHandlerThread = HandlerThread("user_details_ioThread")
    mHandlerThread.start()
    WeakHandler(mHandlerThread.looper)
}

/**
 * @suppress
 * Utility method to run blocks on a dedicated background thread, used for io/database work.
 */
internal fun IO(func: () -> Unit) = run(ioThread, func)

internal fun run(handler: WeakHandler?, vararg functions: () -> Unit) {
    if (handler == null) {
        functions.forEach { it.invoke() }
        return
    }
    functions.forEach { handler.post(it) }
}