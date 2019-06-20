package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import com.bandyer.cordova.plugin.Constants;

public class HandleNotificationInput {

    private String mPayload;

    public static HandleNotificationInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        HandleNotificationInput handleNotificationInput = new HandleNotificationInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            String payload = args.getString(Constants.ARG_HANDLE_NOTIFICATION);
            if(payload == null || payload.equals("")) {
                throw new PluginInputNotValidException(Constants.ARG_HANDLE_NOTIFICATION + " cannot be null");
            }
            handleNotificationInput.setPayload(payload);

            return handleNotificationInput;
        } catch (Throwable t) {
            throw new PluginInputNotValidException("error on InitInput", t);
        }
    }

    public String getPayload() {
        return mPayload;
    }

    public void setPayload(String payload) {
        mPayload = payload;
    }
}
