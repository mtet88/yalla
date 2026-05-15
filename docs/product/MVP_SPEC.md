# MVP Spec iOS: Ideas de Planes

## Objetivo

Construir una V1 iOS nativa que permita guardar ideas de planes, recibir sugerencias contextuales y compartirlas con amigos desde el flujo nativo de iOS.

La V1 valida el uso personal, pero debe estar preparada para grupos en el modelo de datos y lenguaje de producto.

## Principios de Producto

```txt
Guardar primero, enriquecer despues.
La pantalla principal es Vamos!, no una lista.
Todo se guarda como una Idea.
La app debe funcionar sin IA obligatoria.
La experiencia debe sentirse social aunque la V1 sea personal.
```

## Alcance V1 Actual

Incluye o debe incluir en el core local:

```txt
App iOS SwiftUI para iPhone con soporte iPad basico
Modo local sin login obligatorio
Crear idea con texto libre y link opcional
Editar detalles de una idea
Estados: Pendiente, Hecha, Repetible, Descartada
Categorias: Comida, Sitios, Eventos, Planes, Otro
Fechas editables: sin fecha, especifica, rango
Persistencia local en UserDefaults bajo ideas:v1
Sugerencias por scoring simple y explicable
Compartir idea o sugerencia usando ShareLink/share sheet nativa
UI localizada en espanol e ingles
```

Planificado despues del core local:

```txt
Login con Google/email magic link via Supabase
Ubicacion opcional con pin en MapKit
Clima por CoreLocation + Open-Meteo
Migracion guest -> cuenta
Public share links
Grupos completos
```

No incluye en V1:

```txt
Votaciones
Chat
Disponibilidad de amigos
Calendarios compartidos
Reservas
Pagos
Importadores de redes sociales
IA como dependencia critica
```

## Navegacion Principal

La app tiene cuatro areas de producto, aunque solo tres viven como tabs principales:

```txt
Vamos!
Ideas
Cuenta
Guardar idea
```

En iOS, `Vamos!`, `Ideas` y `Cuenta` viven en `TabView`. `Guardar idea` vive como accion global `+` flotante, visible en `Vamos!` e `Ideas`, y se presenta como sheet enfocada.

En flujos enfocados como `Guardar idea` y detalle de idea, se debe minimizar la navegacion global para evitar distracciones o salidas accidentales. Ambos flujos deben tener un cierre explicito con `X`.

## Idiomas

La copy fuente del producto es espanol. La V1 debe poder renderizar la interfaz en espanol e ingles usando el locale activo del sistema o del entorno de tests.

Reglas:

```txt
No traducir datos del usuario como titulo, notas, ubicacion o links.
Localizar labels de dominio, estados, filtros, fallbacks y razones de sugerencia.
Mantener los identificadores internos y datos persistidos estables en ingles cuando ya existan como raw values.
```

## Pantalla: Vamos!

Esta es la pantalla inicial.

### Objetivo

Ayudar al usuario a decidir que hacer en una fecha o momento especifico.

### Elementos

```txt
Selector Cuando: Hoy, Manana, Fin de semana, Fecha
DatePicker nativo cuando se elige Fecha
Estado de carga si alguna fuente futura tarda en responder
Carrusel horizontal de hasta 5 sugerencias validas
Estado vacio/onboarding cuando no hay ideas guardadas
Estado sin sugerencias cuando existen ideas pero ninguna aplica
Acceso rapido a Guardar idea mediante FAB global +
```

### Estado Vacio / Onboarding

Si no hay ideas guardadas:

```txt
Aqui apareceran tus planes
Guarda tu primera idea y te ayudamos a decidir cuando hacerla.
```

CTA:

```txt
FAB global +
```

### Sin Sugerencias Valididas

Si hay ideas guardadas pero ninguna puede sugerirse para el momento seleccionado:

```txt
No hay planes listos para este momento
Prueba otro momento o guarda una nueva idea.
```

### Resultado de Sugerencias

Cada sugerencia muestra:

