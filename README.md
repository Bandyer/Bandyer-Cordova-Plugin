# Bandyer Cordova Plugin

## How to add the plugin to your cordova project:

Since the plugin it's in beta and it hasn't been published yet, you must clone this repo locally and link it to your cordova project using the following command:
```
$ cordova plugin add ../{path-to-local-plugin} --link
```

Every time you update the plugin remove the platforms 'android' and/or 'ios' and re add them to ensure that all modified plugins are copied to build folders

```
$ cordova platforms remove android ios
$ cordova platforms add android ios
```

## How to use the plugin in your Cordova app

You can refer to the Bandyer plugin in your cordova app via
```
BandyerPlugin
```

## Plugin setup
The first thing you need to do is to setup the plugin specifying your keys and your options.

##### Setup params
- environment: **[BandyerPlugin.environments.sandbox() | BandyerPlugin.environments.production()]** the bandyer environment where your integration will run.
- appId: **[mAppId_xxx]** your mobile appId
- logEnabled: **[true | false]** flag to enable disable the logger

- iosConfig: define to personalize the ios configuration
    - callkitEnabled: **[true | false]** flag to enable callkit on iOS 
    - fakeCapturerFileName: **[fileName]** by default is null, this property is **required** only for simulators
    
- androidConfig: define to personalize the android configuration
    - callEnabled: **[true | false]** flag to enable call module on android
    - fileSharingEnabled: **[true | false]** flag to enable file sharing module on android
    - chatEnabled: **[true | false]** flag to enable chat module on android
    - screenSharingEnabled: **[true | false]** flag to enable screen sharing module on android
    - whiteboardEnabled: **[true | false]** flag to enable whiteboard module on android

```javascript
BandyerPlugin.setup({
            environment: BandyerPlugin.environments.sandbox(),
            appId: 'mAppId_xxx',
            logEnabled: true,
            // optional you can disable one or more of the following capabilities, by default callkit is enabled
            iosConfig: {
                callkitEnabled: true,
                fakeCapturerFileName: null // set this property to be able to execute on an ios simulator
            },
            // optional you can disable one or more of the following capabilities, by default all additional modules are enabled
            androidConfig: {
                callEnabled: true,
                fileSharingEnabled: true,
                chatEnabled: true,
                screenSharingEnabled: true,
                whiteboardEnabled: true
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
- callee: an array of user aliases of the users you want to call
- callType: **[BandyerPlugin.callTypes.AUDIO | BandyerPlugin.callTypes.AUDIO_UPGRADABLE | BandyerPlugin.callTypes.AUDIO_VIDEO]** the type of the call you want to start
- recording: **[true | false]** flag to enable recording for the call

```javascript
bandyerPlugin.startCall({
                   userAliases: ['usr_yyy','usr_zzz'],
                   callType: BandyerPlugin.callTypes.AUDIO_VIDEO,
                   recording: false
});
```

## Start a chat
To make a chat you need to specify some params.

##### Start chat params
- userAlias: the alias of the user you want to create a chat with
- withAudioCallCapability: **[recording: true | false]** define if you want the audio only call button in the chat UI, and set recording if you desire to be recorded.
- withAudioUpgradableCallCapability: **[recording: true | false]**  define if you want the audio upgradable call button in the chat UI, and set recording if you desire to be recorded.
- withAudioVideoCallCapability: **[recording: true | false]** define if you want the audio&video call button in the chat UI, and set recording if you desire to be recorded.

```javascript
bandyerPlugin.startChat({
                    userAlias: 'usr_yyy',
                    withAudioCallCapability: {recording: false},
                    withAudioUpgradableCallCapability: {recording: false},
                    withAudioVideoCallCapability: {recording: false}
});
```