//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {Events} from "../Events";

/**
 * You shall listen to this event via [[BandyerPlugin.on]]
 * <br/>
 * <h3>
 * <font color="gray">This event will be fired when the plugin has failed to setup</font>
 * </h3>
 * @event Setup Error Event
 */
export interface VoipPushTokenEvents {

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event setupError
     * @param callback with the reason as parameter
     */
    on(event: Events.iOSVoipPushTokenUpdated, callback: ((token: string) => void));

    /**
     * Register to this event via [[BandyerPlugin.on]]
     * @param event setupError
     * @param callback with the reason as parameter
     */
    on(event: Events.iOSVoipPushTokenInvalidated, callback: (() => void));
}
