/**
 * @typedef {Object} BandyerPluginConfigs
 * @property {!string} environment sandbox or production.
 * @property {!string} appId this key will be provided to you by us.
 * @property {?boolean} logEnabled set to true to enable the logs.
 * @property {?boolean} ios_callkitEnabled set to true to enable the callkit feature..
 * @property {?boolean} android_isCallEnabled set to true to enable the call feature.
 * @property {?boolean} android_isFileSharingEnabled set to true to enable the file sharing feature.
 * @property {?boolean} android_isScreenSharingEnabled set to true to enable the screen sharing feature.
 * @property {?boolean} android_isChatEnabled set to true to enable the chat feature.
 * @property {?boolean} android_isWhiteboardEnabled set to true to enable the whiteboard feature.
 */
interface BandyerPluginConfigs {
    environment: string,
    appId: string,
    logEnabled: boolean | null,
    ios_callkitEnabled: boolean | null,
    android_isCallEnabled: boolean,
    android_isFileSharingEnabled: boolean,
    android_isScreenSharingEnabled: boolean,
    android_isChatEnabled: boolean,
    android_isWhiteboardEnabled: boolean
}