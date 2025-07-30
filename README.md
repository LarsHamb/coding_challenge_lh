# Calendar Challenge Flutter App

A Flutter calendar application with location-based booking management and multiple view modes.

## Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- iOS Simulator / Android Emulator / Chrome (for web)

### Build & Run
```bash
# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run                    # Default platform
flutter run -d chrome         # Web
flutter run -d ios           # iOS Simulator
flutter run -d android       # Android Emulator

# Run tests
flutter test
```

## Architecture Overview (2-minute read)

### 🏗️ **Clean Architecture Pattern**
```
presentation/ → domain/ → data/
    ↓           ↓        ↓
  Widgets → Repositories → DataSources
```

### 📁 **Project Structure**
- **`lib/feature/calendar_view/`** - Main calendar feature
  - `presentation/` - UI widgets and state management
  - `domain/` - Business logic and repository interfaces  
  - `data/` - Data sources and repository implementations

### 🔄 **State Management**
- **Riverpod** providers for reactive state
- Repository pattern with clean separation
- Mock data sources for development

### 📅 **Calendar Views**
- **List View**: Daily agenda with pull-to-refresh
- **Week View**: 7-day grid with swipe navigation
- Settings screen for view mode switching

### 💾 **Data Layer**
- **Location Repository**: Cached location data (5-min TTL)
- **Booking Repository**: Full CRUD operations, no caching
- Mock data sources with realistic sample data

### 🧪 **Testing**
- Comprehensive widget tests for all views
- Provider overrides for isolated testing
- Mock data for predictable test scenarios

### 🎨 **Key Features**
- Pull-to-refresh on list view
- Week navigation with infinite scroll
- Location-based booking filtering
- Responsive Material Design UI

---

**Tech Stack**: Flutter • Dart • Riverpod • Material Design