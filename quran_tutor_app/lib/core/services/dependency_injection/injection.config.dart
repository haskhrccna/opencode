// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:supabase_flutter/supabase_flutter.dart' as _i3;

import '../../../features/auth/presentation/bloc/auth_bloc.dart' as _i4;
import 'injection.dart' as _i5;

Future<_i1.GetIt> $initGetIt(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final supabaseModule = _$SupabaseModule();
  gh.singleton<_i3.SupabaseClient>(() => supabaseModule.supabaseClient);
  gh.singleton<_i3.GoTrueClient>(() => supabaseModule.supabaseAuth);
  gh.singleton<_i3.SupabaseStorageClient>(() => supabaseModule.supabaseStorage);
  gh.factory<_i4.AuthBloc>(
    () => _i4.AuthBloc(gh<_i3.SupabaseClient>()),
  );
  return getIt;
}

class _$SupabaseModule extends _i5.SupabaseModule {}
