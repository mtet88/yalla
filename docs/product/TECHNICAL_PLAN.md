# Technical Plan iOS V1: Ideas de Planes

## Decision Principal

La V1 es una app iOS nativa con SwiftUI, local-first, optimizada primero para iPhone y funcional en iPad.

La app debe sentirse como una app movil nativa, no como un dashboard web ni como una copia literal de la web app.

## Stack V1

```txt
SwiftUI
Observation
Foundation
UserDefaults para modo local inicial
String Catalog (`Localizable.xcstrings`) para localizacion es/en
Swift Testing para unit tests
XCTest/XCUITest para UI tests
Xcode project nativo
```

Integraciones planificadas:

```txt
CoreLocation para permiso de ubicacion
Open-Meteo para clima
MapKit para seleccionar pin
Supabase Auth + Postgres despues de validar flujo local
iOS ShareLink/share sheet para compartir local
Public share links cuando exista backend
```

## Por Que Este Stack

### SwiftUI

Permite construir rapido pantallas nativas con `TabView`, `NavigationStack`, sheets y componentes declarativos.

### Observation

Encaja con el estado local actual de `IdeaStore` y reduce boilerplate frente a patrones antiguos.

### UserDefaults

Suficiente para el primer modo local/invitado.

Permite validar sin auth/backend y mantiene una key compatible conceptualmente con el producto web:

```txt
ideas:v1
```

Si el estado local crece, se puede evaluar SwiftData o SQLite antes de sincronizacion remota.

### Open-Meteo

API gratuita y simple para clima por coordenadas. Debe enriquecer sugerencias, no bloquear el uso.

### MapKit

Es la opcion nativa para mapa y pin selection en iOS, reemplazando el plan web basado en Leaflet.

### Supabase

Se agrega despues de que el flujo local funcione.

Usos:

```txt
Auth con Google/email magic link
Postgres para persistencia sincronizada
Shared links
Base preparada para grupos futuros
```

## Estrategia de Implementacion

La app se construye local-first.

Orden recomendado:

```txt
1. UI SwiftUI nativa sin backend
2. Persistencia local en UserDefaults
3. Clasificacion y scoring local
4. Detalle/edicion robustos
5. Share sheet local
6. Clima con CoreLocation + Open-Meteo
7. Ubicacion con MapKit
8. Supabase Auth + Postgres
9. Migracion local -> cuenta
10. Compartir links publicos
```

## Estructura de Proyecto Actual

```txt
openkoudios/
  openkoudiosApp.swift
  ContentView.swift
  Models/
    Idea.swift
  Localizable.xcstrings
  Services/
    IdeaClassifier.swift
    IdeaExpiration.swift
    IdeaScoring.swift
  Stores/
    IdeaStore.swift
  Views/
    DesignSystem/
      Buttons.swift
    AppRootView.swift
    VamosView.swift
    SaveIdeaView.swift
    IdeasListView.swift
    IdeaDetailView.swift
    AccountView.swift
    Components.swift

openkoudiosTests/
openkoudiosUITests/
```

## Design System / Componentes Visuales

Los componentes visuales reutilizables viven en `Views/DesignSystem/`. Esta carpeta es para piezas de UI genericas de marca que deben verse igual en toda la app.

Componentes actuales:

```txt
CloseButton: boton X de cierre para sheets y flujos enfocados.
ConfirmButton: boton check de confirmacion para toolbar en sheets enfocadas.
PrimaryCTAButton: CTA principal full-width para acciones como Guardar idea y Guardar cambios.
```

Reglas:

```txt
Usar Color.yallaPrimary para acciones principales de marca.
No duplicar estilos de botones principales dentro de cada pantalla.
Mantener los CTAs principales como botones full-width con capsule.
Mantener el cierre de flujos enfocados con X arriba a la izquierda cuando haya NavigationStack propio.
```

## Navegacion iOS

La app usa tabs principales:

```txt
Vamos!
Ideas
Cuenta
```

`Guardar idea` no es tab principal; se abre como sheet desde un `+` flotante global visible en `Vamos!` e `Ideas`.

Detalle de idea se presenta como sheet desde sugerencias o tarjetas de lista. La sheet contiene su propio `NavigationStack` para toolbar, cierre con `X`, edicion y acciones internas.

## Tipos Core

El modelo Swift debe mantener equivalencia con el modelo conceptual del producto:

```swift
enum IdeaCategory: String, Codable {
    case food
    case places
    case events
    case plans
    case other
}

enum IdeaStatus: String, Codable {
    case pending
    case done
    case repeatable
    case discarded
}

enum IdeaDateType: String, Codable {
    case none
    case single
    case range
}

struct Idea: Identifiable, Codable, Hashable {
    var id: String
    var rawText: String
    var title: String
    var link: String?
    var category: IdeaCategory
    var status: IdeaStatus
    var discardedReason: DiscardedReason?
    var dateType: IdeaDateType
    var dateStart: Date?
    var dateEnd: Date?
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    var address: String?
    var idealConditions: [IdealCondition]
    var notes: String?
    var createdByUserId: String?
    var ownerUserId: String?
    var groupId: String?
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var lastSuggestedAt: Date?
    var lastRepeatedAt: Date?
}
```

## Labels de UI

