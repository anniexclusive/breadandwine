# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Keep data models for Gson serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keep class breadandwineandroid.breadandwineandroid.model.** { *; }

# Gson specific rules
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Retrofit
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Keep Retrofit interfaces
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Keep API interface methods
-keep interface breadandwineandroid.breadandwineandroid.data.api.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.api.** { *; }

# Keep all Retrofit method annotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Compose
-keep class androidx.compose.** { *; }
-keepclassmembers class androidx.compose.** { *; }

# Keep ViewModels and Repository classes
-keep class breadandwineandroid.breadandwineandroid.viewmodel.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.repository.** { *; }
-keep class breadandwineandroid.breadandwineandroid.data.cache.** { *; }
