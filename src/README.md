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
The 