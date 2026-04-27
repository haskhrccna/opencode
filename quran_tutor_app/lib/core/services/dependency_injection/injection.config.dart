// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:just_audio/just_audio.dart' as _i501;
import 'package:record/record.dart' as _i1039;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../../features/admin/data/datasources/admin_remote_datasource.dart'
    as _i966;
import '../../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i241;
import '../../../features/admin/domain/repositories/admin_repository.dart'
    as _i241a;
import '../../../features/admin/presentation/bloc/admin_bloc.dart' as _i940;
import '../../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i362;
import '../../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i363;
import '../../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i234;
import '../../../features/auth/domain/repositories/auth_repository.dart'
    as _i234a;
import '../../../features/auth/presentation/bloc/auth_bloc.dart' as _i748;
import '../../../features/grading/data/datasources/grading_remote_datasource.dart'
    as _i998;
import '../../../features/grading/data/repositories/grading_repository_impl.dart'
    as _i916;
import '../../../features/grading/domain/repositories/grading_repository.dart'
    as _i916a;
import '../../../features/grading/presentation/bloc/grading_bloc.dart' as _i867;
import '../../../features/profile/data/datasources/profile_remote_datasource.dart'
    as _i920;
import '../../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i919;
import '../../../features/profile/domain/repositories/profile_repository.dart'
    as _i919a;
import '../../../features/profile/presentation/bloc/profile_bloc.dart' as _i428;
import '../../../features/sessions/data/datasources/sessions_remote_datasource.dart'
    as _i933;
import '../../../features/sessions/data/repositories/sessions_repository_impl.dart'
    as _i46;
import '../../../features/sessions/domain/repositories/sessions_repository.dart'
    as _i46a;
import '../../../features/sessions/presentation/bloc/sessions_bloc.dart'
    as _i284;
import '../audio/audio_service.dart' as _i910;
import '../notifications/notification_service.dart' as _i229;
import '../offline/offline_database.dart' as _i95;
import '../offline/offline_service.dart' as _i642;
import '../pdf/pdf_service.dart' as _i441;
import '../realtime/realtime_service.dart' as _i854;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final supabaseModule = _$SupabaseModule();
  gh.singleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
  gh.singleton<_i454.GoTrueClient>(() => supabaseModule.auth);
  gh.singleton<_i454.PostgrestClient>(() => supabaseModule.database);
  gh.singleton<_i454.SupabaseStorageClient>(() => supabaseModule.storage);
  gh.singleton<_i454.RealtimeClient>(() => supabaseModule.realtime);
  gh.singleton<_i441.PdfService>(() => _i441.PdfService());
  gh.singleton<_i229.NotificationService>(() => _i229.NotificationService());
  gh.singleton<_i501.AudioPlayer>(() => _i501.AudioPlayer());
  gh.singleton<_i1039.AudioRecorder>(() => _i1039.AudioRecorder());
  gh.singleton<_i895.Connectivity>(() => _i895.Connectivity());
  gh.singleton<_i95.OfflineDatabase>(() => _i95.OfflineDatabase());
  gh.singleton<_i361.FlutterSecureStorage>(() => const _i361.FlutterSecureStorage());

  // Data sources
  gh.singleton<_i362.AuthLocalDataSource>(
      () => _i362.SecureStorageAuthDataSource(storage: gh<_i361.FlutterSecureStorage>()));
  gh.singleton<_i363.AuthRemoteDataSource>(
      () => _i363.SupabaseAuthDataSource(supabase: gh<_i454.SupabaseClient>()));
  gh.singleton<_i933.SessionsRemoteDataSource>(
      () => _i933.SupabaseSessionsDataSource(supabase: gh<_i454.SupabaseClient>()));
  gh.singleton<_i920.ProfileRemoteDataSource>(
      () => _i920.SupabaseProfileDataSource(supabase: gh<_i454.SupabaseClient>()));
  gh.singleton<_i966.AdminRemoteDataSource>(
      () => _i966.SupabaseAdminDataSource(supabase: gh<_i454.SupabaseClient>()));
  gh.singleton<_i998.GradingRemoteDataSource>(
      () => _i998.SupabaseGradingDataSource(supabase: gh<_i454.SupabaseClient>()));

  // Repositories
  gh.singleton<_i234a.AuthRepository>(() => _i234.AuthRepositoryImpl(
        remoteDataSource: gh<_i363.AuthRemoteDataSource>(),
        localDataSource: gh<_i362.AuthLocalDataSource>(),
      ));
  gh.singleton<_i46a.SessionsRepository>(
      () => _i46.SessionsRepositoryImpl());
  gh.singleton<_i919a.ProfileRepository>(
      () => _i919.ProfileRepositoryImpl());
  gh.singleton<_i241a.AdminRepository>(
      () => _i241.AdminRepositoryImpl());
  gh.singleton<_i916a.GradingRepository>(
      () => _i916.GradingRepositoryImpl(gh<_i998.GradingRemoteDataSource>()));

  // BLoCs
  gh.factory<_i748.AuthBloc>(() => _i748.AuthBloc(gh<_i234a.AuthRepository>()));
  gh.factory<_i284.SessionsBloc>(
      () => _i284.SessionsBloc(gh<_i46a.SessionsRepository>()));
  gh.factory<_i428.ProfileBloc>(
      () => _i428.ProfileBloc(gh<_i919a.ProfileRepository>()));
  gh.factory<_i940.AdminBloc>(
      () => _i940.AdminBloc(gh<_i241a.AdminRepository>()));
  gh.factory<_i867.GradingBloc>(
      () => _i867.GradingBloc(gh<_i916a.GradingRepository>()));

  // Services
  gh.singleton<_i910.AudioService>(() => _i910.AudioService(
        player: gh<_i501.AudioPlayer>(),
        recorder: gh<_i1039.AudioRecorder>(),
        supabase: gh<_i454.SupabaseClient>(),
      ));
  gh.singleton<_i854.RealtimeService>(
      () => _i854.RealtimeService(supabase: gh<_i454.SupabaseClient>()));
  gh.singleton<_i642.OfflineService>(() => _i642.OfflineService(
        db: gh<_i95.OfflineDatabase>(),
        connectivity: gh<_i895.Connectivity>(),
        sessionsDataSource: gh<_i933.SessionsRemoteDataSource>(),
        gradingDataSource: gh<_i998.GradingRemoteDataSource>(),
      ));
  return getIt;
}

class _$SupabaseModule extends _i464.SupabaseModule {}
