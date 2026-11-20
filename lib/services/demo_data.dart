import '../models/item_model.dart';
import '../models/pagination_response.dart';
import '../models/search_filters.dart';

/// A small, curated catalogue used when the Libra API is not running.
///
/// This keeps the product fully explorable for demos, design reviews and
/// screenshots without a backend. Real API responses always take priority.
class DemoCatalog {
  DemoCatalog._();

  static final DateTime _now = DateTime.now();

  static final List<ItemModel> _items = [
    ItemModel(
      id: 'demo-1',
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      description:
          'Elizabeth Bennet and the proud Mr. Darcy navigate manners, money '
          'and misunderstanding in one of the most beloved novels in the '
          'English language. A sharp, witty portrait of Regency society that '
          'still feels startlingly modern.',
      genres: const ['Classic Literature', 'Romance'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/jane-austen/pride-and-prejudice',
      createdAt: _now.subtract(const Duration(days: 2)),
    ),
    ItemModel(
      id: 'demo-2',
      title: 'Meditations',
      author: 'Marcus Aurelius',
      description:
          'Private notes from a Roman emperor on duty, grief, discipline and '
          'the art of staying calm. A timeless handbook for anyone trying to '
          'live with intention.',
      genres: const ['Philosophy', 'Biography'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/marcus-aurelius/meditations',
      createdAt: _now.subtract(const Duration(days: 4)),
    ),
    ItemModel(
      id: 'demo-3',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      description:
          'Jay Gatsby throws lavish parties on Long Island in pursuit of a '
          'single green light. A glittering, melancholy classic about longing '
          'and the fragility of the American dream.',
      genres: const ['Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/f-scott-fitzgerald/the-great-gatsby',
      createdAt: _now.subtract(const Duration(days: 6)),
    ),
    ItemModel(
      id: 'demo-4',
      title: 'Frankenstein',
      author: 'Mary Shelley',
      description:
          'A young scientist assembles a living creature and then abandons it '
          'to the world. The original science-fiction novel, and still one of '
          'its most humane.',
      genres: const ['Science Fiction', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/mary-shelley/frankenstein',
      createdAt: _now.subtract(const Duration(days: 8)),
    ),
    ItemModel(
      id: 'demo-5',
      title: 'Sherlock Holmes: The Adventures',
      author: 'Arthur Conan Doyle',
      description:
          'Twelve cases from 221B Baker Street, narrated by Dr. Watson. The '
          'blueprint for every detective story that followed.',
      genres: const ['Mystery', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.audiobook,
      source: ItemSource.librivox,
      sourceUrl: 'https://librivox.org/the-adventures-of-sherlock-holmes-by-arthur-conan-doyle/',
      createdAt: _now.subtract(const Duration(days: 9)),
    ),
    ItemModel(
      id: 'demo-6',
      title: 'Dracula',
      author: 'Bram Stoker',
      description:
          'Letters, journals and newspaper cuttings build a slow-burning '
          'horror that defined the vampire myth. Gothic atmosphere at its '
          'most convincing.',
      genres: const ['Mystery', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/bram-stoker/dracula',
      createdAt: _now.subtract(const Duration(days: 11)),
    ),
    ItemModel(
      id: 'demo-7',
      title: 'The Time Machine',
      author: 'H. G. Wells',
      description:
          'An inventor travels to the year 802,701 and finds humanity split in '
          'two. A compact, unsettling speculation on class and progress.',
      genres: const ['Science Fiction'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.audiobook,
      source: ItemSource.librivox,
      sourceUrl: 'https://librivox.org/the-time-machine-by-h-g-wells/',
      createdAt: _now.subtract(const Duration(days: 13)),
    ),
    ItemModel(
      id: 'demo-8',
      title: 'Jane Eyre',
      author: 'Charlotte Brontë',
      description:
          'An orphan grows into a governess with a fierce sense of self. Part '
          'romance, part reckoning with power, entirely unforgettable.',
      genres: const ['Romance', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/charlotte-bronte/jane-eyre',
      createdAt: _now.subtract(const Duration(days: 15)),
    ),
    ItemModel(
      id: 'demo-9',
      title: 'Moby-Dick',
      author: 'Herman Melville',
      description:
          'Captain Ahab hunts the white whale across the oceans while Ishmael '
          'tries to make sense of the world. An epic of obsession, told in '
          'prose that swings between philosophy and salt spray.',
      genres: const ['Classic Literature', 'History'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/herman-melville/moby-dick',
      createdAt: _now.subtract(const Duration(days: 18)),
    ),
    ItemModel(
      id: 'demo-10',
      title: 'Walden',
      author: 'Henry David Thoreau',
      description:
          'Two years, two months and two days living simply beside a pond. A '
          'quiet argument for attention, sufficiency and deliberate living.',
      genres: const ['Philosophy', 'Biography'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.audiobook,
      source: ItemSource.librivox,
      sourceUrl: 'https://librivox.org/walden-by-henry-david-thoreau/',
      createdAt: _now.subtract(const Duration(days: 21)),
    ),
    ItemModel(
      id: 'demo-11',
      title: 'The Picture of Dorian Gray',
      author: 'Oscar Wilde',
      description:
          'A portrait ages so its subject need not. Wilde turns a faustian '
          'bargain into a glittering study of beauty, vanity and consequence.',
      genres: const ['Classic Literature', 'Fantasy'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/oscar-wilde/the-picture-of-dorian-gray',
      createdAt: _now.subtract(const Duration(days: 24)),
    ),
    ItemModel(
      id: 'demo-12',
      title: 'The Art of War',
      author: 'Sun Tzu',
      description:
          'Thirteen short chapters on strategy, deception and knowing when not '
          'to fight. Read by generals, founders and negotiators alike.',
      genres: const ['History', 'Philosophy'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/sun-tzu/the-art-of-war',
      createdAt: _now.subtract(const Duration(days: 27)),
    ),
    ItemModel(
      id: 'demo-13',
      title: 'Leaves of Grass',
      author: 'Walt Whitman',
      description:
          'A lifelong poem of the body, the republic and the ordinary person. '
          'Whitman’s free verse still sounds like an invitation.',
      genres: const ['Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.audiobook,
      source: ItemSource.librivox,
      sourceUrl: 'https://librivox.org/leaves-of-grass-by-walt-whitman/',
      createdAt: _now.subtract(const Duration(days: 31)),
    ),
    ItemModel(
      id: 'demo-14',
      title: 'The Thirty-Nine Steps',
      author: 'John Buchan',
      description:
          'A man on the run across the Scottish moors with a notebook full of '
          'secrets. The original chase thriller, brisk and endlessly fun.',
      genres: const ['Mystery', 'History'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.audiobook,
      source: ItemSource.librivox,
      sourceUrl: 'https://librivox.org/the-thirty-nine-steps-by-john-buchan/',
      createdAt: _now.subtract(const Duration(days: 35)),
    ),
    ItemModel(
      id: 'demo-15',
      title: 'Wuthering Heights',
      author: 'Emily Brontë',
      description:
          'Heathcliff and Catherine on the Yorkshire moors — a love story that '
          'behaves more like a storm than a romance.',
      genres: const ['Romance', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/emily-bronte/wuthering-heights',
      createdAt: _now.subtract(const Duration(days: 39)),
    ),
    ItemModel(
      id: 'demo-16',
      title: 'A Room with a View',
      author: 'E. M. Forster',
      description:
          'A young woman in Florence begins to question the life mapped out for '
          'her. A warm, funny novel about choosing your own view.',
      genres: const ['Romance', 'Classic Literature'],
      coverUrl: null,
      downloadUrls: const [],
      type: ItemType.book,
      source: ItemSource.standardEbooks,
      sourceUrl: 'https://standardebooks.org/ebooks/e-m-forster/a-room-with-a-view',
      createdAt: _now.subtract(const Duration(days: 43)),
    ),
  ];

  static List<ItemModel> get items => List.unmodifiable(_items);

  static PaginationResponse<ItemModel> page({
    int page = 1,
    int limit = 20,
  }) {
    final offset = (page - 1) * limit;
    final start = offset.clamp(0, _items.length);
    final end = (offset + limit).clamp(0, _items.length);
    final slice = _items.sublist(start, end);

    return PaginationResponse<ItemModel>(
      items: slice,
      total: _items.length,
      limit: limit,
      offset: offset,
      totalPages: (_items.length / limit).ceil(),
    );
  }

  static PaginationResponse<ItemModel> search(SearchFilters filters) {
    final query = filters.query?.trim().toLowerCase() ?? '';
    final genre = filters.genre?.toLowerCase();

    final matches = _items.where((item) {
      final matchesType = filters.type == null || item.type == filters.type;
      final matchesGenre = genre == null ||
          item.genres.any((g) => g.toLowerCase() == genre);
      final matchesAuthor = filters.author == null ||
          item.author.toLowerCase().contains(filters.author!.toLowerCase());
      final matchesQuery = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.author.toLowerCase().contains(query) ||
          item.genres.any((g) => g.toLowerCase().contains(query)) ||
          (item.description?.toLowerCase().contains(query) ?? false);

      return matchesType && matchesGenre && matchesAuthor && matchesQuery;
    }).toList();

    final start = filters.offset.clamp(0, matches.length);
    final end = (filters.offset + filters.limit).clamp(0, matches.length);

    return PaginationResponse<ItemModel>(
      items: matches.sublist(start, end),
      total: matches.length,
      limit: filters.limit,
      offset: filters.offset,
      totalPages: (matches.length / filters.limit).ceil(),
    );
  }

  static ItemModel? findById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<String> formatFor(ItemModel item) {
    if (item.type == ItemType.audiobook) {
      return const ['MP3', 'M4B'];
    }
    return const ['EPUB', 'PDF', 'MOBI'];
  }
}
