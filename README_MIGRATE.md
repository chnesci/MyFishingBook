Migración de contraseñas a passwordHash

Este script ayuda a migrar usuarios que tienen la contraseña almacenada en texto plano en Hive
(`users` box) a un hash bcrypt, guardándolo en `passwordHash` y borrando el campo `password`.

Uso (local):
1) Localiza la carpeta donde Hive guarda los archivos (ej: en desarrollo es el directorio de la app, o donde corras el script). Para Android/emulador puede ser complejo; la migración "en primer login" que ya implementamos es preferible para entornos de usuarios.

2) Ejecuta el script desde el root del repo con dart:

dart run tools/migrate_passwords.dart --hive-path "C:\path\to\hive_dir"

Notas:
- El script abrirá la caja `users` y migrará cualquier usuario que tenga `password` no vacío y no tenga `passwordHash`.
- Para la mayoría de escenarios de producción basta con la migración que ocurre automáticamente en el primer login (ya implementada). Usa este script si tienes acceso a los archivos Hive y quieres migrar en bloque.
