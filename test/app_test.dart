import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:rooktook/src/app.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/view/home/home_tab_screen.dart';

import 'model/auth/fake_session_storage.dart';
import 'network/fake_http_client_factory.dart';
import 'test_helpers.dart';
import 'test_provider_scope.dart';

void main() {
  testWidgets('App loads', (tester) async {
    final app = await makeTestProviderScope(tester, child: const Application());

    await tester.pumpWidget(app);

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App loads with system theme, which defaults to light', (tester) async {
    final app = await makeTestProviderScope(tester, child: const Application());

    await tester.pumpWidget(app);

    expect(Theme.of(tester.element(find.byType(MaterialApp))).brightness, Brightness.light);
  });

  testWidgets('App will delete a stored session on startup if one request return 401', (
    tester,
  ) async {
    int tokenTestRequests = 0;
    final mockClient = MockClient((request) async {
      if (request.url.path == '/api/token/test') {
        tokenTestRequests++;
        return mockResponse('''
{
  "${fakeSession.token}": null
}
        ''', 200);
      } else if (request.url.path == '/api/account') {
        return mockResponse('{"error": "Unauthorized"}', 401);
      }
      return mockResponse('', 404);
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

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomeTabScreen), findsOneWidget);

    // wait for the startup requests and animations to complete
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    // should see welcome message
    expect(
      find.text(
        'Lichess is a free (really), libre, no-ads, open source chess server.',
        findRichText: true,
      ),
      findsOneWidget,
    );

    // should have made a request to test the token
    expect(tokenTestRequests, 1);

    // session is not active anymore
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Bottom navigation', (tester) async {
    final app = await makeTestProviderScope(tester, child: const Application());

    await tester.pumpWidget(app);

    expect(find.byType(BottomNavScaffold), findsOneWidget);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      expect(find.byType(BottomNavigationBarItem), findsNWidgets(5));
    } else {
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    }

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Puzzles'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
