//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

/**
 * This class defines the display modes supported per call.
 */
export enum CallDisplayMode {

    /**
     * The call UI fits completely the available window.
     */
    FOREGROUND = "FOREGROUND",

    /**
     * If the device has picture in picture feature the call UI is floating on the screen's device.
     */
    FOREGROUND_PICTURE_IN_PICTURE = "FOREGROUND_PICTURE_IN_PICTURE",

    /**
     * The call UI is not visible to the user.
     */
    BACKGROUND = "BACKGROUND",
}
