# Warahana - Invoice Generator App

A professional Flutter-based invoice management application for Android devices, designed to streamline invoice creation, catalog management, and PDF generation.

## Features

### 📄 Invoice Management
- Create professional invoices with customer information
- Add multiple line items with description, quantity, and unit price
- Automatic calculation of subtotals, service charges, and final balance
- Advanced payment tracking with advance payment support
- Date selection for invoice creation
- Customer title selection (Mr/Mrs/Ms/Dr/Prof)
- Autocomplete suggestions from saved catalog items

### 📦 Items Catalog
- Save frequently used items with descriptions and unit prices
- Search catalog items (minimum 3 characters)
- Add, edit, and delete catalog entries
- Persistent storage using SharedPreferences
- Real-time filtering and search functionality
- Automatic population of invoice items from catalog

### 📱 PDF Generation
- Generate professional PDF invoices
- Share PDFs via any app (email, messaging, cloud storage)
- Includes company logo and branding
- Formatted with proper layout and calculations

### 🎨 User Interface
- Landscape-only orientation for better usability
- Material Design 3 with light green theme
- Bottom navigation between Invoice and Catalog pages
- Responsive layout for tablet compatibility
- Custom app icon with company logo

## Technologies Used

- **Framework**: Flutter 3.9.2+
- **Language**: Dart
- **State Management**: StatefulWidget with setState
- **Storage**: SharedPreferences (persistent local storage)
- **PDF Generation**: 
  - `pdf: ^3.10.4` - PDF document creation
  - `printing: ^5.11.0` - PDF sharing and printing
- **Date Handling**: `intl: ^0.19.0` - Internationalization and date formatting
- **UI Components**: Material Design 3
- **Icons**: Cupertino Icons, Material Icons

## Project Structure

```
lib/
├── main.dart                          # App entry point with landscape orientation setup
├── models/
│   ├── catalog_item.dart             # Catalog item data model
│   └── invoice_item.dart             # Invoice line item model
├── pages/
│   ├── home_page.dart                # Main navigation with bottom bar
│   ├── invoice_page.dart             # Invoice creation and management
│   └── catalog_page.dart             # Items catalog management
├── services/
│   ├── catalog_storage_service.dart  # Persistent storage and search logic
│   └── pdf_service.dart              # PDF generation and sharing
├── widgets/
│   ├── catalog_autocomplete.dart     # Autocomplete dropdown for catalog items
│   ├── customer_info_section.dart    # Customer details input
│   ├── financial_summary.dart        # Invoice totals and calculations
│   ├── invoice_header.dart           # Company header with logo
│   ├── item_row.dart                 # Individual invoice line item
│   └── items_table.dart              # Invoice items table
└── utils/
    └── formatters.dart               # Currency and number formatting

assets/
└── images/
    └── logo.png                      # Company logo (used as app icon)
```

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd invoice
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Building for Release

### Android APK

Generate a release APK for direct distribution:

```bash
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

You can then share this APK file directly with users. Users need to:
1. Enable "Install from Unknown Sources" on their Android device
2. Download and tap the APK file to install

### Build for specific architecture

For smaller APK size, build for specific CPU architectures:

```bash
# For ARM64 devices (most modern phones)
flutter build apk --release --target-platform android-arm64

# For ARM32 devices
flutter build apk --release --target-platform android-arm

# For x86_64 (emulators)
flutter build apk --release --target-platform android-x64
```

## Usage Guide

### Creating an Invoice

1. Open the app and navigate to the **Invoice** tab
2. Enter customer information (title, name, date)
3. Add invoice items:
   - Type description (autocomplete suggestions from catalog appear after 3 characters)
   - Enter quantity and unit price
   - Add more rows as needed
4. Set service charge percentage (defaults to 0%)
5. Enter advance payment if applicable
6. Review the calculated balance
7. Tap **Share PDF** to generate and share the invoice

### Managing Catalog Items

1. Navigate to the **Catalog** tab
2. Add new items:
   - Enter description
   - Set unit price
   - Tap **Add**
3. Search existing items (type at least 3 characters)
4. Edit or delete items using the action buttons
5. Items are automatically saved and persist across app restarts

### Clearing an Invoice

- Tap the refresh icon (⟳) in the top-right corner of the Invoice page
- Confirm to clear all data and start fresh

## Configuration

### Customizing the App

**Change App Name:**
- Update `android/app/src/main/AndroidManifest.xml` - `android:label`
- Update `ios/Runner/Info.plist` - `CFBundleDisplayName`
- Update `lib/main.dart` - MaterialApp `title` property

**Change App Icon:**
1. Replace `assets/images/logo.png` with your logo
2. Run: `dart run flutter_launcher_icons`

**Change Theme Color:**
- Edit `lib/main.dart` - `ColorScheme.fromSeed(seedColor: Colors.lightGreen)`

**Orientation:**
- The app is locked to landscape mode in `lib/main.dart` and native configurations

## Data Persistence

- **Catalog items** are stored locally using SharedPreferences
- Data persists across app restarts
- No internet connection required
- Data is stored in JSON format
- Items are automatically saved on add, edit, or delete

## Known Limitations

- Android only (iOS implementation exists but untested)
- Landscape orientation only
- Local storage only (no cloud sync)
- PDF sharing requires compatible apps on the device

## Future Enhancements

- Cloud backup and sync
- Multiple invoice templates
- Customer database
- Invoice history and search
- Export to Excel/CSV
- Email integration
- Tax calculations
- Multi-currency support

## Development

### Hot Reload

While developing, use hot reload for instant updates:
```bash
flutter run
```
Press `r` in the terminal for hot reload, or `R` for hot restart.

### Debug Mode

Run in debug mode with DevTools:
```bash
flutter run --debug
```

### Format Code

```bash
flutter format lib/
```

### Analyze Code

```bash
flutter analyze
```

## Troubleshooting

**Build fails:**
- Run `flutter clean` then `flutter pub get`
- Check Flutter version: `flutter --version`

**App crashes on startup:**
- Check device/emulator compatibility
- Review console logs for specific errors

**Catalog items not saving:**
- Check device storage permissions
- Verify SharedPreferences implementation

## License

This project is proprietary software.

## Support

For support or questions, please contact the development team.

---

**Version:** 1.0.0+1  
**Last Updated:** January 2026
