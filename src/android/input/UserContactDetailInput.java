package com.bandyer.cordova.plugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import com.bandyer.cordova.plugin.Constants;

import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_ALIAS;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_EMAIL;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_FIRSTNAME;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_LASTNAME;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_NICKNAME;
import static com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_PROFILE_IMAGE_URL;


public class UserContactDetailInput {

    public static List<UserContactDetailInput> createFrom(JSONArray argsArray) throws PluginInputNotValidException {
        List<UserContactDetailInput> list = new ArrayList<>();
        try {
            JSONObject args = (JSONObject) argsArray.get(0);
            JSONArray address = args.has(Constants.ARG_ADDRESS) ? args.getJSONArray(Constants.ARG_ADDRESS) : new JSONArray();
            int len = address.length();
            if (len == 0) {
                throw new PluginInputNotValidException("Input list cannot be empty ");
            }
            for (int i = 0; i < len; i++) {
                list.add(createSingleUser(address.getJSONObject(i)));
            }
            return list;
        } catch (Throwable t) {
            throw new PluginInputNotValidException("error on UserContactDetailInput " + t.getMessage(), t);
        }
    }


    private static UserContactDetailInput createSingleUser(JSONObject object) throws PluginInputNotValidException {
        UserContactDetailInput res = new UserContactDetailInput();
        try {
            res.setAlias(object.optString(VALUE_CALL_KEY_ALIAS));
            res.setNickName(object.optString(VALUE_CALL_KEY_NICKNAME));
            res.setFirstName(object.optString(VALUE_CALL_KEY_FIRSTNAME));
            res.setLastName(object.optString(VALUE_CALL_KEY_LASTNAME));
            res.setEmail(object.optString(VALUE_CALL_KEY_EMAIL));
            res.setProfileImageUrl(object.optString(VALUE_CALL_KEY_PROFILE_IMAGE_URL));
            return res;
        } catch (Throwable t) {
            throw new PluginInputNotValidException("error on UserContactDetailInput " + t.getMessage(), t);
        }
    }

    private String alias, nickName, firstName, lastName, email, profileImageUrl;

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }

    public String getAlias() {
        return alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }
}