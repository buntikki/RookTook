import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:rooktook/l10n/l10n.dart';
import 'package:rooktook/src/app_links.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/account/account_service.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/challenge/challenge_service.dart';
import 'package:rooktook/src/model/common/preloaded_data.dart';
import 'package:rooktook/src/model/correspondence/correspondence_service.dart';
import 'package:rooktook/src/model/notifications/notification_service.dart';
import 'package:rooktook/src/model/settings/board_preferences.dart';
import 'package:rooktook/src/model/settings/general_preferences.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/network/socket.dart';
import 'package:rooktook/src/theme.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/utils/screen.dart';
import 'package:rooktook/src/view/auth/presentation/pages/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application initialization and main entry point.
class AppInitializationScreen extends ConsumerWidget {
  const AppInitializationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<PreloadedData>>(preloadedDataProvider, (_, state) {
      if (state.hasValue || state.hasError) {
        FlutterNativeSplash.remove();
      }
    });

    return ref
        .watch(preloadedDataProvider)
        .when(
          data: (_) => const Application(),
          // loading screen is handled by the native splash screen
          loading: () => const SizedBox.shrink(),
          error: (err, st) {
            debugPrint('SEVERE: [App] could not initialize app; $err\n$st');
            return const SizedBox.shrink();
          },
        );
  }
}

/// The main application widget.
///
/// This widget is the root of the application and is responsible for setting up
/// the theme, locale, and other global settings.
class Application extends ConsumerStatefulWidget {
  const Application({super.key});

  @override
  ConsumerState<Application> createState() => _AppState();
}

class _AppState extends ConsumerState<Application> {
  /// Whether the app has checked for online status for the first time.
  bool _firstTimeOnlineCheck = false;

  AppLifecycleListener? _appLifecycleListener;

  DateTime? _pausedAt;

  @override
  void initState() {
    _appLifecycleListener = AppLifecycleListener(
      onPause: () {
        _pausedAt = DateTime.now();
      },
      onRestart: () async {
        // Invalidate ongoing games if the app was paused for more than an hour.
        // In theory we shouldn't need to do this, because correspondence games are updated by
        // fcm messages, but in practice it's not always reliable.
        // See also: [CorrespondenceService].
        final online = await isOnline(ref.read(defaultClientProvider));
        if (online &&
            _pausedAt != null &&
            DateTime.now().difference(_pausedAt!) >= const Duration(hours: 1)) {
          ref.invalidate(ongoingGamesProvider);
        }
      },
    );

    // Start services
    ref.read(notificationServiceProvider).start();
    ref.read(challengeServiceProvider).start();
    ref.read(accountServiceProvider).start();
    ref.read(correspondenceServiceProvider).start();

    // Listen for connectivity changes and perform actions accordingly.
    ref.listenManual(connectivityChangesProvider, (prev, current) async {
      final prevWasOffline = prev?.value?.isOnline == false;
      final currentIsOnline = current.value?.isOnline == true;

      // Play registered moves whenever the app comes back online.
      if (prevWasOffline && currentIsOnline) {
        final nbMovesPlayed = await ref.read(correspondenceServiceProvider).playRegisteredMoves();
        if (nbMovesPlayed > 0) {
          ref.invalidate(ongoingGamesProvider);
        }
      }

      // Perform actions once when the app comes online.
      if (current.value?.isOnline == true && !_firstTimeOnlineCheck) {
        _firstTimeOnlineCheck = true;
        ref.read(correspondenceServiceProvider).syncGames();
      }

      final socketClient = ref.read(socketPoolProvider).currentClient;
      if (current.value?.isOnline == true &&
          current.value?.appState == AppLifecycleState.resumed &&
          !socketClient.isActive) {
        socketClient.connect();
      } else if (current.value?.isOnline == false) {
        socketClient.close();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generalPrefs = ref.watch(generalPreferencesProvider);
    final userSession = ref.read(authSessionProvider)?.user;
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final (light: themeLight, dark: themeDark) = makeAppTheme(context, generalPrefs, boardPrefs);

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final remainingHeight = estimateRemainingHeightLeftBoard(context);

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        MaterialLocalizationsEo.delegate,
        CupertinoLocalizationsEo.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      onGenerateTitle: (BuildContext context) => 'RookTook',
      locale: generalPrefs.locale,
      theme: themeLight.copyWith(
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme(themeLight.textTheme),
        navigationBarTheme: NavigationBarTheme.of(
          context,
        ).copyWith(height: remainingHeight < kSmallRemainingHeightLeftBoardThreshold ? 60 : null),
      ),
      darkTheme: themeDark.copyWith(
        primaryColor: const Color(0xFF13191D),
        scaffoldBackgroundColor: const Color(0xFF13191D),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF13191D)),
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme(themeDark.textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13191D),
          brightness: Brightness.dark,
        ),
        navigationBarTheme: NavigationBarTheme.of(
          context,
        ).copyWith(height: remainingHeight < kSmallRemainingHeightLeftBoardThreshold ? 60 : null),
      ),
      themeMode: ThemeMode.dark,
      builder:
          isIOS
              ? (context, child) => IconTheme.merge(
                data: IconThemeData(color: CupertinoTheme.of(context).textTheme.textStyle.color),
                child: Material(color: Colors.transparent, child: child),
              )
              : null,
      onGenerateRoute:
          (settings) =>
              settings.name != null ? resolveAppLinkUri(context, Uri.parse(settings.name!)) : null,
      onGenerateInitialRoutes: (initialRoute) {
        final homeRoute = userSession!=null ?  buildScreenRoute<void>(context, screen: const BottomNavScaffold()) : buildScreenRoute<void>(context, screen: const LoginScreen());
        return <Route<dynamic>?>[
          homeRoute,
          resolveAppLinkUri(context, Uri.parse(initialRoute)),
        ].nonNulls.toList(growable: false);
      },
      navigatorObservers: [rootNavPageRouteObserver],
    );
  }
}
