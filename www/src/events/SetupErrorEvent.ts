import {Events} from "./Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when the plugin has failed to setup</font>
 * </h3>
 * @event Setup Error Event
 */
export interface SetupErrorEvent {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event setupError
     * @param callback with the reason as parameter
     */
    on(event: Events.setupError, callback: ((reason: string) => void));
}