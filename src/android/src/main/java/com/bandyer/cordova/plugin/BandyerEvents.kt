package com.bandyer.cordova.plugin

/**
 * This enum defines all the events that may be handled
 * <br/>
 * <br/>
 * You can listen to these events via [[BandyerPlugin.on]]
 */
enum class Events {
    CallError,
    CallModuleStatusChanged,
    ChatError,
    ChatModuleStatusChanged,
    SetupError
}
