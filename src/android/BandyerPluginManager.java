package com.bandyer.cordova.plugin;

import android.app.Application;
import android.content.Intent;
import android.util.Log;

import com.bandyer.android_sdk.BandyerSDK;
import com.bandyer.android_sdk.Environment;
import com.bandyer.android_sdk.call.model.CallInfo;
import com.bandyer.android_sdk.call.notification.CallNotificationListener;
import com.bandyer.android_sdk.call.notification.CallNotificationStyle;
import com.bandyer.android_sdk.call.notification.CallNotificationType;
import com.bandyer.android_sdk.client.BandyerSDKClient;
import com.bandyer.android_sdk.client.BandyerSDKClientObserver;
import com.bandyer.android_sdk.client.BandyerSDKClientOptions;
import com.bandyer.android_sdk.client.BandyerSDKClientState;
import com.bandyer.android_sdk.intent.BandyerIntent;
import com.bandyer.android_sdk.intent.call.CallIntentOptions;
import com.bandyer.android_sdk.intent.call.IncomingCall;
import com.bandyer.android_sdk.intent.chat.ChatIntentOptions;
import com.bandyer.android_sdk.module.BandyerModule;
import com.bandyer.android_sdk.module.BandyerModuleObserver;
import com.bandyer.android_sdk.module.BandyerModuleStatus;
import com.bandyer.android_sdk.notification.NotificationAction;
import com.bandyer.android_sdk.utils.BandyerSDKLogger;
import com.bandyer.android_sdk.utils.provider.OnUserInformationProviderListener;
import com.bandyer.android_sdk.utils.provider.UserContactProvider;
import com.bandyer.android_sdk.utils.provider.UserDetails;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.bandyer.cordova.plugin.input.CallType;
import com.bandyer.cordova.plugin.input.HandleNotificationInput;
import com.bandyer.cordova.plugin.input.InitInput;
import com.bandyer.cordova.plugin.input.StartCallInput;
import com.bandyer.cordova.plugin.input.StartChatInput;
import com.bandyer.cordova.plugin.input.StartInput;
import com.bandyer.cordova.plugin.input.UserContactDetailInput;
import com.bandyer.cordova.plugin.listener.PluginChatNotificationListener;

import static com.bandyer.cordova.plugin.Constants.BANDYER_LOG_TAG;

public class BandyerPluginManager {

    private static InitInput myInitInput;
    private static final Map<String, UserContactDetailInput> usersDetailMap = new HashMap<>();

    private static final BandyerSDKClientObserver clientObserver = new BandyerSDKClientObserver() {
        @Override
        public void onClientStatusChange(BandyerSDKClientState bandyerSDKClientState) {
            BandyerPluginManager.notifyListener("onClientStatusChange");
        }

        @Override
        public void onClientError(Throwable throwable) {
            BandyerPluginManager.notifyListener("onClientError");
        }

        @Override
        public void onClientReady() {
            BandyerPluginManager.notifyListener("onClientReady");
        }

        @Override
        public void onClientStopped() {
            BandyerPluginManager.notifyListener("onClientStopped");
        }
    };

    private static final BandyerModuleObserver moduleObserver = new BandyerModuleObserver() {
        @Override
        public void onModuleReady(BandyerModule bandyerModule) {
            BandyerPluginManager.notifyListener("onModuleReady");
        }

        @Override
        public void onModulePaused(BandyerModule bandyerModule) {
            BandyerPluginManager.notifyListener("onModulePaused");
        }

        @Override
        public void onModuleFailed(BandyerModule bandyerModule, Throwable throwable) {
            BandyerPluginManager.notifyListener("onModuleFailed");
        }

        @Override
        public void onModuleStatusChanged(BandyerModule bandyerModule, BandyerModuleStatus bandyerModuleStatus) {
            BandyerPluginManager.notifyListener("onModuleStatusChanged");
        }
    };
    private static BandyerPlugin currentBandyerPlugin;

    public static void setup(final Application application, InitInput input) {
        BandyerSDK.Builder builder = new BandyerSDK.Builder(application, input.getAppId());
        if (input.isProdEnvironment()) {
            builder.setEnvironment(Environment.Configuration.production());
        } else if (input.isSandoboxEnvironment()) {
            builder.setEnvironment(Environment.Configuration.sandbox());
        }
        if (input.isCallEnabled()) {
            builder.withCallEnabled(getCallNotificationListener(application));
        }
        if (input.isWhiteboardEnabled()) {
            builder.withWhiteboardEnabled();
        }
        if (input.isFileSharingEnabled()) {
            builder.withFileSharingEnabled();
        }
        if (input.isChatEnabled()) {
            builder.withChatEnabled(new PluginChatNotificationListener(application, input));
        }
        if (input.isLogEnabled()) {
            builder.setLogger(new BandyerSDKLogger() {

                @Override
                public void warn(String s, String s1) {
                    Log.w(BANDYER_LOG_TAG, s1);
                }

                @Override
                public void verbose(String s, String s1) {
                    Log.v(BANDYER_LOG_TAG, s1);
                }

                @Override
                public void info(String s, String s1) {
                    Log.i(BANDYER_LOG_TAG, s1);
                }

                @Override
                public void error(String s, String s1) {
                    Log.e(BANDYER_LOG_TAG, s1);
                }

                @Override
                public void debug(String s, String s1) {
                    Log.d(BANDYER_LOG_TAG, s1);
                }
            });
        }
        builder.withUserContactProvider(new UserContactProvider() {

            @Override
            public void provideUserDetails(List<String> userAliases, OnUserInformationProviderListener<UserDetails> onProviderListener) {

                ArrayList<UserDetails> details = new ArrayList<>();

                UserContactDetailInput detail;
                for(String userAlias : userAliases) {
                    UserDetails.Builder builder = new UserDetails.Builder(userAlias);
                    if(usersDetailMap.containsKey(userAlias)){
                        detail = usersDetailMap.get(userAlias);
                        builder.withNickName(detail.getNickName())
                                .withFirstName(detail.getFirstName())
                                .withLastName(detail.getLastName())
                                .withEmail(detail.getEmail())
                                .withImageUrl(detail.getProfileImageUrl()) // or .withImageUri(uri) or .withResId(resId)
                                .build();

                    }
                    details.add(builder.build());
                }

                // provide results on the OnUserInformationProviderListener object
                onProviderListener.onProvided(details);
            }
        });
        myInitInput = input;
        BandyerSDK.init(builder);
    }

    public static void start(StartInput input) {
        if (BandyerSDKClient.getInstance().getState() != BandyerSDKClientState.UNINITIALIZED) {
            return;
        }

        BandyerSDKClientOptions options = new BandyerSDKClientOptions.Builder()
                .keepListeningForEventsInBackground(false)
                .build();
        BandyerSDKClient.getInstance().init(input.getUserAlias(), options);
    }

    public static void startListening() {
        // Start listening for events
        BandyerSDKClient.getInstance().startListening();
    }

    public static void stopListening() {
        BandyerSDKClient.getInstance().stopListening();
    }

    public static void dispose() {
        BandyerSDKClient.getInstance().dispose();
    }

    public static void clearUserCache() {
        BandyerSDKClient.getInstance().clearUserCache();
    }

    public static String getCurrentState() {
        return convertToString(BandyerSDKClient.getInstance().getState());

    }

    private static String convertToString(BandyerSDKClientState state) {
        switch (state) {
            case UNINITIALIZED:
                return "stopped";
            case INITIALIZING:
                return "resuming";
            case PAUSED:
                return "paused ";
            default:
                return "running";
        }
    }

    public static void addObservers() {
        BandyerSDKClient.getInstance().addObserver(clientObserver);
        BandyerSDKClient.getInstance().addModuleObserver(moduleObserver);
    }

    public static void removeObservers() {
        BandyerSDKClient.getInstance().removeObserver(clientObserver);
        BandyerSDKClient.getInstance().removeModuleObserver(moduleObserver);
    }

    public static void handleNotification(Application application, HandleNotificationInput input) {
        BandyerSDKClient.getInstance().handleNotification(application, input.getPayload());
    }

    public static void startCall(BandyerPlugin bandyerPlugin, StartCallInput input) throws PluginMethodNotValidException {
        if (myInitInput == null) {
            throw new PluginMethodNotValidException("A setup method call is needed before a call operation");
        }
        boolean isCallEnabled = myInitInput.isCallEnabled();
        boolean isChatEnabled = myInitInput.isChatEnabled();
        boolean isWhiteboardEnabled = myInitInput.isWhiteboardEnabled();
        boolean isFileSharingEnabled = myInitInput.isFileSharingEnabled();
        if (isCallEnabled) {
            boolean isJoinCall = input.hasJoinUrl();
            BandyerIntent.Builder builder = new BandyerIntent.Builder();
            CallIntentOptions options;
            if (isJoinCall) {
                options = builder
                        .startFromJoinCallUrl(bandyerPlugin.cordova.getActivity(), input.getJoinUrl());
            } else {
                ArrayList<String> calleeList = input.getCalleeList();
                if (input.getCallType() == CallType.AUDIO) {
                    options = builder.startWithAudioCall(bandyerPlugin.cordova.getActivity(),
                            input.isRecordingEnabled(), false)
                            .with(calleeList);
                } else if (input.getCallType() == CallType.AUDIO_UPGRADABLE) {
                    options = builder.startWithAudioCall(bandyerPlugin.cordova.getActivity(),
                            input.isRecordingEnabled(), true)
                            .with(calleeList);
                } else {
                    options = builder
                            .startWithAudioVideoCall(bandyerPlugin.cordova.getActivity(),
                                    input.isRecordingEnabled() /* call recording */)
                            .with(calleeList);
                }


                if (isChatEnabled) {
                    options.withChatCapability();
                }
            }
            if (isWhiteboardEnabled) {
                options.withWhiteboardCapability();
            }
            if (isFileSharingEnabled) {
                options.withFileSharingCapability();
            }
            BandyerIntent callBackIntent = options.build();
            callBackIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            bandyerPlugin.cordova.startActivityForResult(bandyerPlugin, callBackIntent, Constants.INTENT_REQUEST_CALL_CODE);
        } else {
            throw new PluginMethodNotValidException("Cannot manage a 'start call' request: call feature is not enabled!");
        }

    }

    public static void startChat(BandyerPlugin bandyerPlugin, StartChatInput input) throws PluginMethodNotValidException {
        if (myInitInput == null) {
            throw new PluginMethodNotValidException("A setup method call is needed before a chat operation");
        }
        boolean chatEnabled = myInitInput.isChatEnabled();
        boolean callEnabled = myInitInput.isCallEnabled();
        boolean whiteboardEnabled = myInitInput.isWhiteboardEnabled();
        boolean fileSharingEnabled = myInitInput.isFileSharingEnabled();
        if (chatEnabled) {
            String addressee = input.getAddressee();
            ChatIntentOptions intentOptions = new BandyerIntent.Builder()
                    .startWithChat(bandyerPlugin.cordova.getActivity())
                    .with(addressee);

            if (input.getCallType() == CallType.AUDIO) {
                if (callEnabled) {
                    intentOptions.withAudioCallCapability(input.isRecordingEnabled(), false);
                }
            } else if (input.getCallType() == CallType.AUDIO_UPGRADABLE) {
                if (callEnabled) {
                    intentOptions.withAudioCallCapability(input.isRecordingEnabled(), true);
                }
            } else if (input.getCallType() == CallType.AUDIO_VIDEO) {
                if (callEnabled) {
                    intentOptions.withAudioVideoCallCapability(input.isRecordingEnabled());
                }
            } else {
                //chat only
            }

            if (whiteboardEnabled) {
                intentOptions.withWhiteboardInCallCapability();
            }
            if (fileSharingEnabled) {
                intentOptions.withFileSharingInCallCapability();
            }
            BandyerIntent callBackIntent = intentOptions.build();
            callBackIntent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            bandyerPlugin.cordova.startActivityForResult(bandyerPlugin, callBackIntent, Constants.INTENT_REQUEST_CHAT_CODE);
        } else {
            throw new PluginMethodNotValidException("Cannot manage a 'start chat' request: chat feature is not enabled!");
        }
    }

    public static void setUserDetails(List<UserContactDetailInput> input) {
        clearUserDetails();
        for (UserContactDetailInput item :input) {
            usersDetailMap.put(item.getAlias(), item);
        }
    }

    public static void clearUserDetails() {
        usersDetailMap.clear();
    }


    public static boolean isLogEnabled() {
        return myInitInput != null && myInitInput.isLogEnabled();
    }

    public static void notifyListener(final String methodCall) {
        if (BandyerPluginManager.currentBandyerPlugin != null) {
            try {
                BandyerPluginManager.currentBandyerPlugin.cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            BandyerPluginManager.currentBandyerPlugin.webView.loadUrl("javascript:window.cordova.plugins.BandyerPlugin.callClientListener('android_" + methodCall + "')");
                        } catch (Throwable t) {
                            if (isLogEnabled()) {
                                Log.e(BANDYER_LOG_TAG, "Error on javascript method execution", t);
                            }
                        }
                    }
                });
            } catch (Throwable t) {
                if (isLogEnabled()) {
                    Log.e(BANDYER_LOG_TAG, "Error on javascript method execution", t);
                }
            }
        }
    }

    public static void setCurrentPlugin(BandyerPlugin bandyerPlugin) {
        currentBandyerPlugin = bandyerPlugin;
    }

    private static CallNotificationListener getCallNotificationListener(final Application application) {
        return new CallNotificationListener() {

            public void onIncomingCall(IncomingCall call, boolean isDnd, boolean isScreenLocked) {
                if (!isDnd || isScreenLocked) {
                    application.startActivity(call.asActivityIntent(application));
                } else {
                    call.asNotification(application).show();
                }
            }

            public void onCallActivityStartedFromNotificationAction(CallInfo callInfo, CallIntentOptions callIntentOptions) {
                if (myInitInput.isChatEnabled()) {
                    callIntentOptions
                            .withChatCapability();
                }
                if (myInitInput.isWhiteboardEnabled()) {
                    callIntentOptions
                            .withWhiteboardCapability();
                }
                if (myInitInput.isFileSharingEnabled()) {
                    callIntentOptions
                            .withFileSharingCapability();
                }
            }

            public void onCreateNotification(
                    CallInfo callInfo,
                    CallNotificationType type,
                    CallNotificationStyle notificationStyle
            ) {

//                notificationStyle.setNotificationColor(Color.RED);
            }

            public void onNotificationAction(NotificationAction action) {
                // Here you can execute your own code before executing the default action of the notification
                action.execute();
            }
        };
    }

}
