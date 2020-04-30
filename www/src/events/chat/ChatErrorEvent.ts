//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Events} from "../Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when a chat error has occurred</font>
 * </h3>
 * @event Chat Error Event
 */
export interface ChatErrorEvent {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event chatError
     * @param callback with the reason as parameter
     */
    on(event: Events.chatError, callback: ((reason: string) => void));
}
