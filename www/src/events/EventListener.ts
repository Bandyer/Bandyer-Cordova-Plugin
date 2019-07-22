/* tslint:disable:unified-signatures */
import {Events} from "./Events";
import {CallStatusChangedEvent} from "./call/CallStatusChangedEvent";
import {ChatStatusChangedEvent} from "./chat/ChatStatusChangedEvent";
import {IllegalArgumentError} from "../errors/IllegalArgumentError";
import {is} from "typescript-is";
import {SetupErrorEvent} from "./SetupErrorEvent";
import {CallErrorEvent} from "./call/CallErrorEvent";
import {ChatErrorEvent} from "./chat/ChatErrorEvent";

/**
 * Event listener used to subscribe to the events fired by the Bandyer plugin
 */
export abstract class EventListener implements CallStatusChangedEvent, ChatStatusChangedEvent, SetupErrorEvent, CallErrorEvent, ChatErrorEvent {
    /**
     * Available events
     */
    static events = Events;

    on(event: Events.callModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.chatModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.setupError, callback: (reason: string) => void);
    on(event: Events.callError, callback: (reason: string) => void);
    on(event: Events.chatError, callback: (reason: string) => void);
    on(event: Events.callModuleStatusChanged | Events.chatModuleStatusChanged | Events.setupError | Events.callError | Events.chatError, callback: ((status: string) => void)) {
        if (!is<Events>(event)) {
            throw new IllegalArgumentError("Expected an event of type Events!");
        }
        this._registerForEvent(event, callback);
    }

    /**
     * @ignore
     * @private
     */
    protected abstract _registerForEvent(event: string, callback: (...args: any) => void);
}
