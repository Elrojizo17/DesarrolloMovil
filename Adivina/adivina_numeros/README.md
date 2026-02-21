# 🎯 Adivina el Número PRO

## 📌 Descripción del Proyecto

**Adivina el Número PRO** es una aplicación desarrollada en Flutter
donde el usuario debe adivinar un número secreto generado aleatoriamente
dentro de un rango determinado.

El proyecto evolucionó desde una versión básica hasta una versión
avanzada con mejoras visuales, animaciones, sistema de puntuación y
personalización de tema.

------------------------------------------------------------------------

## 🚀 Mejoras Implementadas

El desarrollo se organizó en tres niveles: básico, intermedio y
avanzado.

------------------------------------------------------------------------

## 🟢 Nivel 1 -- Mejoras Básicas

### 🎨 Cambio de Tema Visual

-   Implementación de modo claro y modo oscuro real usando `ThemeMode`.
-   Switch funcional que cambia el tema sin reiniciar el juego.
-   Gradiente dinámico según el tema seleccionado.

### 😄 Personalización de Mensajes

-   Mensajes iniciales más dinámicos y atractivos.
-   Uso estratégico de emojis para mejorar la experiencia.

### 🎯 Ajuste de Intentos

-   Configuración variable de intentos según dificultad.
-   Impacto directo en el nivel de reto del jugador.

------------------------------------------------------------------------

## 🟡 Nivel 2 -- Mejoras Intermedias

### 💡 Botón de Pista

-   Indica si el número es PAR o IMPAR.
-   Cada uso reduce un intento disponible.

### 📊 Indicador Visual de Progreso

-   `LinearProgressIndicator` dinámico.
-   Colores según estado:
    -   🟢 Verde → muchos intentos
    -   🟡 Amarillo → riesgo medio
    -   🔴 Rojo → pocos intentos

### 🧠 Historial de Intentos

-   Implementado con `Wrap` y `Chip`.
-   Colores según resultado (alto, bajo o correcto).

------------------------------------------------------------------------

## 🔴 Nivel 3 -- Mejoras Avanzadas

### ✨ Animaciones

-   `AnimationController` y `ScaleTransition` para efecto rebote al
    ganar.
-   `AnimatedContainer` para transiciones suaves.

### 🏆 Sistema de Puntuación

-   Persistencia con `SharedPreferences`.
-   Guarda el mejor récord (menor número de intentos).
-   El récord permanece incluso al cerrar la app.

### 🎮 Sistema de Dificultad

-   **Modo Fácil:** Rango 1--50, 7 intentos.
-   **Modo Difícil:** Rango 1--200, 4 intentos.
-   Reinicia la partida al cambiar dificultad.

------------------------------------------------------------------------

## 🛠 Tecnologías Utilizadas

-   Flutter
-   Dart
-   Material 3
-   SharedPreferences
-   AnimationController
-   StatefulWidget y manejo de estado con setState

------------------------------------------------------------------------

## 📈 Resultado Final

El proyecto evolucionó a una aplicación completa con:

-   Interfaz moderna
-   Soporte para modo oscuro/claro
-   Sistema de dificultad configurable
-   Persistencia de datos
-   Animaciones interactivas
-   Indicadores visuales dinámicos
-   Historial estilizado

------------------------------------------------------------------------

## 👨‍💻 Autor

Proyecto desarrollado como práctica avanzada de Flutter.
