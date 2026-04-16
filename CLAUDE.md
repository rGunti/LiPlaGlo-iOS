# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**License Plate Glossary (LiPlaGlo)** is an iOS app providing a database of international vehicle license plate information (plate variants, regional identifiers, vanity plate regulations). All data is bundled as a read-only SQLite file (`liplaglo.db`).

## Build & Test Commands

This project uses native Xcode tooling — no Makefile or fastlane.

```bash
# Build for testing (iOS Simulator)
xcodebuild build-for-testing \
  -scheme LicensePlateGlossary \
  -project LicensePlateGlossary.xcodeproj \
  -destination "platform=iOS Simulator,name=iPhone 16"

# Run tests
xcodebuild test \
  -scheme LicensePlateGlossary \
  -project LicensePlateGlossary.xcodeproj \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

CI runs on macOS 15 via `.github/workflows/ios.yml`.

## Architecture

**SwiftUI app with direct database access — no ViewModel layer.**

- Views call `DbManager.instance` (singleton) directly for all data
- No reactive bindings, no async/await — SQLite access is synchronous on the main thread
- Navigation: `TabView` at root (Search / Countries / Settings), `NavigationStack` + `NavigationLink` for drill-down

### Data Layer (`LicensePlateGlossary/Data/`)

- **`DbManager.swift`** — Singleton managing a read-only SQLite connection to the bundled `liplaglo.db`. All query methods live here (`getCountries()`, `getPlateVariantsForCountry()`, `getIdentifiers()`, `getTranslatedString()`, etc.).
- **`Entities.swift`** — All data models (`Country`, `PlateVariant`, `PlateIdentifier`, `PlateIdentifierType`, `I18nEntry`, etc.) with SQLite.swift type-safe column expressions. Each model has a `fromRow()` factory. Column constants use a `col` prefix (e.g., `colCountryId`). Table/view helpers are in `DbTables` and `DbViews` static classes.

### Internationalization (`LicensePlateGlossary/I18n/`)

Translations are stored in the SQLite database, not in `.strings` files.

- **`I18nUtils.swift`** — `getTranslatedString(key:)` and `getTranslatedStringWithFormatting(key:)`. Falls back to English (`"en"`). Strings prefixed with `raw:` bypass lookup and render as-is (supporting Markdown).
- **`TranslatedText.swift`** — SwiftUI component wrapping translated string lookups; use this for all user-facing text instead of `Text` directly.

The `Localizable.xcstrings` catalog is for Xcode/system strings only, not app content translations.

### UI Conventions

- **`LicensePlatePreview.swift`** — Renders visual license plate previews using custom bundled fonts (Swiss: `SwissLicensePlates.otf`, German/Liechtenstein: `GL-Nummernschild-*.ttf`; default: `"HelveticaNeue-CondensedBold"`).
- **`KeyValueRow.swift`** — Reusable key/value list row component.
- Geographic identifier views open Apple Maps via URL scheme (`maps://`).

### Debug Features

Files in `LicensePlateGlossary/Debug/` are only compiled in `DEBUG` builds. They provide a translation completeness dashboard and can generate SQL `INSERT` statements for missing translations.
