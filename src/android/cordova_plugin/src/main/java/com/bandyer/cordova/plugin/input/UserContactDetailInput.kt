package com.bandyer.cordova.plugin.input

import com.bandyer.cordova.plugin.Constants
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_ALIAS
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_EMAIL
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_FIRSTNAME
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_LASTNAME
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_NICKNAME
import com.bandyer.cordova.plugin.Constants.VALUE_CALL_KEY_PROFILE_IMAGE_URL
import org.json.JSONArray
import org.json.JSONObject
import java.util.*


class UserContactDetailInput(var alias: String) {

    var nickName: String? = null
    var firstName: String? = null
    var lastName: String? = null
    var email: String? = null
    var profileImageUrl: String? = null

    companion object {

        @Throws(PluginInputNotValidException::class)
        fun createFrom(argsArray: JSONArray): List<UserContactDetailInput> {
            val list = ArrayList<UserContactDetailInput>()
            try {
                val args = argsArray.get(0) as JSONObject
                val address = if (args.has(Constants.ARG_ADDRESS)) args.getJSONArray(Constants.ARG_ADDRESS) else JSONArray()
                val len = address.length()
                if (len == 0) {
                    throw PluginInputNotValidException("Input list cannot be empty ")
                }
                for (i in 0 until len) {
                    list.add(createSingleUser(address.getJSONObject(i)))
                }
                return list
            } catch (t: Throwable) {
                throw PluginInputNotValidException("error on UserContactDetailInput " + t.message, t)
            }
        }

        @Throws(PluginInputNotValidException::class)
        private fun createSingleUser(user: JSONObject): UserContactDetailInput {
            val res = UserContactDetailInput(user.getString(VALUE_CALL_KEY_ALIAS))
            res.nickName = user.optString(VALUE_CALL_KEY_NICKNAME)
            res.firstName = user.optString(VALUE_CALL_KEY_FIRSTNAME)
            res.lastName = user.optString(VALUE_CALL_KEY_LASTNAME)
            res.email = user.optString(VALUE_CALL_KEY_EMAIL)
            res.profileImageUrl = user.optString(VALUE_CALL_KEY_PROFILE_IMAGE_URL)
            return res
        }
    }
}