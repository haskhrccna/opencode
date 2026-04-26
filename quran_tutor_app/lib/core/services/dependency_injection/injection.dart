import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => $initGetIt(getIt);

// External Modules
@module
abstract class SupabaseModule {
  @singleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @singleton
  SupabaseStorageClient get supabaseStorage => Supabase.instance.client.storage;
}