El codigo puede usar enums en ingles, pero los labels visibles deben resolverse mediante localizacion. El idioma fuente del producto sigue siendo espanol y la app soporta renderizado en espanol (`es`) e ingles (`en`) desde `Localizable.xcstrings`.

```txt
food -> Comida
places -> Sitios
events -> Eventos
plans -> Planes
other -> Otro

pending -> Pendiente
done -> Hecha
repeatable -> Repetible
discarded -> Descartada
```

Reglas:

```txt
Mantener raw values/enums estables en ingles para datos persistidos.
Usar LocalizedStringKey para labels visibles cuando sea posible.
Evitar resolver texto visible a String antes de llegar a SwiftUI salvo cuando sea necesario para share/dinamicos.
Los fallbacks de detalle y razones de sugerencia deben tener traducciones completas en es/en.
```

## Persistencia Local

V1 inicial guarda ideas en `UserDefaults`.

Key:

```txt
ideas:v1
```

Responsabilidades de `IdeaStore`:

```txt
load ideas
persist ideas
add idea
update idea
update status
delete idea
expire past ideas on load
```

Reglas:

```txt
No borrar automaticamente por expiracion.
Descartar ideas expiradas con reason expired si aplica.
No perder datos si falla una clasificacion o enriquecimiento.
No migrar ni borrar datos locales sin confirmacion cuando exista backend.
```

## Clasificacion Local

`IdeaClassifier` puede usar reglas simples por keywords para sugerir:

```txt
title
category
idealConditions
```

La clasificacion es una ayuda inicial, no una decision definitiva. El usuario debe poder cambiar los campos.

La clasificacion actual usa keywords en espanol e ingles con scoring determinista. No debe depender solo del idioma del sistema y no debe bloquear la creacion si no puede clasificar con confianza.

## Scoring Local

`IdeaScoring` debe retornar hasta 5 sugerencias.

Reglas base:

```txt
Excluir done.
Excluir discarded.
Permitir repeatable solo si pasaron 15 dias desde completedAt/lastRepeatedAt.
Priorizar ideas con fecha que encajan con el momento seleccionado.
Priorizar eventos proximos.
Priorizar pendientes antiguas.
Agregar razones legibles.
Ordenar deterministicamente por score y fecha de creacion.
```

Las razones internas se modelan como `SuggestionReason` para separar logica de presentacion. La UI y el texto compartido localizan esas razones segun el locale activo.

## Expiracion

`IdeaExpiration` puede marcar como descartadas ideas con fecha pasada, pero no debe borrarlas.

La razon interna debe distinguir:

```txt
manual
expired
```

## Testing

Priorizar tests unitarios sobre reglas de producto:

```txt
normalizacion de link
creacion local de idea
clasificacion basica
scoring excluye done/discarded
repeatable requiere 15 dias
expiracion marca discarded sin borrar
```

Cobertura unitaria actual en `openkoudiosTests/openkoudiosTests.swift`:

```txt
clasificacion basica e insensible a acentos
normalizacion de links
scoring excluye done/discarded
repeatable requiere cooldown de 15 dias
maximo 5 sugerencias
fecha especifica aplica solo al dia seleccionado
expiracion descarta sin borrar
IdeaStore persiste y recarga con UserDefaults aislado
IdeaStore marca descartes manuales
```

Snapshot tests actuales:

```txt
Dispositivo estandar: iPhone 17 (402x874pt)
Locales: es y en
Temas: Light y Dark
Referencias: openkoudiosTests/Snapshots/*_{es,en}_{Light,Dark}.png
Vistas cubiertas: VamosView, IdeasListView, SaveIdeaView, IdeaDetailView, AccountView
```

`AppRootView` no se usa como referencia estable de snapshot porque puede depender del estado real/persistido de la app y del contenedor de simulador. Las vistas principales se prueban directamente con stores aislados y datos deterministas.

UI tests deben cubrir flujos criticos:

```txt
abrir app
guardar primera idea
ver idea en Ideas
abrir detalle
```

## Comandos

Abrir en Xcode:

```bash
open openkoudios.xcodeproj
```

Listar schemes/targets:

```bash
xcodebuild -list -project openkoudios.xcodeproj
```

Build:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' build
```

Tests:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' test
```

Solo unit tests:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:openkoudiosTests test
```

Solo UI tests:

```bash
xcodebuild -project openkoudios.xcodeproj -scheme openkoudios -destination 'platform=iOS Simulator,name=<installed simulator>' -only-testing:openkoudiosUITests test
```

Si `xcodebuild` usa CommandLineTools, seleccionar Xcode completo:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

## Current Verification State

`xcodebuild -list` works in the current environment with Xcode at:

```txt
/Applications/Xcode-26.4.1.app/Contents/Developer
```

Recent local verification has passed for CLI build, unit tests, and bilingual snapshot tests. The snapshot suite records missing references and then passes once the generated references are reviewed.

The Simulator has intermittently failed in this environment with:

```txt
NSMachErrorDomain Code=-308 "(ipc/mig) server died"
Failed to launch app with identifier: matom.openkoudios
```

This appears to be a Simulator launch/runtime issue rather than a documented product logic failure. `git diff --check` passes.
When it appears, rerun after the simulator recovers before treating it as a product regression.
