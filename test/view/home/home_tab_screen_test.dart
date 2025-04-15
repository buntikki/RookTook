import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rooktook/src/app.dart';
import 'package:rooktook/src/model/game/game_storage.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/styles/lichess_icons.dart';
import 'package:rooktook/src/view/game/game_list_tile.dart';
import 'package:rooktook/src/view/home/games_carousel.dart';
import 'package:rooktook/src/view/play/quick_game_matrix.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/feedback.dart';

import '../../example_data.dart';
import '../../mock_server_responses.dart';
import '../../model/auth/fake_session_storage.dart';
import '../../network/fake_http_client_factory.dart';
import '../../test_helpers.dart';
import '../../test_provider_scope.dart';

void main() {
  group('Home online', () {
    testWidgets('shows Play button', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows players button', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(
        tester
            .widget<AppBarIconButton>(
              find.ancestor(
                of: find.byIcon(Icons.group_outlined),
                matching: find.byType(AppBarIconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('shows challenge button if has session', (tester) async {
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        userSession: fakeSession,
      );
      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(
        tester
            .widget<AppBarIconButton>(
              find.ancestor(
                of: find.byIcon(LichessIcons.crossed_swords),
                matching: find.byType(AppBarIconButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('shows quick pairing matrix', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(QuickGameMatrix), findsOneWidget);
    });

    testWidgets('no session, no stored game: shows welcome screen ', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('libre, no-ads, open source chess server.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('About Lichess...'), findsOneWidget);
    });

    testWidgets('session, no played game: do not show welcome screen', (tester) async {
      int nbUserGamesRequests = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/games/user/testuser') {
          nbUserGamesRequests++;
          return mockResponse('', 200);
        }
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        userSession: fakeSession,
        overrides: [
          httpClientFactoryProvider.overrideWith((ref) => FakeHttpClientFactory(() => mockClient)),
        ],
      );
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(nbUserGamesRequests, 1);
      expect(find.text('Sign in'), findsNothing);
      expect(find.text('About Lichess...'), findsNothing);
    });

    testWidgets('no session, with stored games: shows list of recent games', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateArchivedGames(count: 3);
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('About Lichess...'), findsNothing);
      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('Anonymous'), findsNWidgets(3));
    });

    testWidgets('session, with played games: shows recent games', (tester) async {
      int nbUserGamesRequests = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/games/user/testuser') {
          nbUserGamesRequests++;
          return mockResponse(mockUserRecentGameResponse('testUser'), 200);
        }
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        userSession: fakeSession,
        overrides: [
          httpClientFactoryProvider.overrideWith((ref) => FakeHttpClientFactory(() => mockClient)),
        ],
      );
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(nbUserGamesRequests, 1);
      expect(find.text('About Lichess...'), findsNothing);
      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('MightyNanook'), findsOneWidget);
    });

    testWidgets('shows ongoing games if any', (tester) async {
      int nbOngoingGamesRequests = 0;
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/account/playing') {
          nbOngoingGamesRequests++;
          return mockResponse(mockAccountOngoingGamesResponse(), 200);
        }
        return mockResponse('', 200);
      });
      final app = await makeTestProviderScope(
        tester,
        child: const Application(),
        userSession: fakeSession,
        overrides: [
          httpClientFactoryProvider.overrideWith((ref) => FakeHttpClientFactory(() => mockClient)),
        ],
      );
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(nbOngoingGamesRequests, 1);
      expect(find.text('About Lichess...'), findsNothing);
      expect(find.text('Recent games'), findsNothing);
      expect(find.text('1 game in play'), findsOneWidget);
      expect(find.byType(OngoingGameCarouselItem), findsOneWidget);
    });
  });

  group('Home offline', () {
    testWidgets('shows offline banner', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());

      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(ConnectivityBanner), findsOneWidget);
    });

    testWidgets('shows Play button', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());

      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows disabled players button', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());

      await tester.pumpWidget(app);

      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      expect(
        tester
            .widget<AppBarIconButton>(
              find.ancestor(
                of: find.byIcon(Icons.group_outlined),
                matching: find.byType(AppBarIconButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('no session, no stored game: shows welcome screen ', (tester) async {
      final app = await makeTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);
      // wait for connectivity
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('libre, no-ads, open source chess server.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('About Lichess...'), findsOneWidget);
    });

    testWidgets('no session, with stored games: shows list of recent games', (tester) async {
      final app = await makeOfflineTestProviderScope(tester, child: const Application());
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateArchivedGames(count: 3);
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('About Lichess...'), findsNothing);
      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
      expect(find.text('Anonymous'), findsNWidgets(3));
    });

    testWidgets('session, with stored games: shows list of recent games', (tester) async {
      final app = await makeOfflineTestProviderScope(
        tester,
        child: const Application(),
        userSession: fakeSession,
      );
      await tester.pumpWidget(app);

      final container = ProviderScope.containerOf(tester.element(find.byType(Application)));
      final storage = await container.read(gameStorageProvider.future);
      final games = generateArchivedGames(count: 3, username: 'testUser');
      for (final game in games) {
        await storage.save(game);
      }

      // wait for connectivity
      await tester.pumpAndSettle();

      expect(find.text('About Lichess...'), findsNothing);
      expect(find.text('Recent games'), findsOneWidget);
      expect(find.byType(GameListTile), findsNWidgets(3));
    });
  });
}
