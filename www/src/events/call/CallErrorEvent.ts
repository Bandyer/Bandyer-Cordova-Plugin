//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Events} from "../Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when a call error has occurred</font>
 * </h3>
 * @event Call Error Event
 */
export interface CallErrorEvent {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event callError
     * @param callback with the reason as parameter
     */
    on(event: Events.callError, callback: ((reason: string) => void));
}
