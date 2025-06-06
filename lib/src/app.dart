import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:l10n_esperanto/l10n_esperanto.dart';
import 'package:rooktook/l10n/l10n.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/maintenance_screen.dart';
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
import 'package:rooktook/src/view/tournament/pages/tournament_detail_screen.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Application initialization and main entry point.
class AppInitializationScreen extends ConsumerWidget {
  const AppInitializationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(maintenanceModeProvider.notifier).init();
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
    initBranchSetup();
  }

  Future<void> initBranchSetup() async {
    await FlutterBranchSdk.init();
    FlutterBranchSdk.disableTracking(false);
    FlutterBranchSdk.listSession().listen(
      (event) async {
        print('Branch Event $event');
        if (event.containsKey('+clicked_branch_link') && event['+clicked_branch_link'] == true) {
          final branchLink = event['\$deeplink_path'] as String;
          if (branchLink.contains('invite') && event.containsKey('ref')) {
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('referralCode', event['ref'].toString());
          }
          if (branchLink.contains('tournament') && event.containsKey('id')) {
            final tournament = await ref
                .read(tournamentProvider.notifier)
                .fetchSingleTournament(event['id'].toString());
            if (tournament != null) {
              // Wait until WidgetsBinding is done and Navigator is ready
              if (rootNavigatorKey.currentState?.mounted ?? false) {
                rootNavigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (context) => TournamentDetailScreen(tournament: tournament),
                  ),
                );
              } else {
                debugPrint('Navigator not yet mounted.');
              }
            }
          }
        }
      },
      onError: (error) {
        print('Branch Error $error');
      },
    );
    // FlutterBranchSdk.validateSDKIntegration();
  }

  @override
  void dispose() {
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMaintenance = ref.watch(maintenanceModeProvider);
    final generalPrefs = ref.watch(generalPreferencesProvider);
    final userSession = ref.watch(authSessionProvider)?.user;
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
      // onGenerateRoute:
      //     (settings) =>
      //         settings.name != null ? resolveAppLinkUri(context, Uri.parse(settings.name!)) : null,
      // onGenerateRoute: (initialRoute) {

      //   final homeRoute =
      //       isMaintenance
      //           ? buildScreenRoute<void>(context, screen: const MaintenanceScreen())
      //           : userSession != null
      //           ? buildScreenRoute<void>(context, screen: const BottomNavScaffold())
      //           : buildScreenRoute<void>(context, screen: const LoginScreen());
      //   return homeRoute;
      //   // return <Route<dynamic>?>[
      //   //   homeRoute,
      //   //   // resolveAppLinkUri(context, Uri.parse(initialRoute)),
      //   // ].nonNulls.toList(growable: false);
      // },
      home:
          isMaintenance
              ? const MaintenanceScreen()
              : userSession != null
              ? const BottomNavScaffold()
              : const LoginScreen(),
      navigatorObservers: [rootNavPageRouteObserver],
    );
  }
}

final maintenanceModeProvider = StateNotifierProvider<MaintenanceNotifier, bool>((ref) {
  return MaintenanceNotifier();
});

class MaintenanceNotifier extends StateNotifier<bool> {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  Timer? _timer;

  MaintenanceNotifier() : super(false);

  Future<void> init() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );
      await _remoteConfig.fetchAndActivate().onError((error, stackTrace) {
        log(error.toString());
        return false;
      });
      state = _remoteConfig.getBool('maintenanceMode');

      // poll every 2 minutes
      _timer = Timer.periodic(const Duration(minutes: 1), (_) async {
        await _remoteConfig.fetchAndActivate().onError((error, stackTrace) {
          log(error.toString());
          return false;
        });
        ;
        final value = _remoteConfig.getBool('maintenanceMode');

        if (value != state) {
          state = value;
        }
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
