
# Flutter POS App

A modern, cross-platform Point of Sale application built with Flutter, Riverpod, and Clean Architecture.

## Features

- **Modern Design**: Material 3 implementation with custom seed color, responsive layout (Mobile/Tablet/Web), and dark mode support.
- **Cross-Platform**: Runs on Android, iOS, and Web.
- **Architecture**: Clean Architecture (Presentation, Domain, Data) with Riverpod for state management.
- **POS Features**:
  - Interactive Dashboard
  - Product Management (Mock)
  - Cart & Checkout System
  - Transaction History
  - Responsive Navigation (Bottom Bar / Rail)

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: standard `flutter_riverpod` (Notifiers)
- **Routing**: `go_router`
- **Networking**: `dio` (ready for integration)
- **Local Storage**: `hive` (for settings/cache)
- **Code Generation**: `freezed`, `json_serializable`

## Getting Started

1.  **Prerequisites**: Ensure you have Flutter installed (`flutter doctor`).
2.  **Dependencies**: Run `flutter pub get`.
3.  **Code Generation**: Run `dart run build_runner build -d` (if you modify freezed/riverpod generated files).
4.  **Run**: `flutter run`

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── src/
│   ├── app.dart               # App Widget
│   ├── core/                  # Core utilities (Theme, Router, Constants)
│   ├── data/                  # Data layer (Repositories, Models, Datasources)
│   ├── domain/                # Domain layer (Entities, UseCases, Repository Interfaces)
│   └── presentation/          # UI layer
│       ├── app_scaffold.dart  # Responsive Navigation Wrapper
│       ├── features/
│       │   ├── auth/          # Login logic
│       │   ├── dashboard/     # Dashboard logic
│       │   ├── transactions/  # POS & Cart logic
│       │   └── ...
```

## Next Steps

- Implement real backend integration with Dio.
- Complete PDF printing logic in `checkout_logic.dart`.
- Enhance Offline Queue mechanism.
