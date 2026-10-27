# SISSTeApp — Sprint 1: Cimientos y Seguridad

Código correspondiente a las tres tareas del Sprint 1 (Informe Parcial):

- **Tarea 1.1** — Conexión segura hacia el backend (`lib/core/api_config.dart`, timeouts pensados para redes lentas).
- **Tarea 1.2** — Interfaz de la pantalla de Login (`lib/screens/login_screen.dart`).
- **Tarea 1.3** — Consumo del endpoint de autenticación, manejo de credenciales inválidas / errores de red, y almacenamiento seguro del JWT (`lib/services/auth_service.dart`, `lib/core/secure_session.dart`).

## ⚠️ Importante: este entorno no tiene el SDK de Flutter instalado

Este código fue escrito a mano siguiendo la estructura estándar de un
proyecto Flutter, pero **no pudo compilarse ni ejecutarse aquí** porque
el entorno de trabajo no tiene acceso a `flutter`/`dart` ni a
`pub.dev` (el repositorio de paquetes). Antes de programar el
Sprint 2, corre esto en tu máquina para detectar cualquier detalle
que deba ajustarse:

```bash
flutter pub get
flutter analyze
```

## Cómo integrar este código en un proyecto Flutter real

1. En tu máquina (con Flutter instalado), crea el proyecto para que se
   generen las carpetas nativas `android/` e `ios/` (esto no se puede
   generar a mano, lo hace el propio SDK):
   ```bash
   flutter create sisste_app
   ```
2. Reemplaza el `pubspec.yaml` generado por el de este entrega y copia
   la carpeta `lib/` completa dentro del proyecto.
3. Instala las dependencias:
   ```bash
   flutter pub get
   ```
4. Ajusta `lib/core/api_config.dart` según tu entorno de prueba:
   - Emulador Android → usa `10.0.2.2` en lugar de `172.17.102.202`
     (el emulador no ve `localhost`/la LAN directamente).
   - Dispositivo físico dentro de la red de la SUNDDE → deja la IP real.
   - Si el backend aún no tiene HTTPS configurado en el Proxy Inverso,
     cambia `https://` por `http://` temporalmente **solo para pruebas
     locales**, nunca en producción.
5. Habilita CORS en el backend Node.js para aceptar peticiones desde
   la app (esto es responsabilidad del **servidor**, no de Flutter).
   Con Express, por ejemplo:
   ```js
   const cors = require('cors');
   app.use(cors()); // ajustar origin en producción si se requiere
   ```
6. Corre la app:
   ```bash
   flutter run
   ```

## Prueba rápida sin modificar tu backend real

Si quieres probar el flujo de login sin tocar aún el servidor de la
SUNDDE, puedes montar un mock rápido con `json-server` o una función
Express de 5 líneas que responda en `POST /api/auth/login`:

```json
{ "token": "abc123", "nombre": "Usuario de Prueba", "rol": "operativo" }
```

## Qué NO incluye este Sprint (a propósito)

- Formulario de solicitudes con cámara → Sprint 2.
- Dashboard técnico / swipe → Sprint 3.
- Notificaciones push (Firebase) → Sprint 3.
- Persistencia de sesión con *refresh token* en el servidor
  (`sesiones_moviles`) → Backlog, según la Fase de Diseño.

Esto es intencional: el alcance sigue exactamente lo comprometido en
el Sprint Backlog del Informe Parcial, para no exceder lo que un
desarrollador único puede sostener en dos semanas.

## Próximo paso sugerido

Antes de avanzar al Sprint 2, valida en tu propio entorno:
1. Que el login funciona contra el backend real (o el mock).
2. Que un error de red (por ejemplo, apagando el WiFi) muestra el
   mensaje amigable y no un cuelgue de la app.
3. Que cerrar y volver a abrir la app mantiene la sesión iniciada
   (gracias a `flutter_secure_storage`).

Avísame cuando lo pruebes y seguimos con el formulario de solicitudes
y la integración de la cámara (Sprint 2).
