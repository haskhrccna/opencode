import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Custom BLoC observer for debugging
class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.i('🟢 BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('📤 Event: ${event.runtimeType} in ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.d('🔄 State Change: ${bloc.runtimeType}\n'
        '  Current: ${change.currentState.runtimeType}\n'
        '  Next: ${change.nextState.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.t('➡️ Transition: ${bloc.runtimeType}\n'
        '  Event: ${transition.event.runtimeType}\n'
        '  Current: ${transition.currentState.runtimeType}\n'
        '  Next: ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e('🔴 Error in ${bloc.runtimeType}',
        error: error, stackTrace: stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.i('🔴 BLoC Closed: ${bloc.runtimeType}');
  }
}
