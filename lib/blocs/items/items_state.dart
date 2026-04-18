// lib/blocs/items/items_state.dart
part of 'items_bloc.dart';

abstract class ItemsState extends Equatable {
  const ItemsState();

  @override
  List<Object> get props => [];
}

class ItemsInitial extends ItemsState {}

class ItemsLoading extends ItemsState {}

class ItemsLoaded extends ItemsState {
  final List<ItemModel> items;
  final bool hasReachedMax;
  final int currentPage;
  final int totalPages;
  final int total;

  const ItemsLoaded({
    required this.items,
    required this.hasReachedMax,
    required this.currentPage,
    required this.totalPages,
    required this.total,
  });

  @override
  List<Object> get props => [items, hasReachedMax, currentPage, totalPages, total];
}

class ItemsError extends ItemsState {
  final String message;

  const ItemsError(this.message);

  @override
  List<Object> get props => [message];
}