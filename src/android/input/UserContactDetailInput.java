package it.reply.bandyerplugin.input;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import it.reply.bandyerplugin.Constants;

import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_AGE;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_ALIAS;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_EMAIL;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_FIRSTNAME;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_GENDER;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_LASTNAME;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_NICKNAME;
import static it.reply.bandyerplugin.Constants.VALUE_CALL_KEY_PROFILE_IMAGE_URL;


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
            res.setAlias(object.getString(VALUE_CALL_KEY_ALIAS));
            res.setNickName(object.getString(VALUE_CALL_KEY_NICKNAME));
            res.setFirstName(object.getString(VALUE_CALL_KEY_FIRSTNAME));
            res.setLastName(object.getString(VALUE_CALL_KEY_LASTNAME));
            res.setEmail(object.getString(VALUE_CALL_KEY_EMAIL));
            res.setAge(object.getInt(VALUE_CALL_KEY_AGE));
            res.setGender(object.getString(VALUE_CALL_KEY_GENDER));
            res.setProfileImageUrl(object.getString(VALUE_CALL_KEY_PROFILE_IMAGE_URL));
            return res;
        } catch (Throwable t) {
            throw new PluginInputNotValidException("error on UserContactDetailInput " + t.getMessage(), t);
        }
    }

    private String alias, nickName, firstName, lastName, email, gender, profileImageUrl;
    private int age;

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

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public String getAlias() {
        return alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }
}
