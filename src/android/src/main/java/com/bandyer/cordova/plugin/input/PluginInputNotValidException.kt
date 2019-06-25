package com.bandyer.cordova.plugin.input

class PluginInputNotValidException : Exception {


    constructor(s: String) : super(s) {}

    constructor(s: String, t: Throwable) : super(s, t) {}

}
