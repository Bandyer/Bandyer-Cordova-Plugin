//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

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
