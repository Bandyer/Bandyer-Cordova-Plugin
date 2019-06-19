package com.bandyer.cordova.plugin;

public class Constants {
    public static final String METHOD_INITIALIZE = "initializeBandyer";
    public static final String METHOD_ADD_CALL_CLIENT_LISTENER = "addCallClient";
    public static final String METHOD_REMOVE_CALL_CLIENT_LISTENER = "removeCallClient";
    public static final String METHOD_START = "start";
    public static final String METHOD_STOP = "stop";
    public static final String METHOD_PAUSE = "pause";
    public static final String METHOD_RESUME = "resume";
    public static final String METHOD_STATE = "state";
    public static final String METHOD_MAKE_CALL = "makeCall";
    public static final String METHOD_MAKE_CHAT = "makeChat";
    public static final String METHOD_HANDLE_NOTIFICATION = "handlerPayload";
    public static final String METHOD_CLEAR_USER_CACHE = "clearUserCache";
    public static final String METHOD_CLEAR_USER_DETAILS = "clearCache";
    public static final String METHOD_HANDLE_SET_USER_DETAILS = "createUserInfoFetch";


    //INIT
    public static final String VALUE_ENVIRONMENT_PRODUCTION = "production";
    public static final String VALUE_ENVIRONMENT_SANDBOX = "sandbox";
    public static final String ARG_ENVIRONMENT = "environment";
    public static final String ARG_ENABLE_LOG= "logEnable";
    public static final String ARG_APP_ID = "appId";
    public static final String ARG_CALL_ENABLED= "android_isCallEnabled";
    public static final String ARG_FILE_SHARING_ENABLED= "android_isFileSharingEnabled";
    public static final String ARG_WHITEBOARD_ENABLED= "android_isWhiteboardEnabled";
    public static final String ARG_CHAT_ENABLED= "android_isChatEnabled";

    //START
    public static final String ARG_USER_ALIAS = "username";

    //HANDLE NOTIFICATION
    public static final String ARG_HANDLE_NOTIFICATION = "payload";

    //START CALL
    public static final String ARG_CALLEE = "callee";
    public static final String ARG_JOIN_URL = "joinUrl";

    //START CHAT
    public static final String ARG_ADDRESSEE = "addressee";
    public static final String VALUE_CALL_TYPE_CHAT_ONLY = "c";

    //START CALL AND CHAT
    public static final String ARG_RECORDING = "recording";
    public static final String ARG_CALL_TYPE = "typeCall";
    public static final String VALUE_CALL_TYPE_AUDIO = "a";
    public static final String VALUE_CALL_TYPE_AUDIO_UPGRADABLE = "au";
    public static final String VALUE_CALL_TYPE_AUDIO_VIDEO = "av";

    //USER DETAILS
    public static final String ARG_ADDRESS = "address";
    public static final String VALUE_CALL_KEY_ALIAS = "alias";
    public static final String VALUE_CALL_KEY_NICKNAME = "nickname";
    public static final String VALUE_CALL_KEY_FIRSTNAME = "firstName";
    public static final String VALUE_CALL_KEY_LASTNAME = "lastName";
    public static final String VALUE_CALL_KEY_EMAIL = "email";
    public static final String VALUE_CALL_KEY_AGE = "age";
    public static final String VALUE_CALL_KEY_GENDER = "gender";
    public static final String VALUE_CALL_KEY_PROFILE_IMAGE_URL = "profileImageUrl";

    //INTENT
    public static final int INTENT_REQUEST_CALL_CODE = 101;
    public static final int INTENT_REQUEST_CHAT_CODE = 102;


    public static final String BANDYER_LOG_TAG= "BANDYER_LOG";



}
