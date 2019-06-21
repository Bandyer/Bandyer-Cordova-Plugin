var exec = require('cordova/exec')

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              environment: 'sandbox' or 'production' (mandatory)
 *              appId: application id (mandatory)
 *              logEnabled: true or false
 *              ios_callkitEnabled: true or false
 *              android_isCallEnabled: boolean, on/off call feature
 *              android_isFileSharingEnabled: boolean, on/off file sharing feature
 *              android_isChatEnabled: boolean, on/off chat feature
 *              android_isWhiteboardEnabled: boolean, on/off whiteboard feature
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.setup = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'initializeBandyer', [
        {
            environment: (typeof(params.environment) == 'undefined') ? '' : params.environment,
            appId: (typeof(params.appId) == 'undefined') ? '' : params.appId,
            logEnabled: (typeof(params.logEnabled) == 'undefined') ? false : params.logEnabled,
            ios_callkitEnabled: (typeof(params.ios_callkitEnabled) == 'undefined') ? false : params.ios_callkitEnabled,
            android_isCallEnabled: (typeof(params.android_isCallEnabled) == 'undefined') ? false : params.android_isCallEnabled,
            android_isFileSharingEnabled: (typeof(params.android_isFileSharingEnabled) == 'undefined') ? false : params.android_isFileSharingEnabled,
            android_isScreenSharingEnabled: (typeof(params.android_isScreenSharingEnabled) == 'undefined') ? false : params.android_isScreenSharingEnabled,
            android_isChatEnabled: (typeof(params.android_isChatEnabled) == 'undefined') ? false : params.android_isChatEnabled,
            android_isWhiteboardEnabled: (typeof(params.android_isWhiteboardEnabled) == 'undefined') ? false : params.android_isWhiteboardEnabled
        }
    ])
}

exports.addCallClientListener = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'addCallClient', [])
}

exports.removeCallClientListener = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'removeCallClient', [])
}

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              username: identificativo dell'utente
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.start = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'start', [
        {
            username: (typeof(params.username) == 'undefined') ? '' : params.username
        }
    ])
}

exports.stop = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'stop', [])
}

exports.pause = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'pause', [])
}

exports.resume = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'resume', [])
}

exports.state = function (callback, error) {
    exec(callback, error, 'BandyerPlugin', 'state', [])
}

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              callee: array di utenti da chiamare
 *              joinUrl: url su cui effettuare il join
 *              callType: tipo di chiamata (a = AUDIO ONLY, au = AUDIO UPGRADABLE, av = AUDIO/VIDEO)
 *              recording: booleano che attiva il recording
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.makeCall = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'makeCall', [
        {
            callee: (typeof(params.callee) == 'undefined') ? [] : params.callee,
            joinUrl: (typeof(params.joinUrl) == 'undefined') ? '' : params.joinUrl,
            callType: (typeof(params.callType) == 'undefined') ? '' : params.callType,
            recording: (typeof(params.recording) == 'undefined') ? false : params.recording
        }
    ])
}

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              address:  array di address (mandatory)
 *                  example
 *                  address: [
 *                  {
 *                      alias: 'usr_88c63f7a1f81',
 *                      nickName: 'nickName 1',
 *                      firstName: 'firstName 1',
 *                      lastName: 'lastName 1',
 *                      email: 'email 1',
 *                      age: 18,
 *                      gender: 'M',
 *                      profileImageUrl: 'https://avatarfiles.alphacoders.com/752/75205.png'
 *                  },
 *                  {
 *                      alias: 'usr_4da08d134a37',
 *                      nickName: 'nickName 2',
 *                      firstName: 'firstName 2',
 *                      lastName: 'lastName 2',
 *                      email: 'email 2',
 *                      age: 18,
 *                      gender: 'M',
 *                      profileImageUrl: 'https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/f7/f7e50892cf0750e53d05776850361eb67eb641f1_full.jpg'
 *                  }
 *              ]
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.createUserInfoFetch = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'createUserInfoFetch', [
        {
            address: (typeof(params.address) == 'undefined') ? [] : params.address
        }
    ])
}

exports.clearCache = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'clearCache', [])
}

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              addressee: indirizzo chat
 *              callType: tipo di chiamata (a = AUDIO ONLY, au = AUDIO UPGRADABLE, av = AUDIO/VIDEO, c = CHAT ONLY)
 *              recording: booleano che attiva il recording
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.makeChat = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'makeChat', [
        {
            addressee: (typeof(params.addressee) == 'undefined') ? '' : params.addressee,
            callType: (typeof(params.callType) == 'undefined') ? '' : params.callType,
            recording: (typeof(params.recording) == 'undefined') ? false : params.recording
        }
    ])
}

/*
 *  Parameters:
 *      [params] (object):
 *          {
 *              ios_keypath: keypath for push notification
 *              payload: remote message payload as String
 *          }
 *      [success] (callback)
 *      [error] (callback)
 */
exports.handlerPayload = function (params, success, error) {
    exec(success, error, 'BandyerPlugin', 'handlerPayload', [{
        payload: (typeof(params.payload) == 'undefined') ? '' : params.payload,
        ios_keypath: (typeof(params.ios_keypath) == 'undefined') ? '' : params.ios_keypath,
    }
    ])
}

exports.clearUserCache = function (success, error) {
    exec(success, error, 'BandyerPlugin', 'clearUserCache', [])
}

/*
 *  Messages Android:
 *  android_onClientStatusChange
 *  android_onClientError
 *  android_onClientReady
 *  android_onClientStopped
 *  android_onModuleReady
 *  android_onModulePaused
 *  android_onModuleFailed
 *  android_onModuleStatusChanged
 *
 *  Messages iOS:
 *  - ios_didReceiveIncomingCall
 *  - ios_callClientWillStart
 *  - ios_callClientDidStart
 *  - ios_callClientDidStartReconnecting
 *  - ios_callClientWillPause
 *  - ios_callClientDidPause
 *  - ios_callClientWillStop
 *  - ios_callClientDidStop
 *  - ios_callClientWillResume
 *  - ios_callClientDidResume
 *  - ios_callClientFailed
 */

exports.callClientListener = function (message) {
    // console.log('callClientListener [Log]: ' + { message: message });
    cordova.fireDocumentEvent('callClientEvent', { message: message });
}

/*
 *  I messaggi ritornati dal monitoraggio sono:
 *  - ios_didReceiveIncomingPushWithPayload
 */
exports.pushRegistryListener = function (message) {
    // console.log('pushRegistryListener [Log]: ' + { message: message });
    cordova.fireDocumentEvent('pushRegistryEvent', { message: message });
}
