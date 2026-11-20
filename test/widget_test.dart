// Unit tests for the Libra models and bundled demo catalogue.

import 'package:flutter_test/flutter_test.dart';

import 'package:libra_scrape/models/item_model.dart';
import 'package:libra_scrape/models/search_filters.dart';
import 'package:libra_scrape/services/demo_data.dart';

void main() {
  group('ItemModel', () {
    test('round-trips through JSON', () {
      final createdAt = DateTime.parse('2024-05-01T12:00:00.000Z');
      final item = ItemModel(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        genres: const ['Fiction', 'Test'],
        coverUrl: 'test.jpg',
        downloadUrls: const ['test.epub', 'test.pdf'],
        type: ItemType.book,
        source: ItemSource.standardEbooks,
        sourceUrl: 'https://example.com/1',
        createdAt: createdAt,
      );

      final restored = ItemModel.fromJson(item.toJson());

      expect(restored.id, '1');
      expect(restored.title, 'Test Book');
      expect(restored.author, 'Test Author');
      expect(restored.type, ItemType.book);
      expect(restored.source, ItemSource.standardEbooks);
      expect(restored.genres, ['Fiction', 'Test']);
      expect(restored.downloadUrls.length, 2);
      expect(restored.createdAt, createdAt);
    });

    test('exposes convenience getters', () {
      final audiobook = DemoCatalog.items
          .firstWhere((item) => item.type == ItemType.audiobook);

      expect(audiobook.isAudiobook, isTrue);
      expect(audiobook.typeDisplayName, 'Audiobook');
      expect(audiobook.primaryGenre, isNotEmpty);
    });
  });

  group('ItemSource', () {
    test('maps API values and defaults to Standard Ebooks', () {
      expect(ItemSource.fromApi('librivox'), ItemSource.librivox);
      expect(ItemSource.fromApi('standard_ebooks'), ItemSource.standardEbooks);
      expect(ItemSource.fromApi('unknown'), ItemSource.standardEbooks);
      expect(ItemSource.fromApi(null), ItemSource.standardEbooks);
    });
  });

  group('SearchFilters', () {
    test('builds query params only for active filters', () {
      final filters = SearchFilters(query: 'austen', limit: 10, offset: 20);

      expect(
        filters.toQueryParams(),
        {'q': 'austen', 'limit': '10', 'offset': '20'},
      );
      expect(filters.hasActiveFilters, isTrue);
    });

    test('copyWith can clear a filter', () {
      final filters = SearchFilters(type: ItemType.book).copyWith(clearType: true);

      expect(filters.type, isNull);
      expect(filters.hasActiveFilters, isFalse);
    });
  });

  group('DemoCatalog', () {
    test('paginates items', () {
      final firstPage = DemoCatalog.page(page: 1, limit: 5);

      expect(firstPage.items.length, 5);
      expect(firstPage.total, DemoCatalog.items.length);
      expect(firstPage.hasNextPage, isTrue);
    });

    test('search matches title, author and genre', () {
      final byTitle = DemoCatalog.search(SearchFilters(query: 'meditations'));
      final byAuthor = DemoCatalog.search(SearchFilters(query: 'austen'));
      final byGenre = DemoCatalog.search(SearchFilters(genre: 'Philosophy'));

      expect(byTitle.items.map((i) => i.title), contains('Meditations'));
      expect(byAuthor.items, isNotEmpty);
      expect(byAuthor.items.every((i) => i.author.contains('Austen')), isTrue);
      expect(byGenre.items, isNotEmpty);
      expect(
        byGenre.items.every((i) => i.genres.contains('Philosophy')),
        isTrue,
      );
    });

    test('search respects the type filter and offset', () {
      final audiobooks = DemoCatalog.search(
        SearchFilters(type: ItemType.audiobook, limit: 100),
      );

      expect(audiobooks.items, isNotEmpty);
      expect(
        audiobooks.items.every((i) => i.type == ItemType.audiobook),
        isTrue,
      );

      final offset = DemoCatalog.search(SearchFilters(limit: 3, offset: 3));
      expect(offset.offset, 3);
      expect(offset.items.length, 3);
      expect(
        offset.items.first.id,
        isNot(DemoCatalog.page(limit: 3).items.first.id),
      );
    });

    test('findById returns matching items only', () {
      expect(DemoCatalog.findById('demo-1')?.title, 'Pride and Prejudice');
      expect(DemoCatalog.findById('missing'), isNull);
    });

    test('suggests formats per item type', () {
      final book = DemoCatalog.findById('demo-1')!;
      final audiobook = DemoCatalog.items
          .firstWhere((item) => item.type == ItemType.audiobook);

      expect(DemoCatalog.formatFor(book), contains('EPUB'));
      expect(DemoCatalog.formatFor(audiobook), contains('MP3'));
    });
  });
}
