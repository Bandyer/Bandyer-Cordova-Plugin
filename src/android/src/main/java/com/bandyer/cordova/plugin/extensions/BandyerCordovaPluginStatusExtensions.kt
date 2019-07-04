package com.bandyer.cordova.plugin.extensions

import com.bandyer.android_sdk.module.BandyerModuleStatus
import com.bandyer.cordova.plugin.BandyerCordovaPluginStatus

fun BandyerModuleStatus.toCordovaModuleStatus(): BandyerCordovaPluginStatus? = when (this) {
    BandyerModuleStatus.INITIALIZING -> null
    BandyerModuleStatus.CONNECTING -> null
    BandyerModuleStatus.CONNECTED -> null
    BandyerModuleStatus.RECONNECTING  -> BandyerCordovaPluginStatus.Reconnecting
    BandyerModuleStatus.DISCONNECTED -> null
    BandyerModuleStatus.READY -> BandyerCordovaPluginStatus.Ready
    BandyerModuleStatus.PAUSED -> BandyerCordovaPluginStatus.Paused
    BandyerModuleStatus.FAILED -> BandyerCordovaPluginStatus.Failed
    BandyerModuleStatus.DESTROYED -> BandyerCordovaPluginStatus.Stopped
}