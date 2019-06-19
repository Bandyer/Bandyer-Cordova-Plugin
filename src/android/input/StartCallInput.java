package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import com.bandyer.cordova.plugin.Constants;

import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_UPGRADABLE;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_TYPE_AUDIO_VIDEO;

public class StartCallInput {

    private final ArrayList<String> mCalleeList;
    private String mJoinUrl;
    private boolean isRecordingEnabled;
    private CallType callType;

    public static StartCallInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        StartCallInput startInput = new StartCallInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            JSONArray callee = args.has(Constants.ARG_CALLEE) ? args.getJSONArray(Constants.ARG_CALLEE) : new JSONArray();
            String joinUrl = args.has(Constants.ARG_JOIN_URL) ? args.getString(Constants.ARG_JOIN_URL) : "";
            boolean isThereACallee = callee != null && callee.length() > 0;
            boolean isThereAJoinUrl = joinUrl != null && !joinUrl.equals("");
            if(!isThereACallee && !isThereAJoinUrl) {
                throw new PluginInputNotValidException(Constants.ARG_CALLEE + "and " + Constants.ARG_JOIN_URL + " cannot be null");
            }
            if(isThereACallee){
                int len = callee.length();
                for (int i=0;i<len;i++){
                    startInput.addCallee(callee.getString(i));
                }
            }
            if(isThereAJoinUrl){
                startInput.setJoinUrl(joinUrl);
            }
            boolean rec = args.has(Constants.ARG_RECORDING) ? args.getBoolean(Constants.ARG_RECORDING) : false;
            startInput.setRecordingEnabled(rec);
            String type = args.has(Constants.ARG_CALL_TYPE) ? args.getString(Constants.ARG_CALL_TYPE) : VALUE_CALL_TYPE_AUDIO_VIDEO;
            if(VALUE_CALL_TYPE_AUDIO.equals(type)){
                startInput.setCallType(CallType.AUDIO);
            } else if(VALUE_CALL_TYPE_AUDIO_UPGRADABLE.equals(type)){
                startInput.setCallType(CallType.AUDIO_UPGRADABLE);
            } else {
                startInput.setCallType(CallType.AUDIO_VIDEO);
            }
            return startInput;
        }catch (Throwable t) {
            throw new PluginInputNotValidException("error on InitInput " + t.getMessage(), t);
        }
    }

    private StartCallInput(){
        mCalleeList = new ArrayList<>();
    }

    public ArrayList<String> getCalleeList() {
        return mCalleeList;
    }

    public void addCallee(String callee) {
        mCalleeList.add(callee);
    }

    public String getJoinUrl() {
        return mJoinUrl;
    }

    public void setJoinUrl(String joinUrl) {
        mJoinUrl = joinUrl;
    }

    public boolean hasJoinUrl() {
        return mJoinUrl != null && mJoinUrl.length() > 0;
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
