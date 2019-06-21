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
cordova.plugins.BandyerPlugin
```

## Plugin setup
The first thing you need to do is to setup the plugin specifying your keys and your options.

##### Setup params
- environment: [sandbox|production]the bandyer environment 
- appId: [mAppId_xxx] your mobile appId
- logEnable: [true|false] flag to enable disable the logger
- ios_callkitEnable: [true|false] flag to enable callkit on iOS
- android_isCallEnabled: [true|false] flag to enable call module on android
- android_isFileSharingEnabled: [true|false] flag to enable file sharing module on android
- android_isChatEnabled: [true|false] flag to enable chat module on android
- android_isScreenSharingEnabled: [true|false] flag to enable screen sharing module on android
- android_isWhiteboardEnabled: [true|false] flag to enable whiteboard module on android

```
var params =  {
    environment: 'sandbox',
    appId: 'mAppId_xxx',
    logEnable: true,
    ios_callkitEnable: true,
    android_isCallEnabled: true,
    android_isFileSharingEnabled: true,
    android_isChatEnabled: true,
    android_isScreenSharingEnabled: true,
    android_isWhiteboardEnabled: true
};

cordova
    .plugins
    .BandyerPlugin
    .setup(params,(succ) => {
        // setup success
    },(err) => {
        // setup error
    });
```

## Plugin start
To start a plugin means to connect an user to the bandyer system.

```
const credentials = {
    userAlias: 'usr_xxx'
}

// register the listener to receive calls
cordova.plugins.BandyerPlugin.addCallClientListener(); 

// start the bandyer plugin specifying the user alias of the user you want to connect
cordova
    .plugins
    .BandyerPlugin
    .start(credentials,(succ) => {
        // start success
        // from this moment on you are connected to bandyer
        // and you are able to receive and make calls        
    }, (err) => {
        // start error
    });
```

## Make a call
To make a call you need to specify some params.

##### Make call params
- callee: an array of user aliases of the users you want to call
- typeCall: ['av'|'au'|'a'] the type of the call you want to start (av=audio-video,au=audio-upgreadable,a=audio-only)
- recording: [true|false] flag to enable recording for the call

```
cordova
    .plugins
    .BandyerPlugin
    .makeCall({
        callee: ['usr_xxx'], // call the user usr_xxx
        typeCall: 'av', // audio video call
        recording: false
    }, (succ) => {
        // make call success
        // on success the context switch to bandyer sdk which
        // launch the call screen
    }, (err) => {
        // make call error
    });
```

## Make a chat
To make a chat you need to specify some params.

##### Make chat params
- userAlias: the alias of the user you want to create a chat with
- typeCall: ['av'|'au'|'a'] the type of the call you want to start from the button displayed in the chat UI (av=audio-video,au=audio-upgreadable,a=audio-only)
- recording: [true|false] flag to enable recording for the call started from the chat UI

```
cordova
    .plugins
    .BandyerPlugin
    .makeChat({
        userAlias: 'usr_xxx',
        typeCall: 'av',
        recording: false
    }, (succ) => {
        // make chat success
        // on success the context switch to bandyer sdk which
        // launch the call screen
    }, (err) => {
        // make call error
    });
```