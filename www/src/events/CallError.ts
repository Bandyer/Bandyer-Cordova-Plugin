import {Events} from "./Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired for call errors</font>
 * </h3>
 * @event callError
 */
export interface CallError {
    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event callError
     * @param callback with the reason as parameter
     */
    on(event: Events.callError, callback: ((reason: string) => void));
}
