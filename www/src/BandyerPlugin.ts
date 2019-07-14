//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//
import "core-js/stable";
import "regenerator-runtime/runtime";

declare let cordova: any;
declare let device: any;

/**
 * @ignore
 * @private
 */
const _bandyerHandlers = new Map();

/**
 * BandyerPlugin
 */
export class BandyerPlugin {

    /**
     *
     * @param {!string} event
     * @param {?function(args:...Object)} callback
     */
    static on(event, callback) {
        if (_bandyerHandlers.get(event) === undefined) {
            _bandyerHandlers.set(event, [callback]);
        } else {
            _bandyerHandlers.get(event).push(callback);
        }
    }

    /**
     * Call this method when device is ready to setup the plugin
     * @param {!BandyerPluginConfigs} params
     */
    static setup(params: BandyerPluginConfigs) {
        const success = result => {
            _bandyerHandlers.get(result.event).forEach(callback => {
                callback.apply(undefined, result.args);
            });
        };

        const fail = error => {
            console.log("callbackErrorSetup");
            console.log(error);
        };

        cordova.exec(success, fail, 'BandyerPlugin', 'initializeBandyer', [{
            environment: typeof params.environment === 'undefined' ? '' : params.environment,
            appId: typeof params.appId === 'undefined' ? '' : params.appId,
            logEnabled: typeof params.logEnabled === 'undefined' ? false : params.logEnabled,
            ios_callkitEnabled: typeof params.ios_callkitEnabled === 'undefined' ? false : params.ios_callkitEnabled,
            android_isCallEnabled: typeof params.android_isCallEnabled === 'undefined' ? false : params.android_isCallEnabled,
            android_isFileSharingEnabled: typeof params.android_isFileSharingEnabled === 'undefined' ? false : params.android_isFileSharingEnabled,
            android_isScreenSharingEnabled: typeof params.android_isScreenSharingEnabled === 'undefined' ? false : params.android_isScreenSharingEnabled,
            android_isChatEnabled: typeof params.android_isChatEnabled === 'undefined' ? false : params.android_isChatEnabled,
            android_isWhiteboardEnabled: typeof params.android_isWhiteboardEnabled === 'undefined' ? false : params.android_isWhiteboardEnabled
        }]);
    }

    /**
     * Start the plugin to be used by the userAlias provided
     * @param {!string} userAlias identifier for the user
     */
    static startFor(userAlias: string[]) {
        // check userAlias
        cordova.exec(null, null, 'BandyerPlugin', 'start', [{
            userAlias: typeof userAlias === 'undefined' ? '' : userAlias
        }]);
    }

    /**
     * Stop the plugin
     */
    static stop() {
        cordova.exec(null, null, 'BandyerPlugin', 'stop', []);
    }

    /**
     * Pause the plugin
     */
    static pause() {
        cordova.exec(null, null, 'BandyerPlugin', 'pause', []);
    }

    /**
     * Resume the plugin
     */
    static resume() {
        cordova.exec(null, null, 'BandyerPlugin', 'resume', []);
    }

    /**
     * Get the current state of the plugin,
     * @return {Promise<string>} state called when the plugin has changed its status
     */
    static state() {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'BandyerPlugin', 'state', []);
        });
    }

    /**
     * Start Call with the callee defined
     * @param {BandyerCallOptions} callOptions
     */
    static startCall(callOptions: BandyerCallOptions) {
        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            callee: typeof callOptions.userAliases === 'undefined' ? [] : callOptions.userAliases,
            callType: typeof callOptions.callType === 'undefined' ? '' : callOptions.callType,
            recording: typeof callOptions.recording === 'undefined' ? false : callOptions.recording
        }]);
    }

    /**
     * Start Call from url
     * @param {string} url received
     */
    static startCallFrom(url: string) {
        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            joinUrl: url === 'undefined' ? '' : url
        }]);
    }

    /**
     * Call this method to provide the details for each user. The Bandyer Plugin will use this information
     * to setup the UI
     * @param {Array<BandyerUserDetails>} userDetails  array of user details
     */
    static addUsersDetails(userDetails: BandyerUserDetails[]) {
        cordova.exec(null, null, 'BandyerPlugin', 'addUsersDetails', [{
            details: typeof userDetails === 'undefined' ? [] : userDetails
        }]);
    }

    /**
     * Call this method to remove all the user details previously provided.
     */
    static removeUsersDetails() {
        cordova.exec(null, null, 'BandyerPlugin', 'removeUsersDetails', []);
    }

    /**
     * Call this method to allow Bandyer to handle a notification!
     *
     * **IMPORTANT**
     *
     * For Android no js method will ever be called when the app is closed or in background!
     *
     * To handle notifications while in background and/or with app closed you may:
     * - use phonegap-plugin-push and set server side a parameter {"force-start": "1"} when the notification is created  (This will open the app and put it right away in background and then handle the notifications)
     * - Handle yourself the notifications natively, it will allow you to define a different behaviour based on your own logic
     * - Define the lines as described in our documentation in your config.xml and the bandyer-plugin will handle them for you natively (No handling notification callback via js will ever be called, `BandyerPlugin.handlePushNotificationPayload` included)
     *
     * @param {!string} payload notification data payload as String
     * @param {?function(): void} success callback
     * @param {?function(): void} error callback
     */
    static handlePushNotificationPayload(payload: string, success, error) {
        cordova.exec(success, error, 'BandyerPlugin', 'handlePushNotificationPayload', [{
            payload: typeof payload === 'undefined' ? '' : payload
        }]);
    }

    /**
     * Open chat
     * @param {BandyerChatOptions} chatOptions
     */
    static startChat(chatOptions: BandyerChatOptions) {
        if (this._isAndroid()) {
            cordova.exec(null, null, 'BandyerPlugin', 'startChat', [{
                userAlias: typeof chatOptions.userAlias === 'undefined' ? '' : chatOptions.userAlias,
                audio: typeof chatOptions.withAudioCallCapability === 'undefined' ? '' : chatOptions.withAudioCallCapability,
                audioUpgradable: typeof chatOptions.withAudioUpgradableCallCapability === 'undefined' ? false : chatOptions.withAudioUpgradableCallCapability,
                audioVideo: typeof chatOptions.withAudioVideoCallCapability === 'undefined' ? false : chatOptions.withAudioVideoCallCapability
            }]);
        } else {
            console.log('Not yet supported on ', device.platform, " platform.");
        }
    }

    /**
     * @ignore
     * @private
     */
    static _isAndroid() {
        return device.platform.toLowerCase() === "android";
    }

    /**
     * @ignore
     * @private
     */
    static _isIos() {
        return device.platform.toLowerCase() === "ios";
    }

    /**
     * This methods allows you to clear all user cached data, such as chat messages and generic bandyer informations.
     * @param {?function(): void} success callback
     * @param {?function(): void} error callback
     */
    static clearUserCache(success, error) {
        if (this._isAndroid()) {
            cordova.exec(success, error, 'BandyerPlugin', 'clearUserCache', []);
        } else {
            error('method not supported.');
        }
    }

    // GETTERS AND SETTERS
    //
    // /**
    //  * Currently Bandyer supports 3 different kind of calls.
    //  * Audio Only, Audio Upgradable to video and Audio&Video call.
    //  * @returns {CallType}
    //  * @constructor
    //  */
    // static get CallType() : BandyerCallType {
    //     return {
    //         BandyerCallType.AUDIO,
    //         BandyerCallType.AUDIO_UPGRADABLE,
    //         BandyerCallType.AUDIO_VIDEO
    //     };
    // }
}