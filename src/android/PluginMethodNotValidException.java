package com.bandyer.cordova.plugin;

public class PluginMethodNotValidException extends Exception {

    private static final long serialVersionUID = 123L;

    public PluginMethodNotValidException(String s) {
        super(s);
    }

    public PluginMethodNotValidException(String s, Throwable t) {
        super(s, t);
    }

}
