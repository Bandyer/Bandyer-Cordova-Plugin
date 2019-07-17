//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//
import "core-js/stable";
import "regenerator-runtime/runtime";
import {EventListener} from "./events/EventListener";
import {BandyerPluginConfigs} from "./BandyerPluginConfigs";
import {CreateCallOptions} from "./CreateCallOptions";
import {UserDetails} from "./UserDetails";
import {CreateChatOptions} from "./CreateChatOptions";
import {CallType} from "./CallType";

/**
 * @ignore
 */
declare let cordova: any;

/**
 * @ignore
 */
declare let device: any;

/**
 * @ignore
 * @private
 */
const _bandyerHandlers = new Map();

/**
 * BandyerPlugin
 */
export class BandyerPlugin extends EventListener {

    /**
     * <b>To create an instance of the Bandyer Plugin call the [[setup]] method</b>
     */
    static instance: BandyerPlugin;

    private constructor() {
        super()
    }

    /**
     * Available call types
     */
    static callTypes = CallType;

    /**
     * Call this method when device is ready to setup the plugin
     * @param params
     */
    static setup(params: BandyerPluginConfigs): BandyerPlugin {
        if (this.instance) {
            console.log("BandyerPlugin was already setup.");
            return this.instance;
        }

        const success = result => {
            const callbacks = _bandyerHandlers.get(result.event);
            if (!callbacks) return;
            callbacks.forEach(callback => {
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
            logEnabled: params.logEnabled === true,
            ios_callkitEnabled: params.iosConfig.callkitEnabled !== false,
            android_isCallEnabled: params.androidConfig.callEnabled !== false,
            android_isFileSharingEnabled: params.androidConfig.fileSharingEnabled !== false,
            android_isScreenSharingEnabled: params.androidConfig.screenSharingEnabled !== false,
            android_isChatEnabled: params.androidConfig.chatEnabled !== false,
            android_isWhiteboardEnabled: params.androidConfig.whiteboardEnabled !== false
        }]);

        this.instance = new BandyerPlugin();
        return this.instance
    }

    protected _registerForEvent(event, callback) {
        if (_bandyerHandlers.get(event) === undefined) {
            _bandyerHandlers.set(event, [callback]);
        } else {
            _bandyerHandlers.get(event).push(callback);
        }
    }

    /**
     * Start the plugin to be used by the userAlias provided
     * @param userAlias identifier for the user
     */
    startFor(userAlias: string[]) {
        // check userAlias
        cordova.exec(null, null, 'BandyerPlugin', 'start', [{
            userAlias: typeof userAlias === 'undefined' ? '' : userAlias
        }]);
    }

    /**
     * Stop the plugin
     */
    stop() {
        cordova.exec(null, null, 'BandyerPlugin', 'stop', []);
    }

    /**
     * Pause the plugin
     */
    pause() {
        cordova.exec(null, null, 'BandyerPlugin', 'pause', []);
    }

    /**
     * Resume the plugin
     */
    resume() {
        cordova.exec(null, null, 'BandyerPlugin', 'resume', []);
    }

    /**
     * Get the current state of the plugin
     * @return the state as a promise
     */
    state() {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'BandyerPlugin', 'state', []);
        });
    }

    /**
     * Start Call with the callee defined
     * @param callOptions
     */
    startCall(callOptions: CreateCallOptions) {
        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            callee: typeof callOptions.userAliases === 'undefined' ? [] : callOptions.userAliases,
            callType: typeof callOptions.callType === 'undefined' ? '' : callOptions.callType,
            recording: typeof callOptions.recording === 'undefined' ? false : callOptions.recording
        }]);
    }

    /**
     * Start Call from url
     * @param url received
     */
    startCallFrom(url: string) {
        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            joinUrl: url === 'undefined' ? '' : url
        }]);
    }

    /**
     * Call this method to provide the details for each user. The Bandyer Plugin will use this information
     * to setup the UI
     * @param userDetails  array of user details
     */
    addUsersDetails(userDetails: UserDetails[]) {
        cordova.exec(null, null, 'BandyerPlugin', 'addUsersDetails', [{
            details: typeof userDetails === 'undefined' ? [] : userDetails
        }]);
    }

    /**
     * Call this method to remove all the user details previously provided.
     */
    removeUsersDetails() {
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
     * @param payload notification data payload as String
     * @param success callback
     * @param error callback
     */
    handlePushNotificationPayload(payload: string, success?: () => void, error?: () => void) {
        cordova.exec(success, error, 'BandyerPlugin', 'handlePushNotificationPayload', [{
            payload: typeof payload === 'undefined' ? '' : payload
        }]);
    }

    /**
     * Open chat
     * @param chatOptions
     */
    startChat(chatOptions: CreateChatOptions) {
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
    private _isAndroid() {
        return device.platform.toLowerCase() === "android";
    }

    /**
     * @ignore
     * @private
     */
    private _isIos() {
        return device.platform.toLowerCase() === "ios";
    }

    /**
     * This methods allows you to clear all user cached data, such as chat messages and generic bandyer informations.
     * @param success callback
     * @param error callback
     */
    clearUserCache(success?: () => void, error?: (reason) => void) {
        if (this._isAndroid()) {
            cordova.exec(success, error, 'BandyerPlugin', 'clearUserCache', []);
        } else {
            error('method not supported.');
        }
    }
}