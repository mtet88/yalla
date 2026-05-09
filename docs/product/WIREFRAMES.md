# Wireframes iOS V1: Ideas de Planes

## Objetivo

Definir la estructura de baja fidelidad para la V1 iOS nativa.

Estos wireframes priorizan jerarquia, navegacion, contenido y acciones. No definen visual final, colores ni estilo de marca.

## Principios UX

```txt
iPhone-first, iPad funcional.
La pantalla principal es Vamos!, no la lista de ideas.
Guardar una idea debe estar a un toque en las superficies principales.
El usuario puede probar sin login.
Cada sugerencia debe explicar por que aparece.
La edicion avanzada ocurre despues de guardar.
```

## Navegacion iOS

### Tabs

```txt
( Vamos! )   Ideas   Cuenta
```

Los tabs usan `TabView` nativo. El tab activo debe ser claro, usando las convenciones de iOS salvo que el diseno final pida una tab bar custom.

### Floating Action Button

```txt
+
```

El FAB abre el flujo `Guardar idea` como sheet.

Reglas:

```txt
Visible en Vamos! e Ideas.
Se oculta en Cuenta, Detalle de idea y Guardar idea.
Debe estar optimizado para uso con una mano.
```

En `Guardar idea` y detalle de idea se debe mantener el foco en la tarea actual.

## Screen: Vamos!

### Objetivo

Ayudar al usuario a decidir que hacer en una fecha o momento especifico.

### iPhone Layout

```txt
┌─────────────────────────────┐
│ Vamos!                      │
├─────────────────────────────┤
│ Cuando: [ Hoy v ]           │
│                             │
│ ┌─────────────────────────┐ │
│ │ [Categoria]        [↥]  │ │
│ │                         │ │
│ │     visual/simbolo      │ │
│ │                         │ │
│ │ Picnic en el parque     │ │
│ │ Razon de recomendacion  │ │
│ └─────────────────────────┘ │
│                             │
│                         (+) │
├─────────────────────────────┤
│ Vamos!      Ideas   Cuenta  │
└─────────────────────────────┘
```

Cuando hay sugerencias, el area central muestra un carrusel horizontal de tarjetas visuales. Cada tarjeta es tappable completa; el detalle se abre en modal al tocar cualquier zona que no sea la accion de compartir.

### Selector Fecha

Si `Cuando` es `Fecha`, mostrar un `DatePicker` nativo debajo del selector.

### Tarjeta de Sugerencia

```txt
┌─────────────────────────────┐
│ [Categoria]            [↥]  │
│                             │
│       visual/simbolo        │
│                             │
├─────────────────────────────┤
│ Picnic en el parque         │
│ Razon de recomendacion      │
└─────────────────────────────┘
```

La categoria usa un badge. El boton superior derecho usa share sheet nativa y no navega al detalle.

### Estados

#### Cargando

Para futuras fuentes lentas como clima/backend:

```txt
(loader circular)
Buscando planes para ti
Estamos encontrando las mejores ideas para tu dia.
```

#### Sin Ideas

```txt
Aqui apareceran tus planes
Guarda tu primera idea y te ayudamos a decidir cuando hacerla.

FAB global: +
```

#### Sin Permiso de Ubicacion

Solo cuando la app tenga clima/proximidad:

```txt
Activa tu ubicacion para usar el clima en las sugerencias.

[Usar ubicacion]
[Ahora no]
```

#### Sin Sugerencias Para Esa Fecha

```txt
No hay planes listos para este momento
Prueba otro momento o guarda una nueva idea.

Selector Cuando
FAB global: +
```

## Screen: Guardar Idea

### Objetivo

Capturar una idea con minima friccion.

### Sheet / Navigation Layout

```txt
┌─────────────────────────────┐
│ [ X ]                       │
├─────────────────────────────┤
│ Tira cualquier plan aqui.   │
│                             │
│ Que idea quieres guardar?   │
│ ┌─────────────────────────┐ │
│ │ Picnic en el parque     │ │
│ │ cuando haga buen clima  │ │
│ └─────────────────────────┘ │
│                             │
│ Link opcional               │
│ ┌─────────────────────────┐ │
│ │ https://...             │ │
│ └─────────────────────────┘ │
│                             │
│ [Guardar idea]              │
└─────────────────────────────┘
```

La `X` usa el componente reutilizable `CloseButton`. El boton `Guardar idea` usa el CTA principal reutilizable, igual que `Guardar cambios` en edicion.

### Despues de Guardar

Al guardar, cerrar la sheet y dejar la idea disponible en `Vamos!` e `Ideas`. Los detalles se editan desde el modal de detalle.

```txt
┌─────────────────────────────┐
│ Idea guardada               │
│ Puedes completarla ahora o  │
│ dejarla asi.                │
├─────────────────────────────┤
│ Tipo de idea                │
│ [Planes v]                  │
│                             │
│ Estado                      │
│ [Pendiente v]               │
│                             │
│ Fecha                       │
│ [Sin fecha v]               │
│                             │
│ Titulo                      │
│ Picnic en el parque         │
│                             │
│ Link                        │
│ [https://...]               │
│                             │
│ Ubicacion                   │
│ [Agregar pin en mapa]       │
│                             │
│ Condiciones ideales         │
│ [Buen clima] [Outdoor]      │
│                             │
│ Notas                       │
│ [Opcional]                  │
├─────────────────────────────┤
│ [Guardar cambios]           │
└─────────────────────────────┘
```

Si la idea tiene fecha especifica o rango, el valor se muestra como texto normal junto a una `X` para limpiar la fecha. Elegir fecha especifica o rango abre una sheet enfocada con `X` arriba izquierda y check arriba derecha.

## Screen: Ideas

### Objetivo

Revisar y mantener las ideas guardadas.

### iPhone Layout

```txt
┌─────────────────────────────┐
│ Ideas                       │
├─────────────────────────────┤
│ [Todas] [Pendientes] [...]  │
│                             │
│ ┌─────────────────────────┐ │
│ │ Picnic en el parque     │ │
│ │ Planes · Pendiente      │ │
│ │ Sin fecha               │ │
│ │                    [🗑] │ │
│ └─────────────────────────┘ │
│                             │
│                         (+) │
├─────────────────────────────┤
│ Vamos!      Ideas   Cuenta  │
└─────────────────────────────┘
```

La tarjeta completa abre el detalle en modal. La accion de borrar debe pedir confirmacion y no disparar navegacion.

### Filtros

Los filtros pueden ser chips horizontales:

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

## Screen: Detalle de Idea

### Objetivo

Ver una idea sin entrar directamente al formulario de edicion.

### Layout

```txt
┌─────────────────────────────┐
│ [X] Detalle          Editar │
├─────────────────────────────┤
│ Picnic en el parque         │
│                             │
│ Categoria: Planes           │
│ Estado: Pendiente           │
│ Fecha                       │
│ 15 may 2026                 │
│ Ubicacion: -                │
│ Condiciones: Buen clima     │
│ Notas: -                    │
│                             │
│ [Compartir]                 │
│ [Hecha] [Repetible]         │
│ [Descartar]                 │
│ [Borrar definitivamente]    │
└─────────────────────────────┘
```

El detalle es read-only por defecto y se presenta como modal. Editar abre el formulario dentro del mismo modal.

## Screen: Cuenta

### Objetivo V1

Comunicar el modo local y preparar login futuro.

```txt
┌─────────────────────────────┐
│ Cuenta                      │
├─────────────────────────────┤
│ Modo local                  │
│ Tus ideas se guardan en     │
│ este iPhone/iPad.           │
│                             │
│ Login y sincronizacion      │
│ vendran despues.            │
└─────────────────────────────┘
```

## iPad

iPad puede reutilizar los mismos tabs y layouts con anchos maximos. Mas adelante puede usar split view/sidebar, pero no es requisito para V1.