```txt
Visual o simbolo segun categoria
Boton de compartir
Titulo
Categoria
Razon de recomendacion
Fecha si aplica
Distancia aproximada si hay ubicacion futura
```

La tarjeta completa debe ser tappable y abrir el detalle de la idea en modal. El boton de compartir vive como accion secundaria dentro de la tarjeta y no debe disparar la presentacion del detalle.

## Pantalla: Guardar Idea

### Objetivo

Capturar una idea con la menor friccion posible.

### Campos Iniciales

```txt
Texto libre obligatorio
Link opcional
```

### CTA Principal

```txt
Guardar idea
```

### Comportamiento

Al guardar:

```txt
La idea se crea inmediatamente.
La app intenta clasificarla con reglas simples.
La app cierra la sheet al guardar y la idea queda disponible en `Vamos!` e `Ideas`.
```

### Confirmacion Editable

Campos editables despues de guardar:

```txt
Titulo
Categoria
Estado
Fecha
Ubicacion
Condiciones ideales
Notas
Link
```

Regla:

```txt
Ningun campo extra debe ser obligatorio.
```

## Pantalla: Ideas

### Objetivo

Permitir revisar, filtrar y mantener las ideas guardadas.

El header de la pantalla muestra solo el titulo `Ideas`, sin eyebrow ni texto descriptivo adicional.

### Filtros

```txt
Todas
Pendientes
Repetibles
Hechas
Descartadas
Comida
Sitios
Eventos
Planes
Otro
```

### Orden Default

```txt
Pendientes mas recientes primero
Eventos proximos arriba
Repetibles disponibles arriba
Descartadas al final
```

### Tarjeta de Idea

```txt
Titulo
Categoria
Estado
Fecha si aplica
Ubicacion si aplica
Link si aplica
Boton Borrar
```

La tarjeta completa abre el detalle de la idea en modal. No debe necesitar un boton `Ver`. El borrado debe evitar navegacion accidental y pedir confirmacion.

## Pantalla: Detalle de Idea

### Objetivo

Ver una idea en modal sin entrar directamente al formulario de edicion. Desde el detalle, el usuario puede editar, compartir, borrar, cambiar estado o cerrar con `X`.

### Campos en Detalle

```txt
Titulo
Categoria
Estado
Link
Fecha
Ubicacion
Condiciones ideales
Notas
Fecha de creacion
Ultima vez sugerida
```

### Acciones

```txt
Editar
Compartir
Marcar como Hecha
Marcar como Repetible
Descartar
Borrar definitivamente
```

Cambiar estado debe persistir inmediatamente en `UserDefaults`.

## Pantalla: Cuenta

### Objetivo V1 Local

Explicar el modo local y preparar el espacio para login futuro.

Contenido esperado:

```txt
Modo local activo
Tus ideas se guardan en este iPhone/iPad
Login y sincronizacion vendran despues
```

## Persistencia

La V1 iOS guarda ideas en `UserDefaults` con la key:

```txt
ideas:v1
```

La estructura debe mantenerse compatible conceptualmente con el producto web para facilitar migracion futura.

## Reglas de Sugerencia

```txt
Excluir done.
Excluir discarded.
Permitir repeatable solo despues de 15 dias.
Retornar maximo 5 sugerencias.
Cada sugerencia debe tener al menos una razon legible.
El resultado debe ser deterministico para el mismo input.
```

## Criterios de Aceptacion

1. Una persona puede abrir la app y entender que `Vamos!` es la pantalla principal.
2. Una persona puede guardar una idea con solo texto.
3. Una persona puede guardar una idea con texto y link opcional.
4. La idea aparece en `Ideas` despues de guardarse.
5. La idea puede abrirse en detalle modal.
6. La idea puede editarse sin requerir campos extra.
7. La idea puede cambiar de estado.
8. `done` y `discarded` no aparecen en sugerencias.
9. `repeatable` solo vuelve a sugerirse despues de 15 dias.
10. Las sugerencias explican por que aparecen.
