import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logging/app_logger.dart';

/// Custom BLoC observer for debugging
/// 
/// IMPORTANT: Verbose logging is automatically stripped in release builds.
/// Only errors are logged in release mode.
class AppBlocObserver extends BlocObserver {
  final AppLogger _logger = AppLogger();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    // Only log in debug mode
    if (kDebugMode) {
      _logger.i('🟢 BLoC Created: ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    // Only log in debug mode - strip verbose BLoC logs in release
    if (kDebugMode) {
      _logger.d('📤 Event: ${event.runtimeType} in ${bloc.runtimeType}');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    // Only log in debug mode - strip verbose BLoC logs in release
    if (kDebugMode) {
      _logger.d('🔄 State Change: ${bloc.runtimeType}\n'
          '  Current: ${change.currentState.runtimeType}\n'
          '  Next: ${change.nextState.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // Only log in debug mode - strip verbose BLoC logs in release
    if (kDebugMode) {
      _logger.v('➡️ Transition: ${bloc.runtimeType}\n'
          '  Event: ${transition.event.runtimeType}\n'
          '  Current: ${transition.currentState.runtimeType}\n'
          '  Next: ${transition.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    // Always log errors, regardless of mode
    _logger.e('🔴 Error in ${bloc.runtimeType}',
        error: error, stackTrace: stackTrace);
    
    // In release mode, this will also be reported to Crashlytics
    // via the AppLogger
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    // Only log in debug mode
    if (kDebugMode) {
      _logger.i('🔴 BLoC Closed: ${bloc.runtimeType}');
    }
  }
}
