package com.example.androidexample

import android.content.Context
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.lifecycleScope
import com.example.androidexample.ui.theme.AndroidExampleTheme
import kotlinx.coroutines.launch
import com.veryoauthsdk.VeryOauthSDK
import com.veryoauthsdk.OAuthConfig
import com.veryoauthsdk.AuthenticationMode
import com.veryoauthsdk.OAuthResult

// Provider information data class
data class ProviderInfo(
    val name: String,
    val title: String,
    val description: String,
    val icon: String
)

class MainActivity : ComponentActivity() {
    
    private val providers = listOf(
        ProviderInfo(
            name = "CustomTabs",
            title = "Custom Tabs",
            description = "Uses Chrome Custom Tabs for secure OAuth",
            icon = "browser"
        ),
        ProviderInfo(
            name = "WebView",
            title = "WebView",
            description = "Uses WebView with camera support",
            icon = "web"
        )
    )
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AndroidExampleTheme {
                OAuthDemoScreen(providers = providers, context = this)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OAuthDemoScreen(
    providers: List<ProviderInfo>,
    context: Context
) {
    var selectedProvider by remember { mutableStateOf("CustomTabs") }
    var authResult by remember { mutableStateOf("Authentication result will appear here") }
    var resultColor by remember { mutableStateOf(Color.Gray) }
    var isLoading by remember { mutableStateOf(false) }
    
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        item {
            // Title Section
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Security,
                    contentDescription = "Security",
                    modifier = Modifier.size(64.dp),
                    tint = MaterialTheme.colorScheme.primary
                )
                
                Text(
                    text = "VeryOauthSDK OAuth Demo",
                    style = MaterialTheme.typography.headlineLarge,
                    fontWeight = FontWeight.Bold
                )
                
                Text(
                    text = "Choose authentication method and start OAuth authentication",
                    style = MaterialTheme.typography.bodyLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center
                )
            }
        }
        
        item {
            // Provider Selection
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "Select Authentication Method:",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    
                    providers.forEach { provider ->
                        ProviderCard(
                            provider = provider,
                            isSelected = selectedProvider == provider.name,
                            onSelect = { selectedProvider = provider.name }
                        )
                    }
                }
            }
        }
        
        item {
            // Authentication Button
            Button(
                onClick = {
                    isLoading = true
                    authResult = "Starting authentication with $selectedProvider..."
                    resultColor = Color.Blue
                    
                    // Real VeryOauthSDK authentication - matching iOS example config
                    val config = OAuthConfig(
                        clientId = "veros_145b3a8f2a8f4dc59394cbbd0dd2a77f",
                        redirectUri = "https://veros-web-oauth-demo.vercel.app/callback",
                        authorizationUrl = "https://connect.very.org/oauth/authorize",
                        scope = "openid",
                        authenticationMode = if (selectedProvider == "CustomTabs") 
                            AuthenticationMode.SYSTEM_BROWSER 
                        else 
                            AuthenticationMode.WEBVIEW,
                        userId = "vu-1ed0a927-a336-45dd-9c73-20092db9ae8d"
                    )
                    
                    VeryOauthSDK.getInstance().authenticate(
                        context = context,
                        config = config,
                        callback = { result ->
                            when (result) {
                                is OAuthResult.Success -> {
                                    authResult = "✅ Authentication successful!\n\nToken: ${result.token}\nState: ${result.state ?: "N/A"}"
                                    resultColor = Color.Green
                                }
                                is OAuthResult.Failure -> {
                                    val errorMessage = result.error.message ?: "Unknown error occurred"
                                    authResult = "❌ Authentication failed: $errorMessage"
                                    resultColor = Color.Red
                                }
                                is OAuthResult.Cancelled -> {
                                    authResult = "⚠️ Authentication cancelled by user"
                                    resultColor = Color(0xFFFF9800) // Orange color
                                }
                            }
                            isLoading = false
                        }
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                enabled = !isLoading,
                shape = RoundedCornerShape(12.dp)
            ) {
                if (isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(20.dp),
                        color = MaterialTheme.colorScheme.onPrimary
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Authenticating...")
                } else {
                    Icon(
                        imageVector = Icons.Default.Login,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Start OAuth Authentication")
                }
            }
        }
        
        item {
            // Result Display
            Card(
                modifier = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = "Authentication Result:",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                    
                    Text(
                        text = authResult,
                        style = MaterialTheme.typography.bodyMedium,
                        color = resultColor,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }
        }
    }
}

@Composable
fun ProviderCard(
    provider: ProviderInfo,
    isSelected: Boolean,
    onSelect: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .selectable(
                selected = isSelected,
                onClick = onSelect
            ),
        colors = CardDefaults.cardColors(
            containerColor = if (isSelected) MaterialTheme.colorScheme.primary 
                           else MaterialTheme.colorScheme.surfaceVariant
        ),
        elevation = CardDefaults.cardElevation(
            defaultElevation = if (isSelected) 8.dp else 2.dp
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Icon
            Icon(
                imageVector = when (provider.icon) {
                    "browser" -> Icons.Default.Public
                    "web" -> Icons.Default.Web
                    else -> Icons.Default.Info
                },
                contentDescription = provider.icon,
                modifier = Modifier.size(24.dp),
                tint = if (isSelected) MaterialTheme.colorScheme.onPrimary 
                      else MaterialTheme.colorScheme.primary
            )
            
            // Content
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = provider.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = if (isSelected) MaterialTheme.colorScheme.onPrimary 
                           else MaterialTheme.colorScheme.onSurface
                )
                
                Text(
                    text = provider.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (isSelected) MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f)
                           else MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            // Selection indicator
            Icon(
                imageVector = if (isSelected) Icons.Default.RadioButtonChecked 
                             else Icons.Default.RadioButtonUnchecked,
                contentDescription = if (isSelected) "Selected" else "Not selected",
                modifier = Modifier.size(20.dp),
                tint = if (isSelected) MaterialTheme.colorScheme.onPrimary 
                      else MaterialTheme.colorScheme.outline
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
fun OAuthDemoScreenPreview() {
    AndroidExampleTheme {
        // Note: Preview doesn't support real context, so we'll create a mock version
        // In real usage, context will be provided by MainActivity
        OAuthDemoScreen(
            providers = listOf(
                ProviderInfo(
                    name = "CustomTabs",
                    title = "Custom Tabs",
                    description = "Uses Chrome Custom Tabs for secure OAuth",
                    icon = "browser"
                ),
                ProviderInfo(
                    name = "WebView",
                    title = "WebView",
                    description = "Uses WebView with camera support",
                    icon = "web"
                )
            ),
            context = androidx.compose.ui.platform.LocalContext.current
        )
    }
}