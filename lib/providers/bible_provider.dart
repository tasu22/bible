import 'package:flutter/foundation.dart';
import '../models/strong_bible_services.dart';
import '../models/swahili_bible_service.dart';

class BibleProvider with ChangeNotifier {
  List<String> _books = [];
  // Initialize to true to avoid initial "No books found" flicker before loadBooks is called
  bool _isLoading = true;
  String? _error;

  List<String> get books => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBooks(bool isSwahili) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (isSwahili) {
        _books = await SwahiliBibleService.getBookNames();
      } else {
        _books = await StrongBibleService.getBookNames();
      }
    } catch (e) {
      // In production, you might want to log this error to a service
      _error = 'Failed to load books: ${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
