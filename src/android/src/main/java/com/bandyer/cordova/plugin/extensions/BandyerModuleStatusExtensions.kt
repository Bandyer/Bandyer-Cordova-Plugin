package com.bandyer.cordova.plugin.extensions

import com.bandyer.android_sdk.module.BandyerModuleStatus
import com.bandyer.cordova.plugin.CordovaModuleStatus

fun BandyerModuleStatus.toCordovaModuleStatus(): CordovaModuleStatus? = when (this) {
    BandyerModuleStatus.INITIALIZING -> null
    BandyerModuleStatus.CONNECTING -> null
    BandyerModuleStatus.CONNECTED -> null
    BandyerModuleStatus.RECONNECTING  -> CordovaModuleStatus.Reconnecting
    BandyerModuleStatus.DISCONNECTED -> null
    BandyerModuleStatus.READY -> CordovaModuleStatus.Ready
    BandyerModuleStatus.PAUSED -> CordovaModuleStatus.Paused
    BandyerModuleStatus.FAILED -> CordovaModuleStatus.Failed
    BandyerModuleStatus.DESTROYED -> CordovaModuleStatus.Stopped
}