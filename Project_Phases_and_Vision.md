Fases del Proyecto FishLog
Fase 1: Diseño y Planificación
•	Objetivo: Definir la estructura, funcionalidades y tecnologías del proyecto.
•	Detalles:
o	Nombre, eslogan y logo.
o	Plataforma (Flutter 3.29.3) y editor (Visual Studio Code).
o	Entorno de desarrollo y dispositivos.
o	Funcionalidades deseadas, como registro de usuario, guardar ubicación, adjuntar fotos y registrar datos de pesca.
o	Decisión de usar Hive como base de datos.
Fase 2: Configuración del Entorno y Modelo de Datos
•	Objetivo: Configurar el proyecto base, instalar dependencias y crear la primera versión del modelo de datos.
•	Detalles:
o	Creación inicial de la aplicación.
o	Instalación de paquetes esenciales como hive, hive_flutter, geolocator, image_picker, y url_launcher.
o	Creación del modelo de datos FishingLog.
o	Se han añadido y modificado campos para registrar especies, peso, longitud, señuelo, temperatura y clima.
Fase 3: Desarrollo de la Interfaz de Usuario (UI)
•	Objetivo: Construir las pantallas de la aplicación y la lógica de interacción.
Fase 4: Desarrollo de Funcionalidades Adicionales
•	Objetivo: Implementar el resto de las características del proyecto.
•	Detalles:
o	Implementación de Google Maps.
o	Integración de API de clima y alertas.
o	Pantallas de consulta de registros.
o	Creación de la lógica de usuario y contraseña.
FishLog: "Tu diario de pesca, siempre a mano."
Propósito y Visión
FishLog está diseñada para ser la herramienta definitiva para cualquier pescador. Su objetivo es reemplazar los viejos cuadernos de papel, permitiendo registrar digitalmente cada jornada de pesca con todo tipo de detalles. Desde la ubicación exacta de la captura hasta el señuelo utilizado, la aplicación busca ayudar a los pescadores a analizar patrones, mejorar sus técnicas y, en última instancia, aumentar sus posibilidades de éxito.
Funcionalidades Principales
•	Registro de Usuario: Permite a cada pescador tener su propio perfil y un registro personal de sus capturas, asegurando que los datos de pesca sean privados y accesibles solo para el usuario.
•	Geolocalización con Google Maps: Utiliza la ubicación precisa del dispositivo para guardar las coordenadas exactas de cada lugar de pesca, permitiendo al usuario volver a ese mismo punto en el futuro o analizar los puntos "calientes" en un mapa.
•	Registro Detallado de Capturas:
o	Foto del Pez: Adjunta una foto del pez capturado para tener un registro visual.
o	Foto del Señuelo: Guarda una imagen del señuelo utilizado, lo que es crucial para replicar el éxito.
o	Datos de la Captura: Registra la especie, el peso y la longitud del pez.
•	Datos del Entorno:
o	Fecha y Hora: Guarda el momento exacto de la pesca.
o	Clima y Temperatura: Registra las condiciones meteorológicas y la temperatura del lugar en el momento del evento.
•	Validaciones Flexibles: La aplicación no es estricta. Permite guardar registros de lugares de pesca incluso si no hubo capturas, lo que es útil para documentar las jornadas de exploración y las condiciones del día.
•	Diseño y Usabilidad:
o	Interfaz Intuitiva: El diseño es dinámico y fácil de usar, eliminando la curva de aprendizaje para que cualquier pescador pueda empezar a registrar sus datos de inmediato.
o	Errores Visibles: Cualquier error en el formulario o en la lógica de la aplicación se muestra claramente en la pantalla, facilitando la corrección de datos por parte del usuario.
Tecnología de Desarrollo
•	Plataforma: Flutter 3.29.3, lo que garantiza que la aplicación pueda funcionar tanto en dispositivos Android como iOS.
•	Base de Datos: Hive, una base de datos ligera y rápida que se ejecuta localmente en el dispositivo, ideal para manejar los registros de pesca sin necesidad de una conexión a internet constante.
En resumen, FishLog es tu asistente personal de pesca. Está diseñada para ser un diario inteligente que aprende contigo, ayudándote a convertir cada salida en una lección valiosa para futuras aventuras.
FishLog está diseñada para convertir esos datos en información útil, mostrando estadísticas claras para ayudarte a pescar de forma más inteligente.
Estadísticas de Captura
•	Total de Capturas: El número total de peces que has registrado. Simple, pero satisfactorio.
•	Especie Más Común: Un gráfico que muestra qué especies capturas con mayor frecuencia. Así sabrás si eres un especialista en truchas o un "coleccionista" de bagres.
•	Récords Personales: Se destacarán el pez más grande y pesado que has capturado hasta la fecha, con el objetivo de motivarte a superar tu propia marca.
Estadísticas de Rendimiento por Variables
•	Mejores Ubicaciones: Un mapa con puntos marcados para mostrar dónde has tenido más éxito. Te servirá para recordar esos "secret spots" y analizar si hay patrones geográficos.
•	Señuelo Más Efectivo: Un ranking de los señuelos (por tipo y color) que te han dado más capturas. La aplicación te dirá qué cebo funciona y cuál solo está ocupando espacio en tu caja.
•	Condiciones Ideales: La aplicación analizará la temperatura y las condiciones del clima en el momento de tus capturas exitosas, ayudándote a identificar el clima perfecto para salir a pescar.
Análisis Temporal y de Tendencias
•	Historial de Capturas: Gráficos que muestran tu actividad de pesca a lo largo del tiempo, por día, mes o año. Te permitirá ver si eres más productivo en verano o si las capturas de invierno valen la pena.
•	Distribución de Tallas y Pesos: Un análisis de la distribución de las longitudes y los pesos de tus capturas, lo que puede ayudarte a entender el tamaño promedio de los peces en tus zonas de pesca favoritas.
Todas estas estadísticas se actualizarán automáticamente a medida que vayas añadiendo nuevos registros, convirtiendo a FishLog en un verdadero diario de pesca inteligente.
RESUMEN:
Fase 1: Mejoras de la funcionalidad actual
Esta fase se centra en corregir errores y agregar pequeñas mejoras a las pantallas que ya existen. Son cambios rápidos que no dependen de otras funcionalidades más grandes.

Fase 2: Implementación de funcionalidades clave
Esta fase se enfoca en agregar las funcionalidades más importantes de su aplicación. Empezar por aquí es crucial para tener una aplicación funcional antes de dedicarnos a mejoras visuales o secundarias.
Gestión de usuarios:
Registro / inicio de sesión con usuario y contraseña (ya lo tenemos en parte).
Cerrar sesión y mantener la sesión iniciada.
Perfil de usuario con nombre, correo electrónico y estadísticas (capturas, salidas).
Visualización de registros:
Ver los detalles de cada salida: fotos, notas, ubicación.
Ver una lista de salidas anteriores.
Cada salida mostrará fecha, lugar, especie capturada y miniatura.
Integración de mapas:
Integrar Google Maps directamente en la aplicación.
Cambie el ícono del mapa por el logo oficial de Google Maps.
Clima y alertas:
Consulta automática del clima en el lugar y hora del registro.
Mostrar alertas si hay mal tiempo.

Fase 3: Diseño, animaciones y extras
Una vez que la funcionalidad principal esté lista y funcionando, podemos concentrarnos en hacer que la aplicación se vea mejor y sea más personalizable.
Diseño e interfaz:
Pantalla de presentación con logo, título y autor (ya está, pero se pueden hacer mejoras).
Estilo visual limpio, intuitivo y fácil de usar.
Animaciones:
Añadir animaciones al ícono de la trucha estilizada y la carga del logo.
Configuraciones:
Activar o desactivar funciones como el clima.
Cambie entre temas claro u oscuro.
Elegir idioma (por defecto: español).

Fase 4: Funcionalidades futuras (opcionales)
Estas tareas se pueden realizar más adelante, una vez que la aplicación esté completamente funcional y lanzada. Son mejoras que agregan valor, pero no son esenciales para la primera versión.
Sincronización y respaldo:
Sincronizar los registros en la nube.
Acceso desde distintos dispositivos.
Exportar registros (PDF, CSV, etc.).
