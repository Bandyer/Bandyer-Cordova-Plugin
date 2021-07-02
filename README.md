![Bandyer Logo](doc/img/Bandyer-logotype-white-1024x500.png)

# Bandyer Cordova Plugin

[![npm version](https://badge.fury.io/js/%40bandyer%2Fcordova-plugin-bandyer.svg)](https://badge.fury.io/js/%40bandyer%2Fcordova-plugin-bandyer)

## Requirements

```
npm i xml2js // needed for android 
cordova plugin add cordova-plugin-enable-multidex // plugin needed for android 64k max limit of methods
cordova plugin add cordova-plugin-androidx // needed for android
```

## How to install the plugin:

Open the **terminal** in your Cordova-App folder and run the following commands

```sh
cordova plugin add @bandyer/cordova-plugin-bandyer
```

### Advanced installation options

Starting from the **0.8.0** version, the iOS plugin supports the broadcast screen sharing feature of the native BandyerSDK. In order to enable the broadcast screen sharing tool in your cordova app you must add the plugin providing some settings. For more information please take a look at [Bandyer Broadcast Extension Cordova Plugin][BroadcastExtension] documentation.

## How to link local plugin:

Link the local plugin to the project

```sh
cordova plugin add @bandyer/cordova-plugin-bandyer --searchPath ${path-to-local-plugin}  --link
```

## How to remove the plugin:

```sh
cordova plugin remove @bandyer/cordova-plugin-bandyer
```

## Update the Cordova platforms
Every time you update the plugin remove the platforms 'android' and/or 'ios' and re add them to ensure that all modified plugins are copied to build folders
remove platforms 'android' and/or 'ios' and re add them to ensure that all modified plugins are copied to build folders

```bash
cd {to your app root folder}
# Add --nosave if you don't want to update your package.json file when executing the commands below
cordova platforms remove android ios
cordova platforms add android ios
```

## How to run the cordova app

### iOS - device

```sh
cordova run ios
```

### iOS - simulator

To run on the iOS simulator it's required to copy the following file .mp4 in your app assets.
[https://static.bandyer.com/corporate/iOS/assets/bandyer_iOS_simulator_video_sample.mp4][SimulatorSample]. 
You may run the following command at the root of your app, which will download and put the file in the assets folder

```sh
cd {to your app root folder}
mkdir www/assets & curl -o www/assets/bandyer_iOS_simulator_video_sample.mp4 https://static.bandyer.com/corporate/iOS/assets/bandyer_iOS_si
mulator_video_sample.mp4
```

Once downloaded you will need to declare the file your config.xml

```xml
<platform name="ios">
	<resource-file src="www/assets/bandyer_iOS_simulator_video_sample.mp4" target="bandyer_iOS_simulator_video_sample.mp4" />
</platform>
```

### Android

```sh
cordova run android
```

## How to use the plugin in your Cordova app

You can refer to the Bandyer plugin in your cordova app via

```javascript
BandyerPlugin
```

## Plugin setup

The first thing you need to do is to setup the plugin specifying your keys and your options.

##### Setup params

```javascript
var bandyerPlugin = BandyerPlugin.setup({
            environment: BandyerPlugin.environments.sandbox(),
            appId: 'mAppId_xxx', // your mobile appId
            logEnabled: true, // enable the logger
            // optional you can disable one or more of the following capabilities, by default callkit is enabled
            iosConfig: {
                callkit: {
                    enabled: true, // enable callkit on iOS 10+
                    appIconName: "logo_transparent", // optional but recommended
                    ringtoneSoundName: "custom_ringtone.mp3" // optional
                },
                fakeCapturerFileName: null, // set this property to be able to execute on an ios simulator
                voipNotificationKeyPath: 'keypath_to_bandyer_data' //this property is **required** if you enabled VoIP notifications in your app
            },
            // optional you can disable one or more of the following capabilities, by default all additional modules are enabled
            androidConfig: {
                callEnabled: true, // enable call module on android
                fileSharingEnabled: true, // enable file sharing module on android
                chatEnabled: true, // enable chat module on android
                screenSharingEnabled: true, // enable screen sharing module on android
                whiteboardEnabled: true // enable whiteboard module on android
            }
})
```

[**Android notificationKeyPath you may find an example here**][AndroidNotificationKeyPath]

## Plugin listen for errors/events

To listen for events and/or errors register
Check the documentation [here][EventsDoc] for a complete list.

Example:

```javascript
bandyerPlugin.on(BandyerPlugin.events.callModuleStatusChanged, function (status) {});
```

## Listening for VoIP push token

In order to get your device push token, you must listen for the **BandyerPlugin.events.iOSVoipPushTokenUpdated** event registering a callback as follows:

```javascript
bandyerPlugin.on(BandyerPlugin.events.iOSVoipPushTokenUpdated, function (token) {
				// register the VoIP push token on your server
        });
```
The token provided in the callback is the **string** representation of your device token. 
Here's an example of a device token: **dec105f879924349fd2fa9aa8bb8b70431d5f41d57bfa8e31a5d80a629774fd9**

## Plugin start

To start a plugin means to connect an user to the bandyer system.

```javascript
// start the bandyer plugin specifying the user alias of the user you want to connect
bandyerPlugin.startFor('usr_xxx');
```

## Start a call

To make a call you need to specify some params.

##### Start call params

```javascript
bandyerPlugin.startCall({
                   userAliases: ['usr_yyy','usr_zzz'], //  an array of user aliases of the users you want to call
                   callType: BandyerPlugin.callTypes.AUDIO_VIDEO, // **[BandyerPlugin.callTypes.AUDIO | BandyerPlugin.callTypes.AUDIO_UPGRADABLE | BandyerPlugin.callTypes.AUDIO_VIDEO]** the type of the call you want to start
                   recording: false // enable recording for the call
});
```

## Start a chat

To make a chat you need to specify some params.

##### Start chat params

```javascript
bandyerPlugin.startChat({
                    userAlias: 'usr_yyy', // the alias of the user you want to create a chat with
                    withAudioCallCapability: {recording: false}, // define if you want the audio only call button in the chat UI, and set recording if you desire to be recorded.
                    withAudioUpgradableCallCapability: {recording: false}, // define if you want the audio upgradable call button in the chat UI, and set recording if you desire to be recorded.
                    withAudioVideoCallCapability: {recording: false} // define if you want the audio&video call button in the chat UI, and set recording if you desire to be recorded
});
```

## Set user details

This method will allow you to set your user details DB from which the sdk will read when needed to show the information.
> Be sure to have this always up to date, otherwise if an incoming call is received and the user is missing in this set the userAlias will be printed on the UI.

```javascript
var arrayUserDetails = [
            {userAlias: "user_1", firstName : "User1Name", lastName:"User1Surname"},
            {userAlias: "user_2", firstName : "User2Name", lastName:"User2Surname"}
];

bandyerPlugin.addUsersDetails(arrayUserDetails);
```

## Remove all user details

This method will allow you to remove all the user info from the local app DB.

```javascript
bandyerPlugin.removeUsersDetails();
```

## Set user details format

This method will allow you to specify how you want your user details to be displayed.
> Be aware that you can specify only keywords which exist in the UserDetails type.

For example: if you wish to show only the firstName while your dataset contains also the lastName you may change it here.

```javascript
bandyerPlugin.setUserDetailsFormat({
    default: "${firstName} ${lastName}",
    android_notification_format: "${firstName} ${lastName}" // optional if you wish to personalize the details in the notification.
});
```

## Remove all the cached info in preferences and DBs

```javascript
bandyerPlugin.clearUserCache();
```

## Android change display mode

This method is useful for use-cases where you need to show a prompt and don't want it to be invalidated by the call going into pip.
For example: if you wish to show fingerprint dialog you should first put the current call in background, execute the fingerprint validation and then put back the call in foreground.

```javascript
bandyerPlugin.setDisplayModeForCurrentCall(CallDisplayMode.FOREGROUND); // CallDisplayMode.FOREGROUND | CallDisplayMode.FOREGROUND_PICTURE_IN_PICTURE | CallDisplayMode.BACKGROUND 
```

## Verify user

To verify a user for the current call.

```javascript
bandyerPlugin.verifyCurrentCall(true);  
```

## TSDoc

The API documentation is available on the github pages link:
[https://bandyer.github.io/Bandyer-Cordova-Plugin/][TSDoc]

[BroadcastExtension]: https://github.com/Bandyer/Bandyer-Cordova-BroadcastExtension-Plugin
[SimulatorSample]: https://static.bandyer.com/corporate/iOS/assets/bandyer_iOS_simulator_video_sample.mp4
[AndroidNotificationKeyPath]: https://github.com/Bandyer/Bandyer-Cordova-Example/blob/master/config.xml#L25-L43
[EventsDoc]: https://bandyer.github.io/Bandyer-Cordova-Plugin/enums/events.html
[TSDoc]: https://bandyer.github.io/Bandyer-Cordova-Plugin/