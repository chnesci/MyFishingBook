Configuración de secretos (API keys)

Este proyecto usa la API de OpenWeather para obtener condiciones meteorológicas en algunos pantallas.

No guardes claves en el repositorio. En su lugar, pasa la clave en tiempo de compilación con --dart-define.

Cómo ejecutar / compilar con la clave:

# Ejecutar en modo debug
flutter run --dart-define=OPENWEATHER_API_KEY=tu_api_key_aqui

# Crear APK / build
flutter build apk --release --dart-define=OPENWEATHER_API_KEY=tu_api_key_aqui

Notas:
- Si la variable no está definida, la app mostrará un SnackBar indicando que la clave no está configurada y omitirá la petición al servicio.
- Para CI/CD, configura la variable OPENWEATHER_API_KEY como secret y pásala al comando de build en la acción.
