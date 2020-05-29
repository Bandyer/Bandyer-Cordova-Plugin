//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

/**
 * This enum defines all the events that may be handled
 * <br/>
 * <br/>
 * You can listen to these events via [[BandyerPlugin.on]]
 */
export enum Events {

    /**
     * @see [[SetupSuccessEvent]]
     */
    setupSuccess = "setupSuccess",
    /**
     * @see [[SetupErrorEvent]]
     */
    setupError = "setupError",
    /**
     * @see [[CallStatusChangedEvent]]
     */
    callModuleStatusChanged = "callModuleStatusChanged",
    /**
     * @see [[CallErrorEvent]]
     */
    callError = "callError",
    /**
     * @see [[ChatErrorEvent]]
     */
    chatError = "chatError",
    /**
     * @see [[ChatStatusChangedEvent]]
     */
    chatModuleStatusChanged = "chatModuleStatusChanged",
    /**
     * @see [[VoipPushTokenEvents]]
     */
    iOSVoipPushTokenUpdated = "iOSVoipPushTokenUpdated",
    /**
     * @see [[VoipPushTokenEvents]]
     */
    iOSVoipPushTokenInvalidated = "iOSVoipPushTokenInvalidated",
}
