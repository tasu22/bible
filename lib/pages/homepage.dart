import 'package:bible/models/strong_bible_services.dart';
import 'package:flutter/material.dart';
import 'package:bible/widgets/custom_outlined_button.dart';
import 'package:bible/pages/book_page.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bible/providers/language_provider.dart';

import '../models/swahili_bible_service.dart';
import 'settings page'; // <-- Add this import

class _BookListSkeleton extends StatelessWidget {
  final int count;
  const _BookListSkeleton({this.count = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder:
          (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Helper to determine if a book is Old Testament
  bool isOldTestament(String book) {
    const oldTestamentBooks = [
      'Genesis',
      'Exodus',
      'Leviticus',
      'Numbers',
      'Deuteronomy',
      'Joshua',
      'Judges',
      'Ruth',
      '1 Samuel',
      '2 Samuel',
      '1 Kings',
      '2 Kings',
      '1 Chronicles',
      '2 Chronicles',
      'Ezra',
      'Nehemiah',
      'Esther',
      'Job',
      'Psalms',
      'Proverbs',
      'Ecclesiastes',
      'Song of Solomon',
      'Isaiah',
      'Jeremiah',
      'Lamentations',
      'Ezekiel',
      'Daniel',
      'Hosea',
      'Joel',
      'Amos',
      'Obadiah',
      'Jonah',
      'Micah',
      'Nahum',
      'Habakkuk',
      'Zephaniah',
      'Haggai',
      'Zechariah',
      'Malachi',
    ];
    return oldTestamentBooks.contains(book);
  }

  // Helper to get books in canonical order
  List<String> _orderBooks(List<String> books, List<String> canonicalOrder) {
    return canonicalOrder.where((b) => books.contains(b)).toList();
  }

  Widget _buildBookList(
    String title,
    List<String> books, {
    bool loading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            title,
            style: TextStyle(
              color: Color(0xFFFAF5EE),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child:
              loading
                  ? _BookListSkeleton(count: 10)
                  : ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: CustomOutlinedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        BookPage(bookName: books[index]),
                              ),
                            );
                          },
                          borderColor: Color(0xFFFAF5EE),
                          child: Text(
                            books[index],
                            style: TextStyle(color: Color(0xFFFAF5EE)),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSwahili = languageProvider.isSwahili;
    final future =
        isSwahili
            ? SwahiliBibleService.getBookNames()
            : StrongBibleService.getBookNames();

    // English canonical order
    const oldTestamentOrderEn = [
      'Genesis',
      'Exodus',
      'Leviticus',
      'Numbers',
      'Deuteronomy',
      'Joshua',
      'Judges',
      'Ruth',
      '1 Samuel',
      '2 Samuel',
      '1 Kings',
      '2 Kings',
      '1 Chronicles',
      '2 Chronicles',
      'Ezra',
      'Nehemiah',
      'Esther',
      'Job',
      'Psalms',
      'Proverbs',
      'Ecclesiastes',
      'Song of Solomon',
      'Isaiah',
      'Jeremiah',
      'Lamentations',
      'Ezekiel',
      'Daniel',
      'Hosea',
      'Joel',
      'Amos',
      'Obadiah',
      'Jonah',
      'Micah',
      'Nahum',
      'Habakkuk',
      'Zephaniah',
      'Haggai',
      'Zechariah',
      'Malachi',
    ];
    const newTestamentOrderEn = [
      'Matthew',
      'Mark',
      'Luke',
      'John',
      'Acts',
      'Romans',
      '1 Corinthians',
      '2 Corinthians',
      'Galatians',
      'Ephesians',
      'Philippians',
      'Colossians',
      '1 Thessalonians',
      '2 Thessalonians',
      '1 Timothy',
      '2 Timothy',
      'Titus',
      'Philemon',
      'Hebrews',
      'James',
      '1 Peter',
      '2 Peter',
      '1 John',
      '2 John',
      '3 John',
      'Jude',
      'Revelation',
    ];

    // Swahili canonical order
    const oldTestamentOrderSw = [
      'Mwanzo',
      'Kutoka',
      'Mambo ya Walawi',
      'Hesabu',
      'Kumbukumbu la Torati',
      'Yoshua',
      'Waamuzi',
      'Ruthu',
      '1 Samueli',
      '2 Samueli',
      '1 Wafalme',
      '2 Wafalme',
      '1 Mambo ya Nyakati',
      '2 Mambo ya Nyakati',
      'Ezra',
      'Nehemia',
      'Esta',
      'Ayubu',
      'Zaburi',
      'Mithali',
      'Mhubiri',
      'Wimbo Ulio Bora',
      'Isaya',
      'Yeremia',
      'Maombolezo',
      'Ezekieli',
      'Danieli',
      'Hosea',
      'Yoeli',
      'Amosi',
      'Obadia',
      'Yona',
      'Mika',
      'Nahumu',
      'Habakuki',
      'Sefania',
      'Hagai',
      'Zekaria',
      'Malaki',
    ];
    const newTestamentOrderSw = [
      'Mathayo',
      'Marko',
      'Luka',
      'Yohana',
      'Matendo ya Mitume',
      'Warumi',
      '1 Wakorintho',
      '2 Wakorintho',
      'Wagalatia',
      'Waefeso',
      'Wafilipi',
      'Wakolosai',
      '1 Wathesalonike',
      '2 Wathesalonike',
      '1 Timotheo',
      '2 Timotheo',
      'Tito',
      'Filemoni',
      'Waebrania',
      'Yakobo',
      '1 Petro',
      '2 Petro',
      '1 Yohana',
      '2 Yohana',
      '3 Yohana',
      'Yuda',
      'Ufunuo wa Yohana',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1D503A),
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isSwahili ? 'B I B L I A' : 'B I B L E',
            style: TextStyle(fontSize: 30),
          ),
        ),
        backgroundColor: const Color(0xFF1D503A),
        foregroundColor: const Color(0xFFFAF5EE),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Color(0xFFFAF5EE),
              size: 34,
            ), // Increased size
            onPressed: () {
              HapticFeedback.mediumImpact(); // Add haptic feedback
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                style: TextStyle(color: Color(0xFFFAF5EE)), // <-- Add this line
                decoration: InputDecoration(
                  hintText: isSwahili ? 'T A F U T A' : 'S E A R C H',
                  hintStyle: TextStyle(color: const Color(0xFFFAF5EE)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFFFAF5EE),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1D503A),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: const Color(0xFFFAF5EE),
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: const Color(0xFFFAF5EE),
                      width: 2.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
            FutureBuilder<List<String>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBookList(
                            isSwahili
                                ? 'A G A N O  L A  K A L E'
                                : 'O L D  T E S T A M E N T',
                            [],
                            loading: true,
                          ),
                        ),
                        VerticalDivider(
                          color: const Color(0xFFFAF5EE),
                          thickness: 1.5,
                          width: 32,
                          indent: 16,
                          endIndent: 16,
                        ),
                        Expanded(
                          child: _buildBookList(
                            isSwahili
                                ? 'A G A N O  J I P Y A'
                                : 'N E W  T E S T A M E N T',
                            [],
                            loading: true,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        isSwahili
                            ? 'Kosa la kupakua vitabu'
                            : 'Error loading books',
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        isSwahili
                            ? 'Hakuna vitabu vilivyopatikana'
                            : 'No books found',
                      ),
                    ),
                  );
                }

                final allBooks = snapshot.data!;
                final oldTestamentOrder =
                    isSwahili ? oldTestamentOrderSw : oldTestamentOrderEn;
                final newTestamentOrder =
                    isSwahili ? newTestamentOrderSw : newTestamentOrderEn;

                // Filter books by search query
                List<String> filteredBooks = allBooks;
                if (_searchQuery.isNotEmpty) {
                  filteredBooks =
                      allBooks
                          .where((b) => b.toLowerCase().contains(_searchQuery))
                          .toList();
                }

                final oldTestamentBooks = _orderBooks(
                  filteredBooks
                      .where((b) => oldTestamentOrder.contains(b))
                      .toList(),
                  oldTestamentOrder,
                );
                final newTestamentBooks = _orderBooks(
                  filteredBooks
                      .where((b) => newTestamentOrder.contains(b))
                      .toList(),
                  newTestamentOrder,
                );

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildBookList(
                          isSwahili
                              ? 'A G A N O  L A  K A L E'
                              : 'O L D  T E S T A M E N T',
                          oldTestamentBooks,
                        ),
                      ),
                      VerticalDivider(
                        color: const Color(0xFFFAF5EE),
                        thickness: 1.5,
                        width: 32,
                        indent: 16,
                        endIndent: 16,
                      ),
                      Expanded(
                        child: _buildBookList(
                          isSwahili
                              ? 'A G A N O  J I P Y A'
                              : 'N E W  T E S T A M E N T',
                          newTestamentBooks,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
