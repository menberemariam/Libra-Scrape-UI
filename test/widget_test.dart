// This is a basic test file for the LibraScrape app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:libra_scrape/main.dart';
import 'package:libra_scrape/core/constants/app_constants.dart';
import 'package:libra_scrape/core/models/book_item.dart';

void main() {
  testWidgets('LibraScrape app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LibraScrapeApp());

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  group('App Constants Tests', () {
    test('App constants should have correct values', () {
      expect(AppConstants.appName, 'LibraScrape');
      expect(AppConstants.defaultPageSize, 20);
      expect(AppConstants.maxPageSize, 100);
    });
  });

  group('Book Model Tests', () {
    test('BookType enum should have correct values', () {
      expect(BookType.book.displayName, 'Book');
      expect(BookType.audiobook.displayName, 'Audiobook');
      expect(BookType.book.defaultSource, 'Standard Ebooks');
      expect(BookType.audiobook.defaultSource, 'LibriVox');
    });

    test('BookItem should be created correctly', () {
      final downloadUrls = [
        DownloadUrl(format: 'epub', url: 'test.epub'),
        DownloadUrl(format: 'pdf', url: 'test.pdf'),
      ];

      final book = BookItem(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        genres: ['Fiction', 'Test'],
        coverUrl: 'test.jpg',
        downloadUrls: downloadUrls,
        type: BookType.book,
        sourceUrl: 'test.com',
        source: 'Test Source',
        scrapedAt: DateTime.now(),
      );

      expect(book.id, '1');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.type, BookType.book);
      expect(book.downloadUrls.length, 2);
    });
  });
}