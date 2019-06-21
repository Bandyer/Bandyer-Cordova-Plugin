package com.bandyer.cordova.plugin

class PluginMethodNotValidException : Exception {

    constructor(s: String) : super(s) {}

    constructor(s: String, t: Throwable) : super(s, t) {}

    companion object {

        private val serialVersionUID = 123L
    }

}
