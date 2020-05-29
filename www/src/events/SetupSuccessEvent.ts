//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Events} from "./Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when the plugin has successfully finished setting up</font>
 * </h3>
 * @event Setup Success Event
 */
export interface SetupSuccessEvent {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event setupSuccess
     * @param callback
     */
    on(event: Events.setupSuccess, callback: (() => void));
}
