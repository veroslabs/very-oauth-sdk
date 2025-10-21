package com.veryoauthsdk

/**
 * Language manager for handling localized strings
 */
object LanguageManager {
    
    private var currentLanguage: String = "en"
    
    /**
     * Set the current language
     */
    fun setLanguage(language: String) {
        currentLanguage = language
    }
    
    /**
     * Get the current language
     */
    fun getCurrentLanguage(): String = currentLanguage
    
    /**
     * Get localized string for camera permission title
     */
    fun getCameraPermissionTitle(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "需要相机权限"
            "ja" -> "カメラの許可が必要です"
            "ko" -> "카메라 권한이 필요합니다"
            "es" -> "Se requiere permiso de cámara"
            "fr" -> "Permission de caméra requise"
            "de" -> "Kamera-Berechtigung erforderlich"
            "it" -> "Richiesta autorizzazione fotocamera"
            "pt" -> "Permissão de câmera necessária"
            "ru" -> "Требуется разрешение на камеру"
            else -> "Camera Permission Required"
        }
    }
    
    /**
     * Get localized string for camera permission message
     */
    fun getCameraPermissionMessage(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "此应用需要相机权限来扫描二维码。请在设置中允许相机权限。"
            "ja" -> "QRコードをスキャンするためにカメラの許可が必要です。設定でカメラの許可を有効にしてください。"
            "ko" -> "QR 코드를 스캔하기 위해 카메라 권한이 필요합니다. 설정에서 카메라 권한을 허용해주세요."
            "es" -> "Esta aplicación necesita permiso de cámara para escanear códigos QR. Por favor, permite el permiso de cámara en la configuración."
            "fr" -> "Cette application a besoin de l'autorisation de la caméra pour scanner les codes QR. Veuillez autoriser l'accès à la caméra dans les paramètres."
            "de" -> "Diese App benötigt die Kamera-Berechtigung zum Scannen von QR-Codes. Bitte erlauben Sie den Kamera-Zugriff in den Einstellungen."
            "it" -> "Questa app ha bisogno dell'autorizzazione della fotocamera per scansionare i codici QR. Si prega di consentire l'accesso alla fotocamera nelle impostazioni."
            "pt" -> "Este aplicativo precisa de permissão de câmera para escanear códigos QR. Por favor, permita o acesso à câmera nas configurações."
            "ru" -> "Это приложение требует разрешение на камеру для сканирования QR-кодов. Пожалуйста, разрешите доступ к камере в настройках."
            else -> "This app needs camera permission to scan QR codes. Please allow camera access in settings."
        }
    }
    
    /**
     * Get localized string for grant permission button
     */
    fun getGrantPermissionButton(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "授予权限"
            "ja" -> "許可を付与"
            "ko" -> "권한 부여"
            "es" -> "Conceder permiso"
            "fr" -> "Accorder l'autorisation"
            "de" -> "Berechtigung erteilen"
            "it" -> "Concedi autorizzazione"
            "pt" -> "Conceder permissão"
            "ru" -> "Предоставить разрешение"
            else -> "Grant Permission"
        }
    }
    
    /**
     * Get localized string for continue without button
     */
    fun getContinueWithoutButton(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "继续（无相机）"
            "ja" -> "続行（カメラなし）"
            "ko" -> "계속하기（카메라 없이）"
            "es" -> "Continuar sin cámara"
            "fr" -> "Continuer sans caméra"
            "de" -> "Ohne Kamera fortfahren"
            "it" -> "Continua senza fotocamera"
            "pt" -> "Continuar sem câmera"
            "ru" -> "Продолжить без камеры"
            else -> "Continue Without Camera"
        }
    }
    
    /**
     * Get localized string for camera permission denied title
     */
    fun getCameraPermissionDeniedTitle(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "相机权限被拒绝"
            "ja" -> "カメラの許可が拒否されました"
            "ko" -> "카메라 권한이 거부되었습니다"
            "es" -> "Permiso de cámara denegado"
            "fr" -> "Autorisation de caméra refusée"
            "de" -> "Kamera-Berechtigung verweigert"
            "it" -> "Autorizzazione fotocamera negata"
            "pt" -> "Permissão de câmera negada"
            "ru" -> "Разрешение на камеру отклонено"
            else -> "Camera Permission Denied"
        }
    }
    
    /**
     * Get localized string for camera permission denied message
     */
    fun getCameraPermissionDeniedMessage(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "相机权限被拒绝，但您仍然可以继续使用应用。某些功能（如二维码扫描）可能无法使用。"
            "ja" -> "カメラの許可が拒否されましたが、アプリの使用を続けることができます。QRコードスキャンなどの一部の機能は使用できない場合があります。"
            "ko" -> "카메라 권한이 거부되었지만 앱 사용을 계속할 수 있습니다. QR 코드 스캔과 같은 일부 기능은 사용할 수 없을 수 있습니다."
            "es" -> "El permiso de cámara fue denegado, pero aún puedes continuar usando la aplicación. Algunas funciones como el escaneo de códigos QR pueden no estar disponibles."
            "fr" -> "L'autorisation de la caméra a été refusée, mais vous pouvez toujours continuer à utiliser l'application. Certaines fonctionnalités comme le scan de codes QR peuvent ne pas être disponibles."
            "de" -> "Die Kamera-Berechtigung wurde verweigert, aber Sie können die App weiterhin verwenden. Einige Funktionen wie das Scannen von QR-Codes sind möglicherweise nicht verfügbar."
            "it" -> "L'autorizzazione della fotocamera è stata negata, ma puoi comunque continuare a utilizzare l'app. Alcune funzionalità come la scansione di codici QR potrebbero non essere disponibili."
            "pt" -> "A permissão da câmera foi negada, mas você ainda pode continuar usando o aplicativo. Algumas funcionalidades como a varredura de códigos QR podem não estar disponíveis."
            "ru" -> "Разрешение на камеру было отклонено, но вы все еще можете продолжать использовать приложение. Некоторые функции, такие как сканирование QR-кодов, могут быть недоступны."
            else -> "Camera permission was denied, but you can still continue using the app. Some features like QR code scanning may not be available."
        }
    }
    
    /**
     * Get localized string for OK button
     */
    fun getOkButton(): String {
        return when (currentLanguage) {
            "zh", "zh-CN" -> "确定"
            "ja" -> "OK"
            "ko" -> "확인"
            "es" -> "Aceptar"
            "fr" -> "OK"
            "de" -> "OK"
            "it" -> "OK"
            "pt" -> "OK"
            "ru" -> "ОК"
            else -> "OK"
        }
    }
}