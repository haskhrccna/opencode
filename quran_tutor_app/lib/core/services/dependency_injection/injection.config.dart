// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:supabase_flutter/supabase_flutter.dart' as _i3;

import '../../../features/auth/presentation/bloc/auth_bloc.dart' as _i4;
import 'injection.dart' as _i5;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({_i2.EnvironmentFilter? environmentFilter}) async {
    final gh = _i2.GetItHelper(this, environmentFilter);
    final supabaseModule = _$SupabaseModule();
    gh.singleton<_i3.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.singleton<_i3.GoTrueClient>(() => supabaseModule.auth);
    gh.singleton<_i3.PostgrestClient>(() => supabaseModule.database);
    gh.singleton<_i3.SupabaseStorageClient>(() => supabaseModule.storage);
    gh.singleton<_i3.RealtimeClient>(() => supabaseModule.realtime);
    gh.factory<_i4.AuthBloc>(() => _i4.AuthBloc());
    return this;
  }
}

class _$SupabaseModule extends _i5.SupabaseModule {}
