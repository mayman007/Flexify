<div align = "center">
<img src = "https://i.imgur.com/zUDmmyy.png" width = 200>

# **Flexify - Wallpapers & Widgets**

<a href='https://play.google.com/store/apps/details?id=com.maymanxineffable.flexify'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' height="80"/></a>

</div>

## Why Flexify?

Flexify is more than just a personalization app; it’s your gateway to making your phone reflect *you*. Whether you prefer minimalism, vibrant colors, or intricate designs, Flexify has you covered.

## Features

- 🖼️ More than 600 4K wallpapers
- 📱 100+ customized KWGT widgets and KLWP live wallpapers
- 📋 All the content categorized to make it easy to navigate
- 💾 Save any wallpaper you want with high quality
- 💙 Add wallpapers or widgets you like to favorites
- 🎨 Fluid animations and beautiful UI design following Material Design 3
- 🌍 Multi-language support (English, Arabic)

## Getting Started

### Download the App

Download Flexify directly from [Google Play Store](https://play.google.com/store/apps/details?id=com.maymanxineffable.flexify).

### Requirements

- Android 5.0 or later.
- KWGT and KLWP apps installed (for widgets and depth wallpapers).

## Community

Join our growing community on Telegram to share your setups, get inspiration, and stay updated with the latest releases:  
[Flexify Telegram Channel](https://t.me/Flexify_updates)  

# Screenshots

| ![Image 1](https://i.imgur.com/BoaWX10.jpeg) | ![Image 2](https://i.imgur.com/0DSRMiB.jpeg) | ![Image 3](https://i.imgur.com/A5PTTOe.jpeg) |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| ![Image 4](https://i.imgur.com/qvc0og8.jpeg) | ![Image 5](https://i.imgur.com/7K5Ok3U.jpeg) | ![Image 6](https://i.imgur.com/tdXNoad.jpeg) |

## Running from Source Code

### Prerequisites

- Flutter SDK (3.32 recommended)
- Android Studio or VS Code with Flutter extensions
- Firebase account
- Git

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/mayman007/flexify.git
   cd flexify
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firebase Analytics and Crashlytics
   - Download `google-services.json` and place it in `android/app/`
   - Add your app's package name: `com.maymanxineffable.flexify`

4. **API Configuration**
   - Setup [Flexify API](https://github.com/mayman007/flexify-api) to fetch content
   - Add the API endpoints to Firebase remote configs
   - The API provides wallpapers, widgets, and depth wallpapers data

5. **Build and Run**
   ```bash
   # For debug build
   flutter run
   
   # For release build
   flutter build apk --release
   ```

### Project Structure

- `lib/src/provider/` - API integration and data providers
- `lib/src/views/` - App screens and UI
- `lib/src/widgets/` - Custom widgets and components
- `assets/translations/` - Localization files
- `android/` - Android-specific configuration

## Contributing

We welcome contributions to make Flexify even better! Here are the ways you can help:

### 🌍 Translation Contributions

Help us make Flexify accessible to more people by adding your language or improving existing translations.

#### Adding a New Language

1. **Fork the repository** and clone it to your local machine
2. **Navigate to the translations folder**: `assets/translations/`
3. **Create a new JSON file** for your language using the ISO 639-1 language code (e.g., `fr.json` for French, `es.json` for Spanish)
4. **Copy the structure** from `en.json` and translate all the values to your language
5. **Update the main.dart file** to include your language:
   ```dart
   supportedLocales: [Locale('en'), Locale('ar'), Locale('your_language_code')],
   ```
6. **Test your translation** by running the app and switching to your language
7. **Submit a pull request** with your translation

#### Improving Existing Translations

1. **Fork the repository** and clone it to your local machine
2. **Navigate to the translations folder**: `assets/translations/`
3. **Edit the appropriate JSON file** (e.g., `ar.json` for Arabic improvements)
4. **Make your improvements** while keeping the JSON structure intact
5. **Test your changes** by running the app
6. **Submit a pull request** with your improvements

#### Translation Guidelines

- Keep translations **concise and natural** in your language
- Maintain the **same tone** as the English version (friendly and professional)
- Test translations in the app to ensure they **fit the UI properly**
- For technical terms (like "KWGT", "KLWP"), keep them as-is unless there's a widely accepted translation
- Use **gender-neutral language** where possible
- Follow your language's **capitalization conventions**

#### Translation File Structure

Each translation file contains these main sections:
- `navigation` - Bottom navigation labels
- `wallpapers` - Wallpaper-related strings
- `wallpaperDetails` - Wallpaper details screen
- `widgetDetails` - Widget details screen
- `widgets` - Widget-related strings
- `depthWalls` - Depth wallpaper strings
- `favorites` - Favorites screen
- `settings` - Settings screen
- `aboutUs` - About us screen
- `common` - Common strings used throughout the app

#### Need Help?

If you have questions about translating or need clarification on any strings:
- **Join our [Telegram Discussion Group](https://t.me/Flexify_discussion)**
- **Open an [Issue](https://github.com/mayman007/Flexify/issues)** with the "translation" label

## Support

Have questions, feedback, or issues? We’d love to hear from you! Contact us at:

- **Open an [Issue](https://github.com/mayman007/Flexify/issues)**
- **Join [Telegram Discussion Group](https://t.me/Flexify_discussion)**

---

**Polish your phone. Elevate your style. Download Flexify today!**
