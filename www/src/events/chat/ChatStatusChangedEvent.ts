//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Events} from "../Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when the status of the call module has changed</font>
 * </h3>
 * @event Call Status Changed Event
 */
export interface ChatStatusChangedEvent {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event chatModuleStatusChanged
     * @param callback with the status as parameter
     */
    on(event: Events.chatModuleStatusChanged, callback: ((status: string) => void));
}
