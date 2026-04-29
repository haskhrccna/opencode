import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/environment/app_environment.dart';
import 'package:quran_tutor_app/core/localization/app_localizations.dart';
import 'package:quran_tutor_app/core/router/app_router.dart';
import 'package:quran_tutor_app/core/services/dependency_injection/injection.dart';
import 'package:quran_tutor_app/core/theme/app_theme.dart';
import 'package:quran_tutor_app/core/theme/cubit/theme_cubit.dart';
import 'package:quran_tutor_app/core/utils/bloc_observer.dart';
import 'package:quran_tutor_app/core/utils/logging/app_logger.dart';
import 'package:quran_tutor_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:quran_tutor_app/features/grading/presentation/bloc/grading_bloc.dart';
import 'package:quran_tutor_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:quran_tutor_app/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (bundled as an asset). Tolerate a missing file so that
  // --dart-define-only setups (e.g. CI) keep working.
  try {
    await dotenv.load();
  } catch (_) {
    // No .env bundled — fall back to compile-time --dart-define values.
  }

  final supabaseUrl = _envOrDefine('SUPABASE_URL');
  final supabaseAnonKey = _envOrDefine('SUPABASE_ANON_KEY');
  assert(
    supabaseUrl.isNotEmpty,
    'SUPABASE_URL must be set in .env or via --dart-define=SUPABASE_URL=...',
  );
  assert(
    supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY must be set in .env or via '
    '--dart-define=SUPABASE_ANON_KEY=...',
  );

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await EasyLocalization.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  final logger = AppLogger();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await configureDependencies();

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      logger.e('FlutterError: ${details.exception}',
          error: details.exception, stackTrace: details.stack,);
    };
    ErrorWidget.builder = (details) => Material(
      child: Container(
        color: Colors.red,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Error:\n${details.exception.toString()}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  logger.i('Quran Tutor App Started');
  logger.i('Environment: ${AppEnvironment.displayName}');
  logger.i('API Base URL: ${AppEnvironment.baseUrl}');

  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLocales,
      path: AppConstants.translationsPath,
      fallbackLocale: AppConstants.defaultLocale,
      startLocale: AppConstants.defaultLocale,
      useOnlyLangCode: true,
      child: const QuranTutorApp(),
    ),
  );
}

/// Read [key] from `.env` first, then fall back to a compile-time
/// `--dart-define`. Returns an empty string when neither is set.
String _envOrDefine(String key) {
  final fromEnv = dotenv.maybeGet(key);
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // String.fromEnvironment requires a const key — branch per known key.
  switch (key) {
    case 'SUPABASE_URL':
      return const String.fromEnvironment('SUPABASE_URL');
    case 'SUPABASE_ANON_KEY':
      return const String.fromEnvironment('SUPABASE_ANON_KEY');
    case 'ONESIGNAL_APP_ID':
      return const String.fromEnvironment('ONESIGNAL_APP_ID');
    case 'POSTHOG_API_KEY':
      return const String.fromEnvironment('POSTHOG_API_KEY');
    case 'POSTHOG_HOST':
      return const String.fromEnvironment('POSTHOG_HOST');
    default:
      return '';
  }
}

class QuranTutorApp extends StatelessWidget {
  const QuranTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(const AppStarted()),
        ),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => getIt<SessionsBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()),
        BlocProvider(create: (_) => getIt<GradingBloc>()),
        BlocProvider(create: (_) => getIt<AdminBloc>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          AppRouter.authRefreshNotifier.value = state.status;
        },
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'Quran Tutor',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                ...context.localizationDelegates,
                AppLocalizations.delegate,
              ],
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
