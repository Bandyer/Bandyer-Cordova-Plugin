package com.bandyer.cordova.plugin

/**
 * This is used by Bandyer to define the user details in the call/chat UI
 */
data class UserDetails (
    /**
     * Email of the user
     */
    val email: String? = null,

    /**
     * First name of the user
     */
    val firstName: String? = null,

    /**
     * Last name of the user
     */
    val lastName: String? = null,

    /**
     * Nickname for the user
     */
    val nickName: String? = null,

    /**
     * Image url to use as placeholder for the user.
     */
    val profileImageURL: String? = null,

    /**
     * Bandyer user identifier
     */
    val userAlias: String
)