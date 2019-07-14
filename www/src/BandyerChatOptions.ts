/**
 * @typedef {Object} BandyerChatOptions
 * @property {!string} userAlias Bandyer user identifier to chat with.
 * @property {?CallOptions} withAudioVideoCallCapability object which allows to enable audio&video call from chat
 * @property {?CallOptions} withAudioCallCapability object which allows to enable audio only call from chat
 * @property {?CallOptions} withAudioUpgradableCallCapability object which allows to enable audio upgradable call from chat
 */
interface BandyerChatOptions {
    userAlias: string,
    withAudioVideoCallCapability: CallOptions | null,
    withAudioCallCapability: CallOptions | null,
    withAudioUpgradableCallCapability: CallOptions | null
}

/**
 * @typedef {Object} CallOptions
 * @property {?boolean} recording set to true for a recorded call.
 */
interface CallOptions {
    recording: boolean | null
}