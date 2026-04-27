import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/entities/auth_user.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import 'injection.dart';

GetIt $initGetIt(
  GetIt getIt, {
  String? environment,
  EnvironmentFilter? environmentFilter,
}) {
  final gh = GetItHelper(getIt, environment, environmentFilter);
  final supabaseModule = _$SupabaseModule();

  // Supabase core
  gh.singleton<SupabaseClient>(supabaseModule.supabaseClient);
  gh.singleton<SupabaseStorageClient>(supabaseModule.storage);

  // Auth feature
  gh.factory<AuthRemoteDataSource>(
    () => SupabaseAuthDataSource(supabase: getIt<SupabaseClient>()),
  );
  gh.singleton<AuthLocalDataSource>(
    const SecureStorageAuthDataSource(),
  );
  gh.factory<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  gh.factory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  return getIt;
}

class _$SupabaseModule extends SupabaseModule {}
