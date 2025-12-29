package com.firstloveassembly.breadandwine.data.api

import com.firstloveassembly.breadandwine.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

/**
 * API Service singleton for WordPress REST API
 * Mirrors iOS APIService class
 */
object ApiService {

    private const val BASE_URL = "https://breadandwinedevotional.com/wp-json/wp/v2/"

    /**
     * OkHttp client with conditional logging (DEBUG-only)
     */
    private val okHttpClient = OkHttpClient.Builder()
        .apply {
            if (BuildConfig.DEBUG) {
                addInterceptor(
                    HttpLoggingInterceptor().apply {
                        level = HttpLoggingInterceptor.Level.BASIC
                    }
                )
            }
        }
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    /**
     * Retrofit instance
     */
    private val retrofit: Retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    /**
     * WordPress API interface
     */
    val api: WordPressApi = retrofit.create(WordPressApi::class.java)

    /**
     * Sealed class for API results
     */
    sealed class ApiResult<out T> {
        data class Success<T>(val data: T) : ApiResult<T>()
        data class Error(val message: String, val exception: Exception? = null) : ApiResult<Nothing>()
        object Loading : ApiResult<Nothing>()
    }
}
