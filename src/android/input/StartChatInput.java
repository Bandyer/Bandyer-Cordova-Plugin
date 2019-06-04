package it.reply.bandyerplugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

import it.reply.bandyerplugin.Constants;

public class StartChatInput {

    private String mAddressee;

    public static StartChatInput createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        StartChatInput startChatInput = new StartChatInput();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            String addressee = args.getString(Constants.ARG_ADDRESSEE);
            if(addressee == null || addressee.equals("")) {
                throw new PluginInputNotValidException(Constants.ARG_ADDRESSEE + " cannot be null");
            }
            startChatInput.setAddressee(addressee);

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
}
