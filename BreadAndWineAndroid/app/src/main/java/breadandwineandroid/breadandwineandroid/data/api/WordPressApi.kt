package breadandwineandroid.breadandwineandroid.data.api

import breadandwineandroid.breadandwineandroid.model.Devotional
import retrofit2.Response
import retrofit2.http.GET

/**
 * WordPress REST API interface
 * Base URL: https://breadandwinedevotional.com/wp-json/wp/v2
 */
interface WordPressApi {

    /**
     * Fetch all devotionals from the custom post type
     * Equivalent to iOS APIService.fetchDevotionals()
     */
    @GET("devotional")
    suspend fun getDevotionals(): Response<List<Devotional>>

    /**
     * Fetch devotionals with pagination
     */
    @GET("devotional?per_page=100")
    suspend fun getDevotionalsWithLimit(): Response<List<Devotional>>
}
