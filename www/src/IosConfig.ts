//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {CallKitConfig} from "./CallKitConfig";

/**
 * Configuration for iOS platform
 */
export interface IosConfig {

    /**
     * Set to false to disable
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     * @deprecated
     */
    callkitEnabled?: boolean;

    /**
     * Specify the callkit configuration to enable the usage and it's behaviour
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: null</b>
     */
    callkit?: CallKitConfig;

    /**
     * Specify the file name of the sample video to be used as a fake capturer on an iOS simulator.
     * <br/>
     * This allows to test the call using a simulator.
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: null</b>
     */
    fakeCapturerFileName?: string;

    /**
     * Specify the key path where the bandyer notification payload can be found inside the voip push notification received
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: null</b>
     */
    voipNotificationKeyPath: string;

    /**
     * A boolean flag specifying whether the broadcast screen sharing tool is enabled or not.
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: false</b>
     */
    broadcastScreenSharingEnabled?: boolean;
}
