//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

import {CallOptions} from "./CallOptions";

/**
 * Options to be used when create a chat
 */
export interface CreateChatOptions {

    /**
     * Bandyer user identifier to chat with.
     */
    userAlias: string;

    /**
     * Defining this object will enable an option to start an audio only call from chat UI
     */
    withAudioCallCapability?: CallOptions;

    /**
     * Defining this object will enable an option to start an audio upgradable call from chat UI
     */
    withAudioUpgradableCallCapability?: CallOptions;

    /**
     * Defining this object will enable an option to start an audio&video call from chat UI
     */
    withAudioVideoCallCapability?: CallOptions;
}
