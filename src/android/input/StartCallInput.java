package it.reply.bandyerplugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import it.reply.bandyerplugin.Constants;

public class StartCallInput {

    private final ArrayList<String> mCalleeList;
    private String mJoinUrl;

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
}
