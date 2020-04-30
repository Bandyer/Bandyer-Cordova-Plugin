//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

/**
 * Configuration for callkit
 */
export interface CallKitConfig {

    /**
     * Set to false to disable
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    enabled: boolean;

    /**
     * The icon resource name to be used in the callkit UI to represent the app
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: null</b>
     */
    appIconName?: string;

    /**
     * The ringtone resource name to be used when callkit is launched
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: system</b>
     */
    ringtoneSoundName?: string;

}
