// lib/blocs/search/search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/item_model.dart';
import '../../models/search_filters.dart';
import '../../services/api_service.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService _apiService;

  SearchBloc({required ApiService apiService})
      : _apiService = apiService,
        super(SearchInitial()) {
    on<SearchItems>(_onSearchItems);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<ClearSearch>(_onClearSearch);
    on<UpdateFilters>(_onUpdateFilters);
  }

  Future<void> _onSearchItems(SearchItems event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    
    try {
      final response = await _apiService.searchItems(event.filters);
      
      emit(SearchLoaded(
        items: response.items,
        filters: event.filters,
        hasReachedMax: !response.hasNextPage,
        currentPage: 1,
        totalPages: response.totalPages,
        total: response.total,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onLoadMoreSearchResults(
      LoadMoreSearchResults event, Emitter<SearchState> emit) async {
    if (state is SearchLoaded) {
      final currentState = state as SearchLoaded;
      
      if (currentState.hasReachedMax) return;
      
      try {
        final newFilters = currentState.filters.copyWith(
          offset: currentState.currentPage * currentState.filters.limit,
        );
        
        final response = await _apiService.searchItems(newFilters);
        
        emit(SearchLoaded(
          items: [...currentState.items, ...response.items],
          filters: currentState.filters,
          hasReachedMax: !response.hasNextPage,
          currentPage: currentState.currentPage + 1,
          totalPages: response.totalPages,
          total: response.total,
        ));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }

  Future<void> _onUpdateFilters(UpdateFilters event, Emitter<SearchState> emit) async {
    if (event.filters.hasActiveFilters) {
      add(SearchItems(event.filters));
    } else {
      emit(SearchInitial());
    }
  }
}