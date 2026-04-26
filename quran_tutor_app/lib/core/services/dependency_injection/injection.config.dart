import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import 'injection.dart';

GetIt $initGetIt(
  GetIt getIt, {
  String? environment,
  EnvironmentFilter? environmentFilter,
}) {
  final gh = GetItHelper(getIt, environment, environmentFilter);
  final supabaseModule = _$SupabaseModule();
gh.singleton<SupabaseClient>(supabaseModule.supabaseClient);
    gh.singleton<SupabaseStorageClient>(supabaseModule.storage);
  gh.factory<AuthBloc>(() => AuthBloc());
  return getIt;
}

class _$SupabaseModule extends SupabaseModule {}
