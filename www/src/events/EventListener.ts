import {Events} from "./Events";
import {ChatModuleStatusChanged} from "./ChatModuleStatusChanged";
import {CallModuleStatusChanged} from "./CallModuleStatusChanged";

/**
 * Event listener used to subscribe to the events fired by the Bandyer plugin
 */
export abstract class EventListener implements ChatModuleStatusChanged, CallModuleStatusChanged {

    /**
     * @ignore
     * @private
     */
    protected abstract _registerForEvent(event: string, callback: (...args: any) => void)

    on(event: Events.chatModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.callModuleStatusChanged, callback: (status: string) => void);
    on(event: Events.chatModuleStatusChanged | Events.callModuleStatusChanged, callback: (status: string) => void) {
        this._registerForEvent(event, callback)
    }

    /**
     * Available events
     */
    static events = Events;
}