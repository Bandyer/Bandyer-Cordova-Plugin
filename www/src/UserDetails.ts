/**
 * This is used by Bandyer to define the user details in the call/chat UI
 */
export interface UserDetails {

    /**
     * Bandyer user identifier
     */
    userAlias: string;

    /**
     * Nickname for the user
     */
    nickName?: string;

    /**
     * First name of the user
     */
    firstName?: string;

    /**
     * Last name of the user
     */
    lastName?: string;

    /**
     * Email of the user
     */
    email?: string;

    /**
     * Image url to use as placeholder for the user.
     */
    profileImageUrl?: string;
}
