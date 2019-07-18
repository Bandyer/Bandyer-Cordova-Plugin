import {Events} from "./Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired for chat errors</font>
 * </h3>
 * @event chatError
 */
export interface ChatError {
    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event chatError
     * @param callback with the reason as parameter
     */
    on(event: Events.chatError, callback: ((reason: string) => void))
}