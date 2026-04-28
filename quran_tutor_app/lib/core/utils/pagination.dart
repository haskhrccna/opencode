import 'dart:async';

import 'package:quran_tutor_app/core/constants/app_constants.dart';

/// Pagination state for infinite scroll
class PaginationState<T> {

  const PaginationState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.cursor,
    this.currentPage = 0,
    this.error,
  });
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final String? cursor;
  final int currentPage;
  final Failure? error;

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    String? cursor,
    int? currentPage,
    Failure? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}

/// Generic failure class for pagination
class Failure {

  const Failure({
    required this.message,
    this.code,
  });
  final String message;
  final String? code;
}

/// Pagination configuration
class PaginationConfig {

  const PaginationConfig({
    this.pageSize = AppConstants.defaultPageSize,
    this.maxPageSize = AppConstants.maxPageSize,
    this.initialPage = 0,
  });
  final int pageSize;
  final int maxPageSize;
  final int initialPage;

  /// Validate and clamp page size
  int get clampedPageSize =>
      pageSize.clamp(1, maxPageSize);
}

/// Cursor-based pagination helper
class CursorPagination<T> {

  CursorPagination({
    required this.config,
    required this.fetchPage,
  });
  final PaginationConfig config;
  final Future<PaginatedResult<T>> Function({
    required int limit,
    String? cursor,
  }) fetchPage;

  PaginationState<T> _state = PaginationState<T>();
  bool _isFetching = false;

  /// Current state
  PaginationState<T> get state => _state;

  /// Stream of state changes
  final _stateController = StreamController<PaginationState<T>>.broadcast();
  Stream<PaginationState<T>> get stateStream => _stateController.stream;

  /// Load initial page
  Future<void> loadInitial() async {
    if (_isFetching) return;
    _isFetching = true;

    _state = _state.copyWith(
      isLoading: true,
      error: null,
    );
    _stateController.add(_state);

    try {
      final result = await fetchPage(
        limit: config.clampedPageSize,
        cursor: null,
      );

      _state = PaginationState<T>(
        items: result.items,
        hasMore: result.hasMore,
        cursor: result.cursor,
        currentPage: 1,
      );
      _stateController.add(_state);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: Failure(message: e.toString()),
      );
      _stateController.add(_state);
    } finally {
      _isFetching = false;
    }
  }

  /// Load next page
  Future<void> loadNext() async {
    if (_isFetching || !_state.hasMore || _state.cursor == null) return;
    _isFetching = true;

    _state = _state.copyWith(isLoading: true);
    _stateController.add(_state);

    try {
      final result = await fetchPage(
        limit: config.clampedPageSize,
        cursor: _state.cursor,
      );

      _state = _state.copyWith(
        items: [..._state.items, ...result.items],
        isLoading: false,
        hasMore: result.hasMore,
        cursor: result.cursor,
        currentPage: _state.currentPage + 1,
      );
      _stateController.add(_state);
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: Failure(message: e.toString()),
      );
      _stateController.add(_state);
    } finally {
      _isFetching = false;
    }
  }

  /// Refresh (reload from first page)
  Future<void> refresh() async {
    _state = PaginationState<T>();
    await loadInitial();
  }

  /// Dispose resources
  void dispose() {
    _stateController.close();
  }
}

/// Result of a paginated query
class PaginatedResult<T> {

  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.cursor,
    this.totalCount = 0,
  });
  final List<T> items;
  final bool hasMore;
  final String? cursor;
  final int totalCount;
}
