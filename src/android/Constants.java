package it.reply.bandyerplugin;

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
    public static final String METHOD_CLEAR_USER_CACHE = "clearUserCache";
    public static final String METHOD_HANDLE_NOTIFICATION = "handlerPayload";


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
    public static final String ARG_JOIN_URL = "android_joinUrl";

    //START CHAT
    public static final String ARG_ADDRESSEE = "addressee";

    //INTENT
    public static final int INTENT_REQUEST_CALL_CODE = 101;
    public static final int INTENT_REQUEST_CHAT_CODE = 102;


    public static final String BANDYER_LOG_TAG= "BANDYER_LOG";



}
