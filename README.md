# SISSTeApp

App móvil (Flutter) del Sistema Interno para la Solicitud de Soporte
Técnico (SISSTe / SIGESOT). Se conecta al backend Node.js del repositorio
`sisste-web`, **sin crear endpoints nuevos**: consume los que ya usa la
versión web.

## Conexión con el backend

| Dato | Valor |
|---|---|
| Servidor | contenedor `172.17.102.191` (red interna) |
| Puerto | `3000` (Node escucha directamente, sin proxy) |
| URL base | `http://172.17.102.191:3000` (`lib/core/api_config.dart`) |
| Autenticación | sesión por cookie (`connect.sid`, 8 h), **no JWT** |

Piezas principales:

- `lib/core/api_config.dart` — URL base, endpoints y timeouts. Es el único
  archivo de Dart a tocar si cambia la IP o el puerto.
- `android/app/src/main/res/xml/network_security_config.xml` — Android
  bloquea HTTP sin cifrar por defecto; este archivo permite HTTP **solo**
  hacia `172.17.102.191`. Si cambias la IP, cámbiala también aquí.
- `lib/core/api_client.dart` — un único `Dio` con cookie jar persistente.
  Guarda la cookie del login y la reenvía en cada petición; si el servidor
  responde 401 (sesión vencida), limpia la sesión y manda al login.
- `lib/services/` — `auth_service` (login, logout, validar sesión),
  `categorias_service` y `solicitudes_service` (crear, listar las propias,
  historial).
- `lib/models/` — modelos que reflejan las respuestas del backend.

Al abrir la app se valida con `GET /api/session` que la sesión guardada siga
viva; el cierre de sesión llama a `POST /api/logout` para que quede
registrado en la auditoría del servidor.

## Cómo correrla

```bash
flutter pub get
flutter analyze
flutter run
```

Prueba en un teléfono físico conectado a la misma red interna que el
contenedor. Si el teléfono no llega al servidor, verifica desde el propio
teléfono (navegador) que `http://172.17.102.191:3000` carga el login web.

## Qué falta

- Pantalla de cambio de contraseña obligatorio en el primer inicio de
  sesión (`PUT /api/cambiar-password`; el login ya devuelve
  `debeCambiarPassword`).
- Pantallas de solicitudes (nueva solicitud, pendientes, historial) sobre
  los servicios ya disponibles.
- Dashboard técnico (aceptar / finalizar solicitudes).
- Notificaciones push.
- HTTPS en el servidor: hoy el tráfico viaja sin cifrar dentro de la red
  interna.
