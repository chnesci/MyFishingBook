# fishlog

A new Flutter project.

## Getting Started

README.md (Versión para desarrollador)
FishLog
Slogan: "Tu diario de pesca, siempre a mano."

Descripción
FishLog es una aplicación móvil desarrollada con Flutter que permite a los pescadores aficionados llevar un registro detallado de sus jornadas de pesca. La aplicación permite guardar datos cruciales como la ubicación exacta (utilizando Google Maps), el clima, el señuelo utilizado, y adjuntar fotos de la captura. Todos los datos se almacenan localmente en una base de datos Hive, garantizando un funcionamiento fluido incluso sin conexión.

Características
Autenticación de Usuario: Registro con usuario y contraseña, y opción de recuperación.

Gestión de Registros: Creación, visualización, edición y eliminación de registros de pesca.

Geolocalización: Guardado de la ubicación exacta usando las coordenadas GPS del dispositivo.

Integración con Google Maps: Apertura de la ubicación del registro directamente en Google Maps.

Registro Fotográfico: Posibilidad de adjuntar fotos de la captura y del señuelo.

Base de Datos Local: Almacenamiento eficiente y seguro de datos con Hive.

Diseño Intuitivo: Interfaz dinámica y fácil de usar, con validaciones no estrictas.

Manejo de Errores: Errores de validación y de sistema visibles en pantalla para una mejor experiencia de usuario.

Tecnologías Utilizadas
Framework: Flutter 3.29.3

Lenguaje: Dart

Base de Datos Local: Hive

Paquetes Clave:

flutter_hive: Integración de Hive con Flutter.

geolocator: Para obtener la ubicación GPS del dispositivo.

image_picker: Para seleccionar imágenes de la galería o tomar fotos con la cámara.

url_launcher: Para abrir enlaces externos (Google Maps).

Requisitos del Sistema
Para compilar y ejecutar este proyecto, necesitas tener instalado:

Flutter SDK: Versión 3.29.3 o superior.

Android Studio o Visual Studio Code: Con las extensiones de Flutter y Dart.

Dispositivo/Emulador: Un dispositivo Android o iOS conectado, o un emulador virtual.

Dispositivo de referencia: Xiaomi Redmi Note 13, Android 15 (API 35), con depuración por WiFi (ADB).

SDKs Android:

Android SDK Build Tools 34.

NDK 26.3.11579264.

CMake 3.22.1.

Sistema Operativo: Windows 10 Pro 64 bits (22H2, build 19045.5796).

Instrucciones de Instalación
Sigue estos pasos para poner el proyecto en marcha:

Clonar el Repositorio:

Bash

git clone [URL_DEL_REPOSITORIO]
cd FishLog
(Nota: Reemplaza [URL_DEL_REPOSITORIO] con la URL real de tu repositorio de Git.)

Instalar Dependencias:

Bash

flutter pub get
Habilitar Permisos:

Asegúrate de haber configurado los permisos de ubicación (ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION) y cámara en los archivos AndroidManifest.xml (Android) e Info.plist (iOS) según sea necesario.

Ejecutar la App:

Conecta tu dispositivo o inicia un emulador.

Ejecuta el comando para compilar y lanzar la aplicación.

Bash

flutter run