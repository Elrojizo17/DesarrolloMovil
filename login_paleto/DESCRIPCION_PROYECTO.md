# Descripción del Proyecto - Paleto Knive

## Información General

**Nombre:** login_paleto  
**Título de la Aplicación:** Paleto Knive  
**Tecnología:** Flutter (Framework multiplataforma para desarrollo móvil)  
**Versión:** 1.0.0+1  
**SDK de Flutter:** ^3.11.0  
**Estado:** Privado (no publicado en pub.dev)

---

## Propósito del Proyecto

**Paleto Knive** es una aplicación móvil desarrollada en Flutter diseñada para gestionar y presentar información sobre cuchillos de cocina. Es una aplicación que combina funcionalidades de autenticación de usuarios, notificaciones locales y una interfaz visual atractiva para usuarios interesados en herramientas culinarias.

---

## Características Principales

### 1. **Autenticación de Usuarios**
   - Sistema deLogin con credenciales por defecto:
     - Email: `usuario@palet.knive`
     - Contraseña: `paleto123`
   - Sistema de Registro personalizado de nuevos usuarios
   - Validación de credenciales contra cuentas registradas

### 2. **Splash Screen Animada**
   - Pantalla de inicio con animación profesional
   - Logo animado con efectos de escala y rotación
   - Duración: 4 segundos anteriormente a la navegación a la pantalla principal
   - Tema de color: Naranja profundo

### 3. **Sistema de Notificaciones**
   - Integración de notificaciones locales mediante `flutter_local_notifications`
   - Soporte para zonas horarias (`timezone`)
   - Método de inicialización en main.dart

### 4. **Diseño Visual**
   - Utiliza Material Design 3 (useMaterial3: true)
   - Esquema de colores basado en naranja profundo
   - Icono de aplicación basado en `Icons.restaurant`
   - Sin mostrar banner de debug en producción

---

## Estructura del Proyecto

```
login_paleto/
├── lib/
│   ├── main.dart                    # Archivo principal con la lógica de autenticación
│   └── notification_service.dart    # Servicio de notificaciones
├── android/                         # Configuración específica para Android
├── ios/                             # Configuración específica para iOS
├── windows/                         # Configuración para Windows
├── web/                             # Configuración para Web
├── linux/                           # Configuración para Linux
├── macos/                           # Configuración para macOS
├── pubspec.yaml                     # Dependencias y configuración del proyecto
└── README.md                        # Archivo de lectura inicial
```

---

## Dependencias Principales

### Dependencias de Producción
- **flutter**: Framework base
- **cupertino_icons** (^1.0.8): Iconos de estilo iOS
- **flutter_local_notifications** (^17.2.4): Sistema de notificaciones locales
- **timezone** (^0.9.4): Manejo de zonas horarias

### Dependencias de Desarrollo
- **flutter_test**: Framework de pruebas
- **flutter_lints** (^6.0.0): Reglas de linting recomendadas

---

## Flujo de la Aplicación

1. **Inicialización (`main()`):**
   - Se asegura que los widgets estén inicializados
   - Inicializa el servicio de notificaciones
   - Ejecuta la aplicación con `runApp()`

2. **SplashScreen:**
   - Pantalla inicial con logo animado
   - Se mostrará durante 4 segundos
   - Luego navega automáticamente a HomeScreen

3. **HomeScreen:**
   - Pantalla principal de la aplicación
   - Accesible después de pasar el splash

4. **Autenticación:**
   - Los usuarios pueden iniciar sesión con las credenciales por defecto
   - Pueden registrar nuevas cuentas
   - Se pueden mostrar mensajes de bienvenida personalizados

---

## Plataformas Soportadas

- ✅ **Android**
- ✅ **iOS**
- ✅ **Windows**
- ✅ **Web**
- ✅ **Linux**
- ✅ **macOS**

---

## Configuración Visual

### Tema de Color
- **Seed Color:** Orange Deep (naranja profundo)
- **Material Design:** Versión 3
- **Fuentes:** CupertinoIcons

### Información del Debugging
- **Debug Banner:** Deshabilitado para una experiencia limpia en desarrollo

---

## Próximos Pasos Sugeridos

1. Implementar la pantalla HomeScreen detallada
2. Integrar una base de datos real (Firebase, SQLite, etc.)
3. Mejorar el sistema de autenticación con tokens JWT
4. Diseñar catálogo de cuchillos
5. Implementar carrito de compras (si es una tienda)
6. Agregar más pantallas de funcionalidad
7. Pruebas unitarias y de integración

---

## Notas Técnicas

- La aplicación está en fase inicial de desarrollo
- Utiliza CleanCode y estructura básica de Material Design
- Tiene capacidad para notificaciones programadas
- Está optimizada para múltiples plataformas desde el inicio del proyecto

---

**Última Actualización:** Marzo 2026
