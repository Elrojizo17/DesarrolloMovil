# Mensajes Emergentes en Flutter para Android
*Dentro y fuera de la interfaz de usuario*

**Universidad del Valle**  
750026C Desarrollo de Aplicaciones para Dispositivos Móviles  
Mg. Diana Marcela Ramirez Rodriguez

| Asignatura | Resultado de Aprendizaje | Plataforma | Modalidad |
|---|---|---|---|
| 750026C | RA-1, RA-2 | Flutter (Dart) para Android | Clase invertida / Práctica |

---

## 1. Introducción

En el desarrollo de aplicaciones móviles, la comunicación con el usuario es fundamental. Flutter ofrece distintos mecanismos para mostrar mensajes emergentes, cada uno con un propósito específico según el contexto de interacción.

Estos mecanismos se dividen en dos grandes categorías:

- **Mensajes dentro de la UI:** se muestran sobre el contenido de la pantalla actual sin abandonar la aplicación.
- **Mensajes fuera de la UI:** se muestran en el sistema operativo, fuera de la interfaz de la app (notificaciones).

---

## 2. Mensajes dentro de la UI

Estos componentes son nativos del framework Flutter y no requieren paquetes externos.

### 2.1 SnackBar

El SnackBar es el componente principal para mensajes breves y no intrusivos. Aparece en la parte inferior de la pantalla y desaparece automáticamente. Puede incluir una acción (por ejemplo, "Deshacer").

**Características principales:**
- Duración configurable (corta o larga).
- Soporta un botón de acción opcional.
- Se gestiona a través de `ScaffoldMessenger` para evitar problemas con context obsoleto.

**Ejemplo de uso básico:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Archivo guardado exitosamente'),
    duration: Duration(seconds: 3),
  ),
);
```

**Ejemplo con acción:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Mensaje eliminado'),
    action: SnackBarAction(
      label: 'Deshacer',
      onPressed: () {
        // lógica para revertir la acción
      },
    ),
  ),
);
```

> **Nota:** Desde Flutter 2.0, se recomienda usar `ScaffoldMessenger` en lugar de `Scaffold.of(context)` para mostrar SnackBars, ya que evita errores cuando el contexto cambia.

---

### 2.2 AlertDialog

El AlertDialog interrumpe el flujo del usuario para solicitar una decisión o mostrar información crítica. Bloquea la interacción con el resto de la pantalla hasta que el usuario responde.

**Características principales:**
- Título, contenido y botones configurables.
- Modal: bloquea la interacción con la pantalla de fondo.
- Soporta contenido personalizado (widgets arbitrarios en el body).

**Ejemplo de confirmación:**

```dart
showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text('¿Eliminar archivo?'),
      content: Text('Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            eliminarArchivo();
            Navigator.pop(context);
          },
          child: Text('Eliminar'),
        ),
      ],
    );
  },
);
```

---

### 2.3 SimpleDialog

El SimpleDialog presenta una lista de opciones al usuario. Es ideal cuando se deben mostrar varias alternativas sin formularios complejos.

```dart
showDialog(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text('Selecciona un idioma'),
    children: [
      SimpleDialogOption(
        onPressed: () { Navigator.pop(context, 'es'); },
        child: Text('Español'),
      ),
      SimpleDialogOption(
        onPressed: () { Navigator.pop(context, 'en'); },
        child: Text('English'),
      ),
    ],
  ),
);
```

---

### 2.4 BottomSheet

El BottomSheet emerge desde la parte inferior de la pantalla. Existen dos variantes: modal (bloquea la interacción) y persistente (convive con el contenido).

```dart
// BottomSheet modal
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.share),
          title: Text('Compartir'),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: Icon(Icons.download),
          title: Text('Descargar'),
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
  ),
);
```

---

## 3. Notificaciones fuera de la UI

Las notificaciones permiten comunicarse con el usuario, aunque la aplicación esté en segundo plano o cerrada. En Flutter se utilizan paquetes externos porque el framework no incluye esta funcionalidad de forma nativa.

### 3.1 Paquete `flutter_local_notifications`

Este es el paquete más utilizado para notificaciones locales (generadas por la propia app, sin servidor).

**Instalación en `pubspec.yaml`:**

```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0  # necesario para notificaciones programadas
```

**Configuración inicial** (se hace una sola vez, típicamente en `main.dart`):

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings settings =
      InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(settings);
}
```

**Mostrar una notificación simple:**

```dart
Future<void> mostrarNotificacion() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'canal_principal',       // ID del canal
    'Alertas de la app',     // nombre visible
    channelDescription: 'Notificaciones generales',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,                             // ID único de la notificación
    'Nueva tarea',                 // título
    'Tienes una entrega pendiente', // cuerpo
    details,
  );
}
```

> **Importante:** Desde Android 13 (API 33) es obligatorio solicitar el permiso `POST_NOTIFICATIONS` en tiempo de ejecución. Sin este permiso, las notificaciones no se muestran.

---

### 3.2 Permiso en Android 13+

**`AndroidManifest.xml`:**

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

**En Dart** (usando el paquete `permission_handler`):

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> solicitarPermiso() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
```

---

### 3.3 Notificación programada

Se puede programar una notificación para que aparezca en un momento específico:

```dart
import 'package:timezone/timezone.dart' as tz;

await notificationsPlugin.zonedSchedule(
  1,
  'Recordatorio',
  'Tienes una reunión en 10 minutos',
  tz.TZDateTime.now(tz.local).add(Duration(minutes: 10)),
  details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
);
```

---

## 4. ¿Cuándo usar cada componente?

| Componente | Cuándo usarlo | Interacción del usuario |
|---|---|---|
| SnackBar | Confirmaciones breves sin acción crítica | Ninguna (desaparece solo) |
| SnackBar + action | Acciones reversibles (borrar, archivar) | Botón opcional (Deshacer) |
| AlertDialog | Decisiones críticas o confirmaciones | Obligatoria (botones) |
| SimpleDialog | Selección entre múltiples opciones | Seleccionar una opción |
| BottomSheet | Menús contextuales, opciones secundarias | Tocar una opción o cerrar |
| Notificación local | Alertas cuando la app está en segundo plano | Toque abre la app |
| Notificación programada | Recordatorios a una hora específica | Toque abre la app |

---

## 5. Ejercicio Práctico

### Aplicación: Gestor de tareas con notificaciones

- **Duración estimada:** 2 horas de trabajo
- **Entrega:** Repositorio GitHub con código fuente y capturas de pantalla

### 5.1 Descripción

Construya una aplicación Flutter para Android que implemente un gestor de tareas básico. La app debe demostrar el uso apropiado de los distintos tipos de mensajes emergentes vistos en esta guía.

### 5.2 Requerimientos funcionales

**RF-1: Lista de tareas**
- La pantalla principal muestra una lista de tareas con nombre y estado (pendiente / completada).
- Cada tarea tiene un botón para marcarla como completada y otro para eliminarla.

**RF-2: Agregar tarea (AlertDialog)**
- Un `FloatingActionButton` abre un `AlertDialog` con un campo de texto.
- El diálogo tiene botones 'Cancelar' y 'Agregar'.
- Si el campo está vacío y el usuario presiona 'Agregar', se muestra un SnackBar de error.

**RF-3: Eliminar tarea (SnackBar con Deshacer)**
- Al eliminar una tarea se muestra un SnackBar con el mensaje 'Tarea eliminada' y el botón 'Deshacer'.
- Si el usuario presiona 'Deshacer', la tarea vuelve a la lista en su posición original.

**RF-4: Opciones de tarea (BottomSheet)**
- Al hacer long press sobre una tarea se abre un `ModalBottomSheet` con opciones: Completar, Eliminar, Recordarme.
- La opción 'Recordarme' programa una notificación local para 1 minuto después.

**RF-5: Notificación local**
- La app solicita permiso de notificaciones al iniciar (Android 13+).
- La notificación muestra el nombre de la tarea como título y 'Tienes una tarea pendiente' como cuerpo.
- Al tocar la notificación, la app se abre (se puede usar la pantalla principal).

### 5.3 Requerimientos no funcionales

- El código debe estar organizado en al menos dos archivos Dart (`main.dart` y un archivo para la lógica de notificaciones).
- Se deben manejar los casos de error (lista vacía, campo en blanco).
- La interfaz debe seguir las guías de Material Design 3.

### 5.4 Entregables

1. Repositorio en GitHub con el código fuente completo.
2. Archivo `README.md` que incluya: descripción de la app, instrucciones de instalación y capturas de pantalla de cada mensaje emergente implementado.
3. Video corto (máximo 2 minutos) demostrando el funcionamiento de los 5 requerimientos funcionales.

---

## 6. Rúbrica de Evaluación

| Criterio | Excelente (5) | Aceptable (3) | Insuficiente (1) |
|---|---|---|---|
| SnackBar básico y con acción Deshacer | Funciona correctamente, maneja el estado de la lista al deshacer | Funciona pero no restaura la tarea en posición original | No implementado o no funciona |
| AlertDialog para agregar tarea | Valida campo vacío, cierra correctamente, agrega a la lista | Abre y cierra pero sin validación | No implementado |
| BottomSheet con opciones | Tres opciones funcionales, se cierra al seleccionar | Se abre pero solo una opción funciona | No implementado |
| Notificación local | Solicita permiso, se muestra fuera de la app, abre la app al tocar | Se muestra pero no solicita permiso o no abre la app | No implementado |
| Calidad del código | Código limpio, bien organizado, README completo con capturas | Código funcional pero sin organización o README incompleto | Código desorganizado o sin README |

> **Criterio de aprobación:** Para aprobar el ejercicio se debe obtener al menos 3 puntos en cada criterio (nivel Aceptable). Un criterio en nivel Insuficiente implica revisión obligatoria.

---

## 7. Referencias

- [Flutter documentation - SnackBar](https://api.flutter.dev/flutter/material/SnackBar-class.html)
- [Flutter documentation - AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html)
- [flutter_local_notifications package](https://pub.dev/packages/flutter_local_notifications)
- [Material Design 3 - Communication patterns](https://m3.material.io/components/snackbar/overview)
- [Android Notification documentation](https://developer.android.com/develop/ui/views/notifications)
