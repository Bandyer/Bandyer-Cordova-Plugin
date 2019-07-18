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
import {IllegalArgumentError} from "./errors/IllegalArgumentError";
import {is} from "typescript-is";

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
     * @throws IllegalArgumentError
     */
    static setup(params: BandyerPluginConfigs): BandyerPlugin {
        if (!is<BandyerPluginConfigs>(params)) {
            throw new IllegalArgumentError("Expected an object of type BandyerPluginConfigs!");
        }
        if (params.environment === '') {
            throw new IllegalArgumentError("Expected a not empty environment!");
        }
        if (params.appId === '') {
            throw new IllegalArgumentError("Expected a not empty appId!");
        }

        if (this.instance) {
            console.log("BandyerPlugin was already setup.");
            return this.instance;
        }

        const success = result => {
            var event = result.event.toLowerCase();
            const callbacks = _bandyerHandlers.get(event);
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
            environment: params.environment,
            appId: params.appId,
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
        var eventLowerCase = event.toLowerCase();
        if (_bandyerHandlers.get(eventLowerCase) === undefined) {
            _bandyerHandlers.set(eventLowerCase, [callback]);
        } else {
            _bandyerHandlers.get(eventLowerCase).push(callback);
        }
    }

    /**
     * Start the plugin to be used by the userAlias provided
     * @param userAlias identifier for the user
     * @throws IllegalArgumentError
     */
    startFor(userAlias: string) {
        if (!is<string>(userAlias)) {
            throw new IllegalArgumentError("Expected userAlias as string!");
        }
        if (userAlias === '') {
            throw new IllegalArgumentError("Expected a not empty userAlias!");
        }
        // check userAlias
        cordova.exec(null, null, 'BandyerPlugin', 'start', [{
            userAlias: userAlias
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
     * @throws IllegalArgumentError
     */
    startCall(callOptions: CreateCallOptions) {
        if (!is<CreateCallOptions>(callOptions)) {
            throw new IllegalArgumentError("Expected an object of type CreateCallOptions!");
        }
        if (callOptions.userAliases.length === 0) {
            throw new IllegalArgumentError("No userAliases were provided!");
        }
        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            callee: callOptions.userAliases,
            callType: callOptions.callType,
            recording: callOptions.recording
        }]);
    }

    /**
     * Start Call from url
     * @param url received
     * @throws IllegalArgumentError
     */
    startCallFrom(url: string) {
        if (!is<string>(url)) {
            throw new IllegalArgumentError("Expected an url of type string!");
        }
        if (url === '') {
            throw new IllegalArgumentError("Expected a not empty url!");
        }

        cordova.exec(null, null, 'BandyerPlugin', 'startCall', [{
            joinUrl: url === 'undefined' ? '' : url
        }]);
    }

    /**
     * Call this method to provide the details for each user. The Bandyer Plugin will use this information
     * to setup the UI
     * @param userDetails  array of user details
     * @throws IllegalArgumentError
     */
    addUsersDetails(userDetails: UserDetails[]) {
        if (!is<UserDetails[]>(userDetails)) {
            throw new IllegalArgumentError("Expected an array of type UserDetails!");
        }
        if (userDetails.length === 0) {
            throw new IllegalArgumentError("No userDetails were provided!");
        }
        cordova.exec(null, null, 'BandyerPlugin', 'addUsersDetails', [{
            details: userDetails
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
     * @throws IllegalArgumentError
     */
    handlePushNotificationPayload(payload: string, success?: () => void, error?: () => void) {
        if (!is<string>(payload)) {
            throw new IllegalArgumentError("Expected a payload of type string!");
        }
        if (payload === '') {
            throw new IllegalArgumentError("Expected a not empty payload!");
        }

        cordova.exec(success, error, 'BandyerPlugin', 'handlePushNotificationPayload', [{
            payload: typeof payload === 'undefined' ? '' : payload
        }]);
    }

    /**
     * Open chat
     * @param chatOptions
     * @throws IllegalArgumentError
     */
    startChat(chatOptions: CreateChatOptions) {
        if (!is<CreateChatOptions>(chatOptions)) {
            throw new IllegalArgumentError("Expected an object of type CreateChatOptions!");
        }
        if (chatOptions.userAlias === '') {
            throw new IllegalArgumentError("Expected a not empty userAlias!");
        }

        if (this._isAndroid()) {
            cordova.exec(null, null, 'BandyerPlugin', 'startChat', [{
                userAlias: chatOptions.userAlias,
                audio: chatOptions.withAudioCallCapability,
                audioUpgradable: chatOptions.withAudioUpgradableCallCapability,
                audioVideo: chatOptions.withAudioVideoCallCapability
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