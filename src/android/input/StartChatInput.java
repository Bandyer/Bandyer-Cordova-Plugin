package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

import com.bandyer.cordova.plugin.Constants;

import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_VIDEO;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_CHAT_ONLY;

public class StartChatInput {

    private String mAddressee;
    private boolean isRecordingEnabled;
    private CallType callType;

    public static StartChatInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        StartChatInput startChatInput = new StartChatInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            String addressee = args.getString(Constants.ARG_ADDRESSEE);
            if(addressee == null || addressee.equals("")) {
                throw new PluginInputNotValidException(Constants.ARG_ADDRESSEE + " cannot be null");
            }
            startChatInput.setAddressee(addressee);
            boolean rec = args.has(Constants.ARG_RECORDING) ? args.getBoolean(Constants.ARG_RECORDING) : false;
            startChatInput.setRecordingEnabled(rec);
            String type = args.has(Constants.ARG_CALL_TYPE) ? args.getString(Constants.ARG_CALL_TYPE) : VALUE_CALL_TYPE_AUDIO_VIDEO;
            if(VALUE_CALL_TYPE_AUDIO.equals(type)){
                startChatInput.setCallType(CallType.AUDIO);
            } else if(VALUE_CALL_TYPE_AUDIO_UPGRADABLE.equals(type)){
                startChatInput.setCallType(CallType.AUDIO_UPGRADABLE);
            }else if(VALUE_CALL_TYPE_CHAT_ONLY.equals(type)){
                startChatInput.setCallType(CallType.CHAT_ONLY);
            } else {
                startChatInput.setCallType(CallType.AUDIO_VIDEO);
            }
            return startChatInput;
        }catch (Throwable t) {
            throw new PluginInputNotValidException("error on StartChatInput " + t.getMessage(), t);
        }
    }

    public String getAddressee() {
        return mAddressee;
    }

    public void setAddressee(String addressee) {
        mAddressee = addressee;
    }

    public boolean isRecordingEnabled() {
        return isRecordingEnabled;
    }

    public void setRecordingEnabled(boolean recordingEnabled) {
        isRecordingEnabled = recordingEnabled;
    }

    public CallType getCallType() {
        return callType;
    }

    public void setCallType(CallType callType) {
        this.callType = callType;
    }
}
