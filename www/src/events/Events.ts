/**
 * This enum defines all the events that may be handled
 * <br/>
 * <br/>
 * You can listen to these events via [[BandyerPlugin.on]]
 */
export enum Events {
    /**
     * @see [[ChatModuleStatusChanged]]
     */
    chatModuleStatusChanged = 'chatModuleStatusChanged',

    /**
     * @see [[CallModuleStatusChanged]]
     */
    callModuleStatusChanged = 'callModuleStatusChanged'
}