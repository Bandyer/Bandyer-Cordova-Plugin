package it.reply.bandyerplugin;

public class PluginMethodNotValidException extends Exception {


    public PluginMethodNotValidException(String s) {
        super(s);
    }

    public PluginMethodNotValidException(String s, Throwable t) {
        super(s, t);
    }

}
