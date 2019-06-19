package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import com.bandyer.cordova.plugin.Constants;

public class StartInput {

    private String mUserAlias;

    public static StartInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        StartInput startInput = new StartInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            String username = args.getString(Constants.ARG_USER_ALIAS);
            if(username == null || username.equals("")) {
                throw new PluginInputNotValidException(Constants.ARG_USER_ALIAS + " cannot be null");
            }
            startInput.setUserAlias(username);

            return startInput;
        }catch (Throwable t) {
            throw new PluginInputNotValidException("error on StartInput " + t.getMessage(), t);
        }
    }

    public String getUserAlias() {
        return mUserAlias;
    }

    public void setUserAlias(String userAlias) {
        mUserAlias = userAlias;
    }
}
