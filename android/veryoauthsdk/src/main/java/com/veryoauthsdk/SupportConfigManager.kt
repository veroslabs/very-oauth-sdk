package com.veryoauthsdk

import android.content.Context
import android.content.SharedPreferences

/**
 * Support configuration data class for Android
 * Only contains Android-specific requirements
 */
data class SupportConfig(
    val androidApiLevel: Int = 29, // Android 10 (API level 29)
    val androidMemory: Int = 6144 // Minimum memory requirement in MB (6144 MB = 6GB)
)

/**
 * Manager for support configuration
 * Stores and retrieves support requirements from SharedPreferences
 */
internal object SupportConfigManager {
    private const val PREFS_NAME = "veryoauthsdk_support_config"
    private const val KEY_ANDROID_API_LEVEL = "android_api_level"
    private const val KEY_ANDROID_MEMORY = "android_memory"
    
    // Default configuration
    private val defaultConfig = SupportConfig(
        androidApiLevel = 29, // Android 10
        androidMemory = 6144 // 6144 MB = 6GB
    )
    
    /**
     * Get support configuration from SharedPreferences
     * @param context Application context
     * @return SupportConfig object
     */
    fun getConfig(context: Context): SupportConfig {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return SupportConfig(
            androidApiLevel = prefs.getInt(KEY_ANDROID_API_LEVEL, defaultConfig.androidApiLevel),
            androidMemory = prefs.getInt(KEY_ANDROID_MEMORY, defaultConfig.androidMemory)
        )
    }
    
    /**
     * Update support configuration
     * @param context Application context
     * @param config SupportConfig object to save
     */
    fun updateConfig(context: Context, config: SupportConfig) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putInt(KEY_ANDROID_API_LEVEL, config.androidApiLevel)
            putInt(KEY_ANDROID_MEMORY, config.androidMemory)
            apply()
        }
    }
    
    /**
     * Update support configuration from map (useful for API responses)
     * @param context Application context
     * @param configMap Map containing configuration values
     * Expected keys: "androidApiLevel" (Int), "androidMemory" (Int)
     */
    fun updateConfigFromMap(context: Context, configMap: Map<String, Any>) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        
        configMap["androidApiLevel"]?.let {
            when (it) {
                is Int -> editor.putInt(KEY_ANDROID_API_LEVEL, it)
                is String -> editor.putInt(KEY_ANDROID_API_LEVEL, it.toIntOrNull() ?: defaultConfig.androidApiLevel)
                else -> {}
            }
        }
        // Also support legacy "androidVersion" key for backward compatibility
        configMap["androidVersion"]?.let {
            when (it) {
                is Int -> editor.putInt(KEY_ANDROID_API_LEVEL, it)
                is String -> editor.putInt(KEY_ANDROID_API_LEVEL, it.toIntOrNull() ?: defaultConfig.androidApiLevel)
                else -> {}
            }
        }
        configMap["androidMemory"]?.let {
            when (it) {
                is Int -> editor.putInt(KEY_ANDROID_MEMORY, it)
                is String -> editor.putInt(KEY_ANDROID_MEMORY, it.toIntOrNull() ?: defaultConfig.androidMemory)
                else -> {}
            }
        }
        
        editor.apply()
    }
}

