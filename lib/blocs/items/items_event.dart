// lib/blocs/items/items_event.dart
part of 'items_bloc.dart';

abstract class ItemsEvent extends Equatable {
  const ItemsEvent();

  @override
  List<Object> get props => [];
}

class LoadItems extends ItemsEvent {
  final int limit;

  const LoadItems({this.limit = 20});

  @override
  List<Object> get props => [limit];
}

class LoadMoreItems extends ItemsEvent {
  final int limit;

  const LoadMoreItems({this.limit = 20});

  @override
  List<Object> get props => [limit];
}

class RefreshItems extends ItemsEvent {
  final int limit;

  const RefreshItems({this.limit = 20});

  @override
  List<Object> get props => [limit];
}