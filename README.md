# Bandyer Cordova Plugin

## How to install the plugin:

```
$ npm i
$ cordova prepare
$ cordova plugin add @bandyer/cordova-plugin-bandyer
```

## How to remove the plugin:

```
$ cordova plugin remove cordova-plugin-bandyer
```

## How to link local plugin:
Link the local plugin to the project
```
$ cordova plugin add ../{path-to-local-plugin} --link

remove platforms 'android' and/or 'ios' and re add them to ensure that all modified plugins are copied to build folders
$ cordova platforms remove android
$ cordova platforms add android

run on android device with a device connected through adb
$ cordova run android --device

or run on android emulator
$ cordova emulate android
```

## How to use the plugin in your Cordova app

You can refer to the Bandyer plugin in your cordova app via
```
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
                fakeCapturerFileName: null // set this property to be able to execute on an ios simulator
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