/**
 * Configuration for iOS platform
 */
export interface IosConfig {

    /**
     * Set to false to disable
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: true</b>
     */
    callkitEnabled?: boolean;

    /**
     * Specify the file name of the sample video to be used as a fake capturer on an iOS simulator.
     * <br/>
     * This allows to test the call using a simulator.
     * <br/>
     * <br/>
     * <b><font color="blue">default</font>: null</b>
     */
    fakeCapturerFileName?: string;
}
