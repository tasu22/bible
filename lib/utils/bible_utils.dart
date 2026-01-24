class BibleUtils {
  /// Orders a list of books based on a provided canonical order.
  static List<String> orderBooks(
    List<String> books,
    List<String> canonicalOrder,
  ) {
    return canonicalOrder.where((b) => books.contains(b)).toList();
  }
}
