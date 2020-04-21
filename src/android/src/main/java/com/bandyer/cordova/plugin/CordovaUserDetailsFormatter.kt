package com.bandyer.cordova.plugin

import android.content.Context
import android.content.SharedPreferences
import com.bandyer.android_sdk.FormatContext
import com.bandyer.android_sdk.utils.provider.UserDetails
import com.bandyer.android_sdk.utils.provider.UserDetailsFormatter
import com.bandyer.cordova.plugin.utils.formatBy
import java.util.regex.Pattern

/**
 *
 * @author kristiyan
 */
class CordovaUserDetailsFormatter() : UserDetailsFormatter {

    private var mUsersDetailFormat: String? = null
    private var mNotificationUsersDetailFormat: String? = null

    constructor(context: Context, usersDetailFormat: String, notificationUsersDetailFormat: String? = null) : this() {
        update(context, usersDetailFormat, notificationUsersDetailFormat)
    }

    fun update(context: Context, usersDetailFormat: String, notificationUsersDetailFormat: String? = null) {
        mUsersDetailFormat = usersDetailFormat.mapToSDKUserDetails()
        mNotificationUsersDetailFormat = notificationUsersDetailFormat?.mapToSDKUserDetails()
        val preferences = context.getSharedPreferences(BandyerCordovaPluginManager.BANDYER_CORDOVA_PLUGIN_PREF, Context.MODE_PRIVATE)
        preferences.edit().putString(BANDYER_CORDOVA_PLUGIN_USER_DETAILS_FORMAT, mUsersDetailFormat).apply()
        preferences.edit().putString(BANDYER_CORDOVA_PLUGIN_NOTIFICATION_USER_DETAILS_FORMAT, mNotificationUsersDetailFormat).apply()
    }

    constructor(preferences: SharedPreferences) : this() {
        mUsersDetailFormat = preferences.getString(BANDYER_CORDOVA_PLUGIN_USER_DETAILS_FORMAT, null)
        mNotificationUsersDetailFormat = preferences.getString(BANDYER_CORDOVA_PLUGIN_NOTIFICATION_USER_DETAILS_FORMAT, null)
    }

    override fun format(userDetails: UserDetails, context: FormatContext): String {
        mUsersDetailFormat ?: return userDetails.userAlias
        return with(userDetails) {
            if (context.isNotification) mNotificationUsersDetailFormat?.let { formatBy(it) }
                    ?: formatBy(mUsersDetailFormat!!)
            else formatBy(mUsersDetailFormat!!)
        }
    }

    private fun String.mapToSDKUserDetails(): String {
        var output = this
        val regex = "(?<=\\$\\{)(.*?)(?=\\})"
        val p = Pattern.compile(regex)
        val m = p.matcher(this)
        while (m.find()) {
            val keyword = m.group()
            output = output.replace(keyword, keyword.mapToUserDetailsProperty())
        }
        return output
    }

    private fun String.mapToUserDetailsProperty(): String {
        val allFieldsSDK = UserDetails::class.java.declaredFields
        return allFieldsSDK.firstOrNull { this.contains(it.name, true) }?.name ?: return this
    }

    companion object {
        const val BANDYER_CORDOVA_PLUGIN_USER_DETAILS_FORMAT = "BANDYER_CORDOVA_PLUGIN_USER_DETAILS_FORMAT"
        const val BANDYER_CORDOVA_PLUGIN_NOTIFICATION_USER_DETAILS_FORMAT = "BANDYER_CORDOVA_PLUGIN_NOTIFICATION_USER_DETAILS_FORMAT"
    }
}