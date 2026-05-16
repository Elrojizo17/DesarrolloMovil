# Jugabilidad Actual - Paleto Knife

Fecha de corte: 28/03/2026
Estado: Implementada en la pantalla de batalla y funcional por lógica de juego en tiempo real.

## 1. Resumen General

La jugabilidad actual está centrada en un combate 1 vs 1 entre Chef y Enemigo.

El loop de juego corre de forma continua y permite:
- Movimiento horizontal del Chef.
- Ataque manual del Chef por botón.
- Ataques automáticos del enemigo con telegrafiado (zona roja previa).
- Cálculo de daño dinámico según distancia.
- Fin de combate por derrota de alguno de los dos personajes.

## 2. Flujo de Acceso al Gameplay

1. El jugador entra a la pestaña de combate.
2. Ve datos del enemigo actual (nombre, nivel y HP).
3. Presiona Iniciar Batalla.
4. Se crea una batalla nueva con:
- Chef con vida máxima según nivel global.
- Enemigo con vida según amalgama actual.
5. Se abre la pantalla de batalla dedicada.

## 3. Controles del Jugador

### 3.1 Movimiento

El Chef se mueve solo en eje horizontal (izquierda y derecha).

Detalles:
- Control por botones táctiles laterales.
- Al mantener presionado, el personaje se desplaza continuamente.
- La posición se limita entre -1.0 y 1.0 para no salir del área.

### 3.2 Ataque del Chef

El ataque del Chef es manual mediante botón ATACAR.

Reglas principales:
- Tiene cooldown corto para evitar spam extremo.
- Puede encadenar combo si ataca dentro de una ventana temporal.
- El daño aumenta con:
- Cercanía al centro objetivo.
- Multiplicador de combo.

Feedback visual:
- Texto de daño flotante sobre el enemigo.
- Etiqueta del botón mostrando combo (ejemplo: ATACAR x2).

## 4. Sistema de Ataque del Enemigo

El enemigo ataca en ciclos automáticos, no instantáneos:

1. Inicia fase de telegrafiado.
2. Marca una zona roja objetivo (trackea la posición del Chef durante carga).
3. Bloquea objetivo al finalizar la carga.
4. Ejecuta golpe.
5. Si el Chef sigue dentro del área, recibe daño.

Características del sistema:
- Ataques con jitter para evitar ritmo totalmente fijo.
- Zona de peligro visual (barra roja y línea vertical).
- Barra de progreso del ataque enemigo.
- Mensaje contextual para esquivar.

## 5. Sistema de Daño y Vida

### 5.1 Vida

Cada personaje usa un modelo con:
- maxHealth
- currentHealth
- isDefeated

La vida nunca baja de 0 ni supera su máximo.

### 5.2 Daño del Chef

Se calcula según:
- Daño base.
- Bono por proximidad.
- Bono por combo.

### 5.3 Daño del Enemigo

Se calcula según:
- Daño base.
- Bono por proximidad del Chef al centro de impacto enemigo.

### 5.4 Barras de Vida

HUD compacto y responsivo:
- Barra de enemigo y barra de chef visibles en la parte superior.
- Animación suave al actualizar HP.
- Color por umbral de vida:
- Verde alta vida.
- Naranja vida media.
- Rojo vida crítica.

## 6. Estado de Combate

La batalla maneja estados:
- idle
- chefAttacking
- enemyAttacking
- gameOver

Además, controla:
- Posición horizontal del Chef.
- Ventanas de tiempo de ataque.
- Progreso de telegrafiado enemigo.
- Objetivo de golpe bloqueado.

## 7. Game Loop y Tiempo Real

La simulación usa un ciclo continuo aproximado a 60 FPS.

En cada tick:
1. Se actualiza el movimiento del Chef.
2. Se procesa la máquina de estados del ataque enemigo.
3. Se evalúan impactos.
4. Se actualiza UI y efectos.
5. Se verifica condición de fin.

## 8. Responsive y Adaptación a Pantalla

La pantalla de batalla ajusta tamaños según dimensiones disponibles:
- Alto de HUD.
- Alto de arena de combate.
- Alto de panel de controles.
- Tamaño de personajes.
- Tamaño de botones.
- Tamaño de tipografías e iconos.

El diseño usa LayoutBuilder para escalar en móviles con diferentes resoluciones.

## 9. Fin de Partida

Condiciones:
- Si vida del Chef llega a 0: derrota.
- Si vida del enemigo llega a 0: victoria.

UI de cierre:
- Overlay de resultado.
- Mensaje de victoria o derrota.
- Botón para volver a la pantalla anterior.

## 10. Conexión con la Progresión Global

Actualmente:
- El combate se inicializa con stats derivados del nivel y enemigo actual.
- La batalla funciona como instancia local de enfrentamiento.

Importante:
- El resultado de la batalla no está aplicando recompensas directas al progreso global dentro de esta pantalla de combate en el código actual.

## 11. Parámetros de Jugabilidad Actuales

Valores observados en la implementación actual:
- Velocidad de movimiento Chef: 0.028
- Zona de impacto enemigo: 120 px
- Daño enemigo base: 8
- Daño enemigo extra por proximidad: 8
- Daño chef base: 8
- Daño chef extra por proximidad: 14
- Telegraph enemigo: 900 ms
- Strike enemigo: 240 ms
- Cooldown enemigo: 1600 ms (+ jitter)
- Cooldown ataque chef: 280 ms
- Ventana de combo chef: 700 ms

## 12. Archivos Relevantes de Jugabilidad

- lib/screens/battle_game_screen.dart
- lib/screens/tabs/combat_tab.dart
- lib/models/battle_character.dart
- lib/models/battle_state.dart
- lib/widgets/compact_health_bar.dart
- lib/widgets/enemy_character.dart
- lib/widgets/chef_character.dart

## 13. Estado Actual

La jugabilidad actual sí incluye interacción real:
- Esquivar ataques enemigos en tiempo real.
- Atacar manualmente con combo.
- Ver daño y respuesta visual en HUD y arena.

El núcleo jugable de combate está implementado y activo en la pantalla de batalla.
