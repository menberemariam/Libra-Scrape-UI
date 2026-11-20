// lib/blocs/items/items_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/item_model.dart';
import '../../services/api_service.dart';

part 'items_event.dart';
part 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ApiService _apiService;

  ItemsBloc({required ApiService apiService})
      : _apiService = apiService,
        super(ItemsInitial()) {
    on<LoadItems>(_onLoadItems);
    on<LoadMoreItems>(_onLoadMoreItems);
    on<RefreshItems>(_onRefreshItems);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<ItemsState> emit) async {
    emit(ItemsLoading());
    
    try {
      final response = await _apiService.getItems(
        page: 1,
        limit: event.limit,
      );
      
      emit(ItemsLoaded(
        items: response.items,
        hasReachedMax: !response.hasNextPage,
        currentPage: 1,
        totalPages: response.totalPages,
        total: response.total,
      ));
    } catch (e) {
      emit(ItemsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreItems(LoadMoreItems event, Emitter<ItemsState> emit) async {
    if (state is ItemsLoaded) {
      final currentState = state as ItemsLoaded;
      
      if (currentState.hasReachedMax) return;
      
      try {
        final response = await _apiService.getItems(
          page: currentState.currentPage + 1,
          limit: event.limit,
        );
        
        emit(ItemsLoaded(
          items: [...currentState.items, ...response.items],
          hasReachedMax: !response.hasNextPage,
          currentPage: currentState.currentPage + 1,
          totalPages: response.totalPages,
          total: response.total,
        ));
      } catch (e) {
        emit(ItemsError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshItems(RefreshItems event, Emitter<ItemsState> emit) async {
    try {
      final response = await _apiService.getItems(
        page: 1,
        limit: event.limit,
      );
      
      emit(ItemsLoaded(
        items: response.items,
        hasReachedMax: !response.hasNextPage,
        currentPage: 1,
        totalPages: response.totalPages,
        total: response.total,
      ));
    } catch (e) {
      emit(ItemsError(e.toString()));
    }
  }
}