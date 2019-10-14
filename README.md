# Bandyer Cordova Plugin

## How to install the plugin:

Open the **terminal** in your Cordova-App folder and run the following commands

```
npm i
cordova prepare
cordova plugin add @bandyer/cordova-plugin-bandyer
```

## How to link local plugin:
Link the local plugin to the project
```bash
cordova plugin add ../{path-to-local-plugin} --link
```

## How to remove the plugin:

```bash
cordova plugin remove cordova-plugin-bandyer
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

Android 
```bash
cordova run android
```

iOS
```bash
cordova run ios
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
BandyerPlugin.setup({
            environment: BandyerPlugin.environments.sandbox(),
            appId: 'mAppId_xxx', // your mobile appId
            logEnabled: true, // enable the logger
            // optional you can disable one or more of the following capabilities, by default callkit is enabled
            iosConfig: {
                callkitEnabled: true, // enable callkit on iOS 10+
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

## Plugin listen for errors/events
To listen for events and/or errors register
Check the documentation [here](enums/events.html) for a complete list

Example:

```javascript
bandyerPlugin.on(BandyerPlugin.events.callModuleStatusChanged, function (status) {});
```

## Listening for VoIP push token
In order to get your device push token, you must listen for the **BandyerPlugin.events.iOSVoipPushTokenUpdated** event registering a callback as follows:

```javascript
bandyerPlugin.on(BandyerPlugin.events.iOSVoipPushTokenUpdated, function (token) {
				//Do something with the token received
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
