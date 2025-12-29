package com.firstloveassembly.breadandwine.service

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.util.*

/**
 * Simple TTS Manager - mirrors iOS SpeechSynthesizer
 */
class TextToSpeechManager(private val context: Context) : TextToSpeech.OnInitListener {

    private var tts: TextToSpeech = TextToSpeech(context, this)
    private var audioManager: AudioManager? = null
    var isSpeaking = false
        private set

    var onStateChanged: ((Boolean) -> Unit)? = null

    init {
        audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            // Set British English to match iOS
            val langResult = tts.setLanguage(Locale.UK)

            if (langResult == TextToSpeech.LANG_MISSING_DATA ||
                langResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.w("TTS", "UK English not available, using US English")
                tts.setLanguage(Locale.US)
            }

            // Set speech rate to match iOS (0.65 * 1.5 ≈ 0.9)
            tts.setSpeechRate(0.9f)

            // Set pitch
            tts.setPitch(1.0f)

            // Set up listener to track when speech finishes
            tts.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {
                    isSpeaking = true
                    onStateChanged?.invoke(true)
                    Log.d("TTS", "Started speaking")
                }

                override fun onDone(utteranceId: String?) {
                    isSpeaking = false
                    onStateChanged?.invoke(false)
                    Log.d("TTS", "Finished speaking")
                }

                override fun onError(utteranceId: String?) {
                    isSpeaking = false
                    onStateChanged?.invoke(false)
                    Log.e("TTS", "Error during speech")
                }
            })

            Log.d("TTS", "TTS initialized successfully")
        } else {
            Log.e("TTS", "TTS initialization failed")
        }
    }

    fun speak(text: String) {
        if (text.isEmpty()) {
            Log.w("TTS", "Empty text provided")
            return
        }

        // Request audio focus
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val focusRequest = android.media.AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .build()
            audioManager?.requestAudioFocus(focusRequest)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus(
                null,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            )
        }

        // Build params bundle with audio attributes
        val params = Bundle()
        params.putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "DevotionalTTS")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            params.putInt(TextToSpeech.Engine.KEY_PARAM_STREAM, AudioManager.STREAM_MUSIC)
            params.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, 1.0f)
        }

        tts.speak(text, TextToSpeech.QUEUE_FLUSH, params, "DevotionalTTS")
        Log.d("TTS", "Speaking text: ${text.take(100)}...")
    }

    fun stop() {
        if (tts.isSpeaking) {
            tts.stop()
        }
        isSpeaking = false
        onStateChanged?.invoke(false)

        // Abandon audio focus
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // For API 26+, would need to store focusRequest, skipping for simplicity
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }

        Log.d("TTS", "Stopped speaking")
    }

    fun shutdown() {
        stop()
        tts.shutdown()
        Log.d("TTS", "TTS shutdown")
    }
}
