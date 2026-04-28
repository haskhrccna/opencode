import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:quran_tutor_app/core/services/dependency_injection/injection.config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => $initGetIt(getIt);

/// Supabase Module - provides Supabase client and services
@module
abstract class SupabaseModule {
  /// Get Supabase client instance
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  /// Get GoTrue client (Auth)
  @singleton
  GoTrueClient get auth => Supabase.instance.client.auth;

  /// Get PostgREST client (Database)
  @singleton
  PostgrestClient get database => Supabase.instance.client.rest;

  /// Get Storage client
  @singleton
  SupabaseStorageClient get storage => Supabase.instance.client.storage;

  /// Get Realtime client
  @singleton
  RealtimeClient get realtime => Supabase.instance.client.realtime;
}
