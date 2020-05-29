package com.bandyer.cordova.plugin.utils

import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.cordova.plugin.repository.User
import java.util.regex.Pattern
import kotlin.reflect.full.declaredMemberProperties

/**
 *
 * @author kristiyan
 */
fun User.toUserDetails(): UserDetails {
    return UserDetails.Builder(userAlias).also { builder ->

        firstName?.let { builder.withFirstName(it) }
        lastName?.let { builder.withLastName(it) }
        nickName?.let { builder.withNickName(it) }

        email?.let { builder.withEmail(it) }

        imageUrl?.let { builder.withImageUrl(it) }
    }.build()
}

fun UserDetails.toUser(): User {
    return User(userAlias).also {

        it.firstName = this.firstName
        it.lastName = this.lastName
        it.nickName = this.nickName

        it.email = this.email

        it.imageUrl = this.imageUrl
    }
}

fun UserDetails.formatBy(textToFormat: String): String {
    var output = textToFormat
    val regex = "(?<=\\$\\{)(.*?)(?=\\})";
    val p = Pattern.compile(regex);
    val m = p.matcher(textToFormat);
    while (m.find()) {
        val keyword = m.group()
        val value = this::class::declaredMemberProperties.get().firstOrNull { it.name == keyword }
        output = output.replace("\${$keyword}", value?.call(this).toString())
    }
    return output
}