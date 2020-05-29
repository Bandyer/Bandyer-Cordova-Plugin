package com.bandyer.cordova.plugin.repository

import androidx.room.*

@Dao
interface UserDao {
    @get:Query("SELECT * FROM user")
    val all: List<User?>?

    @Query("SELECT * FROM user WHERE userAlias IN (:userAliases)")
    fun loadAllByUserAliases(userAliases: Array<String?>?): List<User?>?

    @Query("SELECT * FROM user WHERE userAlias = (:userAlias)")
    fun getUserByAlias(userAlias: String?): User?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(vararg users: User?)

    @Delete
    fun delete(user: User?)
}