package breadandwineandroid.breadandwineandroid.service

import android.content.Context
import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.messaging.FirebaseMessaging

/**
 * Device Token Manager
 * Manages FCM token storage in Firebase Firestore
 * Mirrors iOS DeviceManager
 */
object DeviceTokenManager {

    private const val TAG = "DeviceTokenManager"
    private const val COLLECTION_DEVICES = "devices"

    /**
     * Initialize and retrieve FCM token
     */
    fun initializeToken(context: Context) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
            if (task.isSuccessful) {
                val token = task.result
                saveDeviceToken(context, token)
            } else {
                Log.e(TAG, "Failed to get FCM token")
            }
        }
    }

    /**
     * Save device token to Firestore
     * Mirrors iOS saveDeviceToken() in DeviceManager
     */
    fun saveDeviceToken(context: Context, token: String) {
        val db = FirebaseFirestore.getInstance()

        val deviceData = hashMapOf(
            "token" to token,
            "platform" to "android",
            "appVersion" to "1.0.0",
            "lastActive" to com.google.firebase.Timestamp.now()
        )

        db.collection(COLLECTION_DEVICES)
            .document(token)
            .set(deviceData)
            .addOnFailureListener {
                Log.e(TAG, "Failed to save device token")
            }
    }

    /**
     * Delete device token from Firestore (for logout/uninstall)
     */
    fun deleteDeviceToken(token: String) {
        val db = FirebaseFirestore.getInstance()

        db.collection(COLLECTION_DEVICES)
            .document(token)
            .delete()
            .addOnFailureListener {
                Log.e(TAG, "Failed to delete device token")
            }
    }
}
