import {CallType} from "./CallType";
import {CallOptions} from "./CallOptions";

/**
 * Options to be used when creating a call
 */
export interface CreateCallOptions extends CallOptions {

    /**
     * Array of Bandyer users identifiers to call.
     */
    userAliases: string[];

    /**
     * Type of call to create
     */
    callType: CallType;
}
