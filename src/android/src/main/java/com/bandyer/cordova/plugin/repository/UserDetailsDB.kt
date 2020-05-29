package com.bandyer.cordova.plugin.repository

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase


/**
 *
 * @author kristiyan
 */
@Database(entities = [User::class], version = 1, exportSchema = false)
abstract class UserDetailsDB : RoomDatabase() {

    companion object {

        private var instance: UserDetailsDB? = null

        fun getInstance(context: Context): UserDetailsDB? {
            if (instance == null) {
                synchronized(UserDetailsDB::class) {
                    instance = Room.databaseBuilder(context.applicationContext,
                            UserDetailsDB::class.java, "bandyer_user_details.db")
                            .fallbackToDestructiveMigration()
                            .build()
                }
            }
            return instance!!
        }
    }

    abstract fun userDao(): UserDao?
}



