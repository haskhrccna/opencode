import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran_tutor_app/core/constants/app_constants.dart';
import 'package:quran_tutor_app/core/environment/app_environment.dart';
import 'package:quran_tutor_app/core/router/app_router.dart';
import 'package:quran_tutor_app/core/services/dependency_injection/injection.dart';
import 'package:quran_tutor_app/core/theme/app_theme.dart';
import 'package:quran_tutor_app/core/theme/cubit/theme_cubit.dart';
import 'package:quran_tutor_app/core/utils/bloc_observer.dart';
import 'package:quran_tutor_app/core/utils/logging/app_logger.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:quran_tutor_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  assert(supabaseUrl.isNotEmpty,
      'SUPABASE_URL must be provided via --dart-define=SUPABASE_URL=...',);
  assert(supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY must be provided via --dart-define=SUPABASE_ANON_KEY=...',);

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

class QuranTutorApp extends StatelessWidget {
  const QuranTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(const AppStarted()),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
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
              localizationsDelegates: context.localizationDelegates,
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
