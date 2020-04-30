//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

/* tslint:disable:unified-signatures */
import {Events} from "./Events";
import {CallStatusChangedEvent} from "./call/CallStatusChangedEvent";
import {ChatStatusChangedEvent} from "./chat/ChatStatusChangedEvent";
import {assertType} from "typescript-is";
import {SetupErrorEvent} from "./SetupErrorEvent";
import {CallErrorEvent} from "./call/CallErrorEvent";
import {ChatErrorEvent} from "./chat/ChatErrorEvent";
import {VoipPushTokenEvents} from "./call/VoipPushTokenEvents";

/**
 * Event listener used to subscribe to the events fired by the Bandyer plugin
 */
export abstract class EventListener implements CallStatusChangedEvent, ChatStatusChangedEvent, SetupErrorEvent, CallErrorEvent, ChatErrorEvent, VoipPushTokenEvents {
    /**
     * Available events
     */
    static events = Events;

    on(event: Events.callModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.chatModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.setupError, callback: (reason: string) => void);
    on(event: Events.callError, callback: (reason: string) => void);
    on(event: Events.chatError, callback: (reason: string) => void);
    on(event: Events.iOSVoipPushTokenUpdated, callback: (token: string) => void);
    on(event: Events.iOSVoipPushTokenInvalidated, callback: () => void);
    on(event: Events.callModuleStatusChanged | Events.chatModuleStatusChanged | Events.setupError | Events.callError | Events.chatError | Events.iOSVoipPushTokenUpdated | Events.iOSVoipPushTokenInvalidated, callback: ((status: string) => void) | (() => void)) {
        assertType<Events>(event);
        this._registerForEvent(event, callback);
    }

    /**
     * @ignore
     * @private
     */
    protected abstract _registerForEvent(event: string, callback: (...args: any) => void);
}
