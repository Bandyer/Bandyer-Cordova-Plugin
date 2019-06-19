package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import com.bandyer.cordova.plugin.Constants;

public class InitInput {

    private String mAppId;
    private String mEnvironment;
    private boolean mIsCallEnabled;
    private boolean mIsFileSharingEnabled;
    private boolean mIsWhiteboardEnabled;
    private boolean mIsChatEnabled;
    private boolean mIsLogEnabled;

    public static InitInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        InitInput initInput = new InitInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            String appId = args.getString(Constants.ARG_APP_ID);
            if(appId == null || appId.equals("")) {
                throw new PluginInputNotValidException(Constants.ARG_APP_ID + " cannot be null");
            }
            initInput.setAppId(appId);
            initInput.setCallEnabled(args.getBoolean(Constants.ARG_CALL_ENABLED));
            initInput.setChatEnabled(args.getBoolean(Constants.ARG_CHAT_ENABLED));
            initInput.setEnvironment(args.getString(Constants.ARG_ENVIRONMENT));
            initInput.setFileSharingEnabled(args.getBoolean(Constants.ARG_FILE_SHARING_ENABLED));
            initInput.setWhiteboardEnabled(args.getBoolean(Constants.ARG_WHITEBOARD_ENABLED));
            initInput.setWhiteboardEnabled(args.getBoolean(Constants.ARG_WHITEBOARD_ENABLED));
            initInput.setLogEnabled(args.getBoolean(Constants.ARG_ENABLE_LOG));
            return initInput;
        }catch (Throwable t) {
            throw new PluginInputNotValidException("error on InitInput " + t.getMessage(), t);
        }

    }

    public String getAppId() {
        return mAppId;
    }

    public void setAppId(String appId) {
        mAppId = appId;
    }

    public String getEnvironment() {
        return mEnvironment;
    }

    public void setEnvironment(String environment) {
        mEnvironment = environment;
    }

    public boolean isCallEnabled() {
        return mIsCallEnabled;
    }

    public void setCallEnabled(boolean callEnabled) {
        mIsCallEnabled = callEnabled;
    }

    public boolean isFileSharingEnabled() {
        return mIsFileSharingEnabled;
    }

    public void setFileSharingEnabled(boolean fileSharingEnabled) {
        mIsFileSharingEnabled = fileSharingEnabled;
    }

    public boolean isWhiteboardEnabled() {
        return mIsWhiteboardEnabled;
    }

    public void setWhiteboardEnabled(boolean whiteboardEnabled) {
        mIsWhiteboardEnabled = whiteboardEnabled;
    }

    public boolean isChatEnabled() {
        return mIsChatEnabled;
    }

    public void setChatEnabled(boolean chatEnabled) {
        mIsChatEnabled = chatEnabled;
    }

    public boolean isProdEnvironment(){
        return Constants.VALUE_ENVIRONMENT_PRODUCTION.equals(getEnvironment());
    }

    public boolean isSandoboxEnvironment(){
        return Constants.VALUE_ENVIRONMENT_SANDBOX.equals(getEnvironment());
    }

    public boolean isLogEnabled() {
        return mIsLogEnabled;
    }

    public void setLogEnabled(boolean logEnabled) {
        mIsLogEnabled = logEnabled;
    }
}
