// lib/blocs/search/search_state.dart
part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<ItemModel> items;
  final SearchFilters filters;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final int total;

  const SearchLoaded({
    required this.items,
    required this.filters,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalPages,
    required this.total,
  });

  @override
  List<Object> get props => [items, filters, hasReachedMax, currentPage, totalPages, total];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}