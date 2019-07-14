/**
 * @typedef {Object} BandyerUserDetails
 * @property {!string} userAlias Bandyer user identifier .
 * @property {?string} nickName nickname for the user.
 * @property {?string} firstName first name of the user.
 * @property {?string} lastName last name of the user.
 * @property {?string} email email of the user.
 * @property {?string} profileImageUrl image url to use as placeholder for the user.
 */
interface BandyerUserDetails {
    userAlias: string,
    nickName: string | null,
    firstName: string | null,
    lastName: string | null,
    email: string | null,
    profileImageUrl: string | null
}