package com.verysdk.example

import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.veryoauthsdk.VeryOauthSDK
import com.veryoauthsdk.OAuthConfig
import com.veryoauthsdk.OAuthResult
import com.veryoauthsdk.AuthenticationMode
import com.verysdk.example.databinding.ActivityMainBinding
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private val veryOauthSDK = VeryOauthSDK.getInstance()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
    }
    
    private fun setupUI() {
        binding.apply {
            titleText.text = "VeryOauthSDK OAuth Demo"
            descriptionText.text = "Choose authentication method:"
            
            // Custom Tabs authentication
            authButton.setOnClickListener {
                startAuthentication(AuthenticationMode.CUSTOM_TABS)
            }
            
            // WebView authentication (if you have a second button)
            // You might need to add another button in your layout
        }
    }
    
    private fun startAuthentication(authMode: AuthenticationMode) {
        // Example OAuth configuration
        val config = OAuthConfig(
            clientId = "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
            redirectUri = "verysdk://oauth/callback",
            authorizationUrl = "https://connect.very.org/oauth/authorize",
            scope = "openid",
            authenticationMode = authMode
        )
        
        veryOauthSDK.authenticate(this, config) { result ->
            lifecycleScope.launch {
                handleAuthenticationResult(result)
            }
        }
    }
    
    private fun handleAuthenticationResult(result: OAuthResult) {
        runOnUiThread {
            when (result) {
                is OAuthResult.Success -> {
                    binding.resultText.text = "✅ Authentication successful!\nToken: ${result.token}\nState: ${result.state ?: "N/A"}"
                    binding.resultText.setTextColor(getColor(android.R.color.holo_green_dark))
                    Toast.makeText(this, "Authentication successful!", Toast.LENGTH_SHORT).show()
                }
                is OAuthResult.Failure -> {
                    binding.resultText.text = "❌ Authentication failed: ${result.error.message}"
                    binding.resultText.setTextColor(getColor(android.R.color.holo_red_dark))
                    Toast.makeText(this, "Authentication failed: ${result.error.message}", Toast.LENGTH_LONG).show()
                }
                is OAuthResult.Cancelled -> {
                    binding.resultText.text = "⚠️ Authentication cancelled by user"
                    binding.resultText.setTextColor(getColor(android.R.color.holo_orange_dark))
                    Toast.makeText(this, "Authentication cancelled", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }
}
