/**
 * Configuration for Android platform
 */
export interface AndroidConfig {

    /**
     * Set to false to disable the call feature
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    callEnabled?: boolean;

    /**
     * Set to false to disable the file sharing feature
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    fileSharingEnabled?: boolean;

    /**
     * Set to false to disable the screen sharing feature
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    screenSharingEnabled?: boolean;

    /**
     * Set to false to disable the chat feature
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    chatEnabled?: boolean;

    /**
     * Set to false to disable the whiteboard feature
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    whiteboardEnabled?: boolean;

    /**
     * Set to true to keep receiving events when in background
     * <br/>
     * This will allow your application to receive events while in background such as chat messages and incoming calls even without push notifications.
     * <br/>
     * Be aware that Android may kill your app at anytime while in background.
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: false</b>
     */
    keepListeningForEventsInBackground?: boolean;
}
