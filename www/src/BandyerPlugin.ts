//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import "core-js/es/map";
import {EventListener} from "./events/EventListener";
import {BandyerPluginConfigs} from "./BandyerPluginConfigs";
import {CreateCallOptions} from "./CreateCallOptions";
import {UserDetails} from "./UserDetails";
import {CreateChatOptions} from "./CreateChatOptions";
import {CallType} from "./CallType";
import {IllegalArgumentError} from "./errors/IllegalArgumentError";
import {assertType} from "typescript-is";
import {Environments} from "./Environments";
import {CallDisplayMode} from "./CallDisplayMode";
import {CallKitConfig} from "./CallKitConfig";
import {UserDetailsFormat} from "./UserDetailsFormat";
import {UserDetailsFormatValidator} from "./UserDetailsFormatValidator"

/**
 * @ignore
 */
declare let cordova: Cordova;

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

    /**
     * Available call types
     */
    static callTypes = CallType;

    /**
     * Available environments
     */
    static environments = Environments;

    /**
     * Available display modes
     */
    static callDisplayModes = CallDisplayMode;

    /**
     * Call this method when device is ready to setup the plugin
     * @param params
     * @throws IllegalArgumentError
     */
    static setup(params: BandyerPluginConfigs): BandyerPlugin {
        assertType<BandyerPluginConfigs>(params);

        if (params.appId === "") {
            throw new IllegalArgumentError("Expected a not empty appId!");
        }

        if (this._isIos() && device.isVirtual && (!params.iosConfig.fakeCapturerFileName || params.iosConfig.fakeCapturerFileName === "")) {
            throw new IllegalArgumentError("Expected a valid file name to initialize the fake capturer on a simulator!");
        }

        if (this.instance) {
            console.warn("BandyerPlugin was already setup.");
            return this.instance;
        }

        const success = (result) => {
            const event = result.event.toLowerCase();
            const callbacks = _bandyerHandlers.get(event);
            if (!callbacks) {
                return;
            }
            callbacks.forEach((callback) => {
                callback.apply(undefined, result.args);
            });
        };

        const fail = (error) => {
            console.error("BandyerPluginSetup failed setup", error);
        };


        const callkit: CallKitConfig = params.iosConfig?.callkit !== undefined ? params.iosConfig.callkit : {enabled: params.iosConfig?.callkitEnabled !== false};

        cordova.exec(success, fail, "BandyerPlugin", "initializeBandyer", [{
            environment: params.environment.name,
            appId: params.appId,
            logEnabled: params.logEnabled === true,
            ios_callkit: callkit,
            ios_fakeCapturerFileName: params.iosConfig?.fakeCapturerFileName,
            ios_voipNotificationKeyPath: params.iosConfig?.voipNotificationKeyPath,
            android_isCallEnabled: params.androidConfig?.callEnabled !== false,
            android_isFileSharingEnabled: params.androidConfig?.fileSharingEnabled !== false,
            android_isScreenSharingEnabled: params.androidConfig?.screenSharingEnabled !== false,
            android_isChatEnabled: params.androidConfig?.chatEnabled !== false,
            android_isWhiteboardEnabled: params.androidConfig?.whiteboardEnabled !== false,
            android_keepListeningForEventsInBackground: params.androidConfig?.keepListeningForEventsInBackground === true,
        }]);

        this.instance = new BandyerPlugin();
        return this.instance;
    }

    /**
     * @ignore
     * @private
     */
    private static _isAndroid() {
        return device.platform.toLowerCase() === "android";
    }

    /**
     * @ignore
     * @private
     */
    private static _isIos() {
        return device.platform.toLowerCase() === "ios";
    }

    private constructor() {
        super();
    }

    /**
     * Start the plugin to be used by the userAlias provided
     * @param userAlias identifier for the user
     * @throws IllegalArgumentError
     */
    startFor(userAlias: string) {
        assertType<string>(userAlias);

        if (userAlias === "") {
            throw new IllegalArgumentError("Expected a not empty userAlias!");
        }
        // check userAlias
        cordova.exec(null, null, "BandyerPlugin", "start", [{
            userAlias,
        }]);
    }

    /**
     * Stop the plugin
     */
    stop() {
        cordova.exec(null, null, "BandyerPlugin", "stop", []);
    }

    /**
     * Pause the plugin
     */
    pause() {
        cordova.exec(null, null, "BandyerPlugin", "pause", []);
    }

    /**
     * Resume the plugin
     */
    resume() {
        cordova.exec(null, null, "BandyerPlugin", "resume", []);
    }

    /**
     * Get the current state of the plugin
     * @return the state as a promise
     */
    state() {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, "BandyerPlugin", "state", []);
        });
    }

    /**
     * Start Call with the callee defined
     * @param callOptions
     * @throws IllegalArgumentError
     */
    startCall(callOptions: CreateCallOptions) {
        assertType<CreateCallOptions>(callOptions);

        if (callOptions.userAliases.length === 0) {
            throw new IllegalArgumentError("No userAliases were provided!");
        }
        if (callOptions.userAliases.filter((str) => str.trim().length <= 0).length > 0) {
            throw new IllegalArgumentError("Some empty userAliases were provided");
        }

        cordova.exec(null, null, "BandyerPlugin", "startCall", [{
            callee: callOptions.userAliases,
            callType: callOptions.callType,
            recording: callOptions.recording,
        }]);
    }

    /**
     * Verify the user for the current call
     * @param verify true if the user is verified, false otherwise
     * @throws IllegalArgumentError
     */
    verifyCurrentCall(verify: boolean) {
        assertType<boolean>(verify);

        if (BandyerPlugin._isAndroid()) {
            cordova.exec(null, null, "BandyerPlugin", "verifyCurrentCall", [{verifyCall: verify}]);
        } else {
            console.warn("Not yet supported on ", device.platform, " platform.");
        }

    }

    /**
     * Set the UI display mode for the current call
     * @param mode FOREGROUND, FOREGROUND_PICTURE_IN_PICTURE, BACKGROUND
     * @throws IllegalArgumentError
     */
    setDisplayModeForCurrentCall(mode: CallDisplayMode) {
        assertType<CallDisplayMode>(mode);

        if (BandyerPlugin._isAndroid()) {
            cordova.exec(null, null, "BandyerPlugin", "setDisplayModeForCurrentCall", [{displayMode: mode}]);
        } else {
            console.warn("Not supported by ", device.platform, " platform.");
        }
    }

    /**
     * Start Call from url
     * @param url received
     * @throws IllegalArgumentError
     */
    startCallFrom(url: string) {
        assertType<string>(url);

        if (url === "") {
            throw new IllegalArgumentError("Expected a not empty url!");
        }

        cordova.exec(null, null, "BandyerPlugin", "startCall", [{
            joinUrl: url === "undefined" ? "" : url,
        }]);
    }

    // noinspection JSMethodCanBeStatic
    /**
     * Call this method to provide the details for each user. The Bandyer Plugin will use this information
     * to setup the UI
     * @param userDetails  array of user details
     * @throws IllegalArgumentError
     */
    addUsersDetails(userDetails: UserDetails[]) {
        assertType<UserDetails[]>(userDetails);

        if (userDetails.length === 0) {
            throw new IllegalArgumentError("No userDetails were provided!");
        }
        cordova.exec(null, null, "BandyerPlugin", "addUsersDetails", [{
            details: userDetails,
        }]);
    }

    setUserDetailsFormat(format: UserDetailsFormat) {
        assertType<UserDetailsFormat>(format);

        const validator = new UserDetailsFormatValidator();
        validator.validate(format.default)

        if (format.android_notification) {
            validator.validate(format.android_notification)
        }

        cordova.exec(null, null, "BandyerPlugin", "setUserDetailsFormat", [{
            format: format.default,
            android_notification_format: format.android_notification,
        }]);
    }

    /**
     * Call this method to remove all the user details previously provided.
     */
    removeUsersDetails() {
        cordova.exec(null, null, "BandyerPlugin", "removeUsersDetails", []);
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
        assertType<string>(payload);

        if (payload === "") {
            throw new IllegalArgumentError("Expected a not empty payload!");
        }

        cordova.exec(success, error, "BandyerPlugin", "handlePushNotificationPayload", [{
            payload: typeof payload === "undefined" ? "" : payload,
        }]);
    }

    /**
     * Open chat
     * @param chatOptions
     * @throws IllegalArgumentError
     */
    startChat(chatOptions: CreateChatOptions) {
        assertType<CreateChatOptions>(chatOptions);

        if (chatOptions.userAlias === "") {
            throw new IllegalArgumentError("Expected a not empty userAlias!");
        }

        cordova.exec(null, null, "BandyerPlugin", "startChat", [{
            userAlias: chatOptions.userAlias,
            audio: chatOptions.withAudioCallCapability,
            audioUpgradable: chatOptions.withAudioUpgradableCallCapability,
            audioVideo: chatOptions.withAudioVideoCallCapability,
        }]);
    }

    /**
     * This methods allows you to clear all user cached data, such as chat messages and generic bandyer informations.
     * @param success callback
     * @param error callback
     */
    clearUserCache(success?: () => void, error?: (reason) => void) {
        if (BandyerPlugin._isAndroid()) {
            cordova.exec(success, error, "BandyerPlugin", "clearUserCache", []);
        } else {
            console.warn("Not yet supported on ", device.platform, " platform.");
        }
    }

    protected _registerForEvent(event, callback) {
        const eventLowerCase = event.toLowerCase();
        if (_bandyerHandlers.get(eventLowerCase) === undefined) {
            _bandyerHandlers.set(eventLowerCase, [callback]);
        } else {
            _bandyerHandlers.get(eventLowerCase).push(callback);
        }
    }
}
