package com.bandyer.cordova.plugin

object Constants {
    val METHOD_INITIALIZE = "initializeBandyer"
    val METHOD_ADD_CALL_CLIENT_LISTENER = "addCallClient"
    val METHOD_REMOVE_CALL_CLIENT_LISTENER = "removeCallClient"
    val METHOD_START = "start"
    val METHOD_STOP = "stop"
    val METHOD_PAUSE = "pause"
    val METHOD_RESUME = "resume"
    val METHOD_STATE = "state"
    val METHOD_MAKE_CALL = "makeCall"
    val METHOD_MAKE_CHAT = "makeChat"
    val METHOD_HANDLE_NOTIFICATION = "handlerPayload"
    val METHOD_CLEAR_USER_CACHE = "clearUserCache"
    val METHOD_CLEAR_USER_DETAILS = "clearCache"
    val METHOD_HANDLE_SET_USER_DETAILS = "createUserInfoFetch"


    //INIT
    val VALUE_ENVIRONMENT_PRODUCTION = "production"
    val VALUE_ENVIRONMENT_SANDBOX = "sandbox"
    val ARG_ENVIRONMENT = "environment"
    val ARG_ENABLE_LOG = "logEnabled"
    val ARG_APP_ID = "appId"
    val ARG_CALL_ENABLED = "android_isCallEnabled"
    val ARG_FILE_SHARING_ENABLED = "android_isFileSharingEnabled"
    val ARG_WHITEBOARD_ENABLED = "android_isWhiteboardEnabled"
    val ARG_SCREENSHARING_ENABLED = "android_isScreenSharingEnabled"
    val ARG_CHAT_ENABLED = "android_isChatEnabled"

    //START
    val ARG_USER_ALIAS = "userAlias"

    //HANDLE NOTIFICATION
    val ARG_HANDLE_NOTIFICATION = "payload"

    //START CALL
    val ARG_CALLEE = "callee"
    val ARG_JOIN_URL = "joinUrl"

    //START CHAT
    val ARG_ADDRESSEE = "addressee"
    val VALUE_CALL_TYPE_CHAT_ONLY = "c"

    //START CALL AND CHAT
    val ARG_RECORDING = "recording"
    val ARG_CALL_TYPE = "callType"
    val VALUE_CALL_TYPE_AUDIO = "a"
    val VALUE_CALL_TYPE_AUDIO_UPGRADABLE = "au"
    val VALUE_CALL_TYPE_AUDIO_VIDEO = "av"

    //USER DETAILS
    val ARG_ADDRESS = "address"
    val VALUE_CALL_KEY_ALIAS = "alias"
    val VALUE_CALL_KEY_NICKNAME = "nickname"
    val VALUE_CALL_KEY_FIRSTNAME = "firstName"
    val VALUE_CALL_KEY_LASTNAME = "lastName"
    val VALUE_CALL_KEY_EMAIL = "email"
    val VALUE_CALL_KEY_PROFILE_IMAGE_URL = "profileImageUrl"

    //INTENT
    val INTENT_REQUEST_CALL_CODE = 101
    val INTENT_REQUEST_CHAT_CODE = 102


    val BANDYER_LOG_TAG = "BANDYER_LOG"


}
