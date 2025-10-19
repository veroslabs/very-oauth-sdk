package com.veryoauthsdk

/**
 * Language configuration for VeryOauthSDK
 */
enum class Language {
    ENGLISH,    // English (default)
    CHINESE,    // Chinese (Simplified)
    JAPANESE,   // Japanese
    KOREAN,     // Korean
    SPANISH,    // Spanish
    FRENCH,     // French
    GERMAN,     // German
    ITALIAN,    // Italian
    PORTUGUESE, // Portuguese
    RUSSIAN     // Russian
}

/**
 * Language manager for handling localized strings
 */
object LanguageManager {
    
    private var currentLanguage: Language = Language.ENGLISH
    
    /**
     * Set the current language
     */
    fun setLanguage(language: Language) {
        currentLanguage = language
    }
    
    /**
     * Get the current language
     */
    fun getCurrentLanguage(): Language = currentLanguage
    
    /**
     * Get localized string for camera permission title
     */
    fun getCameraPermissionTitle(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "需要相机权限"
            Language.JAPANESE -> "カメラの許可が必要です"
            Language.KOREAN -> "카메라 권한이 필요합니다"
            Language.SPANISH -> "Se requiere permiso de cámara"
            Language.FRENCH -> "Permission de caméra requise"
            Language.GERMAN -> "Kamera-Berechtigung erforderlich"
            Language.ITALIAN -> "Richiesta autorizzazione fotocamera"
            Language.PORTUGUESE -> "Permissão de câmera necessária"
            Language.RUSSIAN -> "Требуется разрешение на камеру"
            else -> "Camera Permission Required"
        }
    }
    
    /**
     * Get localized string for camera permission message
     */
    fun getCameraPermissionMessage(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "此应用需要相机权限以支持WebView认证功能。请授予权限以继续。"
            Language.JAPANESE -> "このアプリはWebView認証機能にカメラアクセスが必要です。続行するには許可してください。"
            Language.KOREAN -> "이 앱은 WebView 인증 기능을 위해 카메라 액세스가 필요합니다. 계속하려면 권한을 부여하세요."
            Language.SPANISH -> "Esta aplicación necesita acceso a la cámara para las funciones de autenticación WebView. Por favor, otorgue el permiso para continuar."
            Language.FRENCH -> "Cette application a besoin d'un accès à la caméra pour les fonctionnalités d'authentification WebView. Veuillez accorder l'autorisation pour continuer."
            Language.GERMAN -> "Diese App benötigt Kamera-Zugriff für WebView-Authentifizierungsfunktionen. Bitte erteilen Sie die Berechtigung, um fortzufahren."
            Language.ITALIAN -> "Questa app ha bisogno dell'accesso alla fotocamera per le funzionalità di autenticazione WebView. Si prega di concedere l'autorizzazione per continuare."
            Language.PORTUGUESE -> "Este aplicativo precisa de acesso à câmera para funcionalidades de autenticação WebView. Por favor, conceda a permissão para continuar."
            Language.RUSSIAN -> "Это приложение требует доступа к камере для функций аутентификации WebView. Пожалуйста, предоставьте разрешение для продолжения."
            else -> "This app needs camera access for WebView authentication features. Please grant permission to continue."
        }
    }
    
    /**
     * Get localized string for camera permission denied title
     */
    fun getCameraPermissionDeniedTitle(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "相机权限被拒绝"
            Language.JAPANESE -> "カメラの許可が拒否されました"
            Language.KOREAN -> "카메라 권한이 거부되었습니다"
            Language.SPANISH -> "Permiso de cámara denegado"
            Language.FRENCH -> "Permission de caméra refusée"
            Language.GERMAN -> "Kamera-Berechtigung verweigert"
            Language.ITALIAN -> "Autorizzazione fotocamera negata"
            Language.PORTUGUESE -> "Permissão de câmera negada"
            Language.RUSSIAN -> "Разрешение на камеру отклонено"
            else -> "Camera Permission Denied"
        }
    }
    
    /**
     * Get localized string for camera permission denied message
     */
    fun getCameraPermissionDeniedMessage(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "相机权限被拒绝。某些WebView功能可能无法正常工作，但认证将继续进行。"
            Language.JAPANESE -> "カメラの許可が拒否されました。一部のWebView機能が正常に動作しない可能性がありますが、認証は続行されます。"
            Language.KOREAN -> "카메라 권한이 거부되었습니다. 일부 WebView 기능이 제대로 작동하지 않을 수 있지만 인증은 계속됩니다."
            Language.SPANISH -> "El permiso de cámara fue denegado. Algunas funciones de WebView pueden no funcionar correctamente, pero la autenticación continuará."
            Language.FRENCH -> "La permission de caméra a été refusée. Certaines fonctionnalités WebView peuvent ne pas fonctionner correctement, mais l'authentification continuera."
            Language.GERMAN -> "Die Kamera-Berechtigung wurde verweigert. Einige WebView-Funktionen funktionieren möglicherweise nicht richtig, aber die Authentifizierung wird fortgesetzt."
            Language.ITALIAN -> "L'autorizzazione della fotocamera è stata negata. Alcune funzionalità WebView potrebbero non funzionare correttamente, ma l'autenticazione continuerà."
            Language.PORTUGUESE -> "A permissão da câmera foi negada. Algumas funcionalidades do WebView podem não funcionar corretamente, mas a autenticação continuará."
            Language.RUSSIAN -> "Разрешение на камеру было отклонено. Некоторые функции WebView могут работать неправильно, но аутентификация будет продолжена."
            else -> "Camera permission was denied. Some WebView features may not work properly, but authentication will continue."
        }
    }
    
    /**
     * Get localized string for grant permission button
     */
    fun getGrantPermissionButton(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "授予权限"
            Language.JAPANESE -> "許可を付与"
            Language.KOREAN -> "권한 부여"
            Language.SPANISH -> "Otorgar permiso"
            Language.FRENCH -> "Accorder l'autorisation"
            Language.GERMAN -> "Berechtigung erteilen"
            Language.ITALIAN -> "Concedi autorizzazione"
            Language.PORTUGUESE -> "Conceder permissão"
            Language.RUSSIAN -> "Предоставить разрешение"
            else -> "Grant Permission"
        }
    }
    
    /**
     * Get localized string for continue without button
     */
    fun getContinueWithoutButton(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "继续无权限"
            Language.JAPANESE -> "許可なしで続行"
            Language.KOREAN -> "권한 없이 계속"
            Language.SPANISH -> "Continuar sin permiso"
            Language.FRENCH -> "Continuer sans autorisation"
            Language.GERMAN -> "Ohne Berechtigung fortfahren"
            Language.ITALIAN -> "Continua senza autorizzazione"
            Language.PORTUGUESE -> "Continuar sem permissão"
            Language.RUSSIAN -> "Продолжить без разрешения"
            else -> "Continue Without"
        }
    }
    
    /**
     * Get localized string for OK button
     */
    fun getOkButton(): String {
        return when (currentLanguage) {
            Language.CHINESE -> "确定"
            Language.JAPANESE -> "OK"
            Language.KOREAN -> "확인"
            Language.SPANISH -> "Aceptar"
            Language.FRENCH -> "OK"
            Language.GERMAN -> "OK"
            Language.ITALIAN -> "OK"
            Language.PORTUGUESE -> "OK"
            Language.RUSSIAN -> "ОК"
            else -> "OK"
        }
    }
}
