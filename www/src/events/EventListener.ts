import {Events} from "./Events";
import {ChatModuleStatusChanged} from "./ChatModuleStatusChanged";
import {CallModuleStatusChanged} from "./CallModuleStatusChanged";
import {is} from "typescript-is";
import {IllegalArgumentError} from "../errors/IllegalArgumentError";
import {CallError} from "./CallError";
import {ChatError} from "./ChatError";

/**
 * Event listener used to subscribe to the events fired by the Bandyer plugin
 */
export abstract class EventListener implements ChatModuleStatusChanged,
    CallModuleStatusChanged,
    CallError,
    ChatError {

    /**
     * @ignore
     * @private
     */
    protected abstract _registerForEvent(event: string, callback: (...args: any) => void)

    /**
     * Available events
     */
    static events = Events;

    on(event: Events.chatModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.callModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.callError, callback: (reason: string) => void);
    on(event: Events.chatError, callback: (reason: string) => void);
    on(event: Events.chatModuleStatusChanged | Events.callModuleStatusChanged | Events.callError | Events.chatError, callback: ((status: string) => void)) {
        if (!is<Events>(event)) {
            throw new IllegalArgumentError("Expected an event of type Events!");
        }
        this._registerForEvent(event, callback)
    }
}