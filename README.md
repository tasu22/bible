# 📖 Bible Minimalist (EN/SW)

A minimalist, high-performance Flutter application for reading the Bible in **English** and **Swahili**. This project focuses on a clean typography-first approach with zero distractions.

## 🚀 Getting Started

This is a Flutter-based project. To get it running locally:

```bash
# Clone the repository
git clone https://github.com

# Navigate into the project
cd bible

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🛠 Technical Stack

- **Framework:** [Flutter](https://flutter.dev)
- **Language:** Dart
- **Data Format:** Local JSON assets for offline access.
- **State Management:** Provider / Riverpod (optional).

## 📂 Project Structure

```text
lib/
├── main.dart           # App entry point
├── models/             # Bible verse & chapter data models
├── screens/            # Dual-language reader view
└── services/           # JSON parsing & search logic
assets/
└── bibles/
    ├── en.json         # English Translation (KJV/NIV)
    └── sw.json         # Swahili Translation (Union Version)
```

## 📖 Features

- **Side-by-Side View:** Compare English and Swahili verses horizontally.
- **Offline First:** No internet required; scriptures are stored locally in `assets/`.
- **Search Logic:**
  ```dart
  // Example of the search filter logic
  var results = bibleData.where((verse) => 
    verse.text.toLowerCase().contains(query.toLowerCase())
  ).toList();
  ```
- **Dark Mode Support:** Easy on the eyes for night reading.

## 🤝 Contributing

If you want to add more features or translations:

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---
Built with ❤️ for the Word.

