/**
 * @typedef {Object} BandyerCallOptions
 * @property {!Array<string>} userAliases array of Bandyer users identifiers to call.
 * @property {!BandyerCallType} callType type of call to create.
 * @property {?boolean} recording set to true for a recorded call.
 */
interface BandyerCallOptions {
    userAliases: string[],
    callType: BandyerCallType,
    recording: boolean | null
}