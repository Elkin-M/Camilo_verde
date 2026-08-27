# Integracion Firebase y Google Drive

## Flujo

```text
Administrador
    -> Firebase Auth
    -> Apps Script
    -> Google Drive
    -> URL guardada en Firestore
```

La app usa correo y contrasena con Firebase Auth. El documento `admins/{uid}` debe tener `active: true` y `role: admin` o `superadmin`.

## Apps Script

1. Crea un proyecto en script.google.com.
2. Copia `apps-script/Code.gs` y `apps-script/appsscript.json`.
3. Verifica el ID de la carpeta principal y la API key de Firebase.
4. Implementa como aplicacion web, ejecutando como propietario y con acceso para cualquier usuario.
5. Copia la URL `/exec` y pasala con `--dart-define=DRIVE_UPLOAD_ENDPOINT=...` si cambia.
6. Cada vez que cambies `Code.gs`, crea una nueva version de la implementacion.

Apps Script crea automaticamente las carpetas `evidencias` y `modelos-3d`. La accion `trash` envia los archivos a la papelera antes de borrar el registro en Firestore.

## Firebase

Activa Authentication con Email/Password, crea Firestore y publica manualmente `firestore.rules`. Crea el primer usuario en Authentication y luego un documento `admins/{UID}` con:

```text
active: true
role: superadmin
email: correo-del-usuario
```

El cliente no contiene credenciales privadas de Google Drive. Firebase Storage no es necesario para este flujo.
