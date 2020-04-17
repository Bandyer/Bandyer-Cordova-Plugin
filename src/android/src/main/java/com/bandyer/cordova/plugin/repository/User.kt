package com.bandyer.cordova.plugin.repository

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable


/**
 * @suppress
 * @author kristiyan
 */
@Entity
data class User(@PrimaryKey val userAlias: String) {

    var firstName: String? = null
    var lastName: String? = null
    var nickName: kotlin.String? = null

    var email: kotlin.String? = null

    var imageUrl: kotlin.String? = null
}