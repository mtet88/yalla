# Plan de Producto iOS: Ideas de Planes

## Vision

Una app iOS nativa para guardar ideas de cosas que hacer con amigos y recibir sugerencias utiles cuando llegue el momento de decidir: hoy, manana, este fin de semana o una fecha especifica.

La idea central es que la app funcione como una memoria inteligente de planes. No solo guarda restaurantes, eventos, sitios o actividades, sino que los vuelve a traer cuando tienen sentido segun fecha, clima, estado e historial.

## Frase de Producto

Guarda ideas de planes y recibelas justo cuando tiene sentido hacerlas.

## Problema

Las ideas de planes aparecen en momentos aleatorios y quedan dispersas en notas, screenshots, WhatsApp, Instagram, TikTok, Google Maps o la memoria.

Cuando llega el momento de decidir que hacer, muchas de esas ideas ya no estan presentes, se olvidan, expiran o cuesta encontrarlas.

## Propuesta de Valor

La app permite capturar rapidamente cualquier idea y despues responde la pregunta:

```txt
Vamos!
```

Con sugerencias como:

```txt
Picnic en el parque
Recomendado porque hoy hara buen clima y esta pendiente desde hace 2 meses.
```

```txt
Exhibicion de fotografia
Recomendada porque termina en 10 dias y el domingo va a llover.
```

```txt
Restaurante coreano
Recomendado porque esta pendiente y no has probado comida coreana recientemente.
```

## Enfoque Inicial

La vision final es para grupos de amigos, pero la V1 empieza como una experiencia personal y local-first para validar el comportamiento principal en iPhone.

La app debe sentirse desde el inicio como una lista viva de ideas para hacer con gente, no como una app privada de notas.

## Hipotesis a Validar

1. Una persona guarda ideas de planes espontaneamente si la captura es rapida.
2. Esa persona vuelve a consultar la app cuando necesita decidir que hacer.
3. Las sugerencias contextuales son suficientemente utiles para que la app se vuelva recurrente.
4. Despues de recibir valor personal, el usuario quiere compartir ideas o sugerencias con amigos.

## Objeto Principal

Todo lo que se guarda es una `Idea`.

Una idea puede representar un restaurante, evento, sitio, actividad o cualquier plan posible.

Ejemplos:

```txt
Restaurante japones nuevo
Exhibicion de fotografia en agosto
Museo que queremos visitar
Jugar Nintendo Switch en mi casa
Picnic en el parque cuando haga buen clima
```

## Categorias

La V1 usa pocas categorias, sin subcategorias.

```txt
Comida
Sitios
Eventos
Planes
Otro
```

### Comida

Ideas donde el foco es comer o tomar algo.

```txt
Restaurante
Brunch
Cafe
Postre
Cena
```

### Sitios

Lugares interesantes para visitar o tener en radar.

```txt
Museo
Bar
Discoteca
Rooftop
Parque
Mirador
Mercado
```

### Eventos

Cosas con fecha, rango temporal o programacion.

```txt
Exhibicion
Concierto
Festival
Pop-up
Obra de teatro
Feria
```

### Planes

Actividades o ideas mas flexibles.

```txt
Picnic
Noche de juegos
Cocinar en casa
Jugar Nintendo Switch
Roadtrip corto
Caminar
Plan de lluvia
```

### Otro

Fallback para ideas incompletas, mixtas o dificiles de clasificar.

## Estados

```txt
Pendiente
Hecha
Repetible
Descartada
```

### Pendiente

Idea que nunca se ha hecho.

### Hecha

Idea que se hizo y no se quiere o no se puede repetir.

### Repetible

Idea que se hizo, gusto y puede volver a sugerirse en el futuro.

Regla V1:

```txt
Una idea repetible puede volver a sugerirse despues de 15 dias.
```

### Descartada

Idea que ya no interesa o que expiro.

La app puede descartar automaticamente ideas con fecha fija 1 o 2 dias despues de que pasen, si no fueron marcadas como `Hecha` o `Repetible`.

No se deben borrar automaticamente. Internamente conviene guardar la razon:

```txt
manual
expired
```

## Fechas

La V1 debe soportar:

```txt
Sin fecha
Fecha especifica
Rango de fechas
```

Ejemplos:

```txt
Sin fecha: Restaurante pendiente.
Fecha especifica: Concierto el 12 de junio.
Rango de fechas: Exhibicion del 1 al 30 de agosto.
```

## Ubicacion

La ubicacion es opcional.

Cuando exista, deberia ser un pin seleccionado con una experiencia nativa iOS, preferiblemente MapKit. La V1 deberia guardar:

```txt
locationName
latitude
longitude
address opcional
```

La app no debe pedir ubicacion al crear una idea salvo que el usuario agregue un pin o use una funcion que la requiera.

## Clima

El clima es una mejora de sugerencias, no una dependencia del flujo principal.

En iOS, la app debe pedir permiso de ubicacion con CoreLocation solo cuando el clima/proximidad agregue valor y debe seguir funcionando si el permiso se niega.

La recomendacion tecnica inicial sigue siendo Open-Meteo porque tiene una API gratuita util para clima por coordenadas y no requiere API key para muchos casos.

## Captura de Ideas

La captura principal es:

```txt
Texto libre obligatorio
Link opcional
```

Campos opcionales/editables despues de guardar:

```txt
Categoria
Fecha
Ubicacion
Condiciones ideales
Notas
```

La regla de producto es:

```txt
Guardar primero, enriquecer despues.
```

La captura nunca debe bloquearse porque la app no entendio una fecha, categoria, link, ubicacion o condicion ideal.

Al crear una idea, reglas simples proponen categoria y condiciones ideales. Esas sugerencias aparecen en edicion, pero el usuario puede cambiarlas. La app no debe reclasificar automaticamente una idea editada salvo que exista una accion explicita de reclasificar.

Tocar una idea abre primero el detalle read-only en un modal nativo. Desde ese detalle se puede cerrar con `X`, entrar al formulario de edicion, compartir, borrar definitivamente o cambiar estado.

## Sugerencias

La pantalla principal es `Vamos!`.

El usuario elige un momento:

```txt
Hoy
Manana
Fin de semana
Fecha
```

La app devuelve hasta 5 sugerencias validas y explicables.

Reglas base:

```txt
No sugerir done.
No sugerir discarded.
Sugerir repeatable solo si pasaron al menos 15 dias.
Priorizar fecha relevante.
Priorizar eventos proximos.
Priorizar pendientes antiguas.
Explicar por que aparece cada sugerencia.
```

El scoring puede mejorar con clima, ubicacion e historial, pero debe funcionar sin esas integraciones.

## Compartir

En V1 iOS, compartir puede usar `ShareLink` o la share sheet nativa con texto simple.

Public share links son una integracion posterior cuando exista backend.

## Cuenta y Grupos

La V1 nativa empieza sin login obligatorio.

Supabase Auth/Postgres se agregara despues de validar el flujo local. Cuando exista cuenta, las ideas locales no deben borrarse antes de una migracion remota confirmada.

El modelo debe mantener espacio para grupos futuros con `groupId` opcional.
