import {IosConfig} from "./IosConfig";
import {AndroidConfig} from "./AndroidConfig";
import {Environment} from "./Environments";

/**
 * Generic configuration for the bandyer plugin
 */
export interface BandyerPluginConfigs {

    /**
     * This variable defines the environment where you will be sandbox or production.
     */
    environment: Environment;

    /**
     * This key will be provided to you by us.
     */
    appId: string;

    /**
     * Set to true to enable log, default value is false
     */
    logEnabled?: boolean;

    /**
     * Define to customize the iOS configuration
     */
    iosConfig?: IosConfig;

    /**
     * Define to customize the android configuration
     */
    androidConfig?: AndroidConfig;
}
