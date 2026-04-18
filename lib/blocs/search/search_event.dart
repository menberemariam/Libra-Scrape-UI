// lib/blocs/search/search_event.dart
part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchItems extends SearchEvent {
  final SearchFilters filters;

  const SearchItems(this.filters);

  @override
  List<Object> get props => [filters];
}

class LoadMoreSearchResults extends SearchEvent {}

class ClearSearch extends SearchEvent {}

class UpdateFilters extends SearchEvent {
  final SearchFilters filters;

  const UpdateFilters(this.filters);

  @override
  List<Object> get props => [filters];
}