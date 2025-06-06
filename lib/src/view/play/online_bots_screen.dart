import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/user/user.dart';
import 'package:rooktook/src/model/user/user_repository.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/play/challenge_odd_bots_screen.dart';
import 'package:rooktook/src/view/play/create_challenge_screen.dart';
import 'package:rooktook/src/view/user/user_screen.dart';
import 'package:rooktook/src/widgets/adaptive_bottom_sheet.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/platform_scaffold.dart';
import 'package:rooktook/src/widgets/user_full_name.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

final _onlineBotsProvider = FutureProvider.autoDispose<IList<User>>((ref) async {
  return ref.withClientCacheFor(
    (client) => UserRepository(client).getOnlineBots().then((bots) => bots.toIList()),
    const Duration(hours: 5),
  );
});

class OnlineBotsScreen extends StatelessWidget {
  const OnlineBotsScreen();

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(context, screen: const OnlineBotsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Styles.listingsScreenBackgroundColor(context),
      appBarTitle: Text(context.l10n.onlineBots),
      body: _Body(),
    );
  }
}

class _Body extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineBots = ref.watch(_onlineBotsProvider);

    return onlineBots.when(
      data:
          (data) => ListView.separated(
            itemCount: data.length,
            separatorBuilder:
                (context, index) =>
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Divider(
                          height: 0,
                          thickness: 0,
                          // equals to _kNotchedPaddingWithoutLeading constant
                          // See: https://github.com/flutter/flutter/blob/89ea49204b37523a16daec53b5e6fae70995929d/packages/flutter/lib/src/cupertino/list_tile.dart#L24
                          indent: 28,
                          color: CupertinoDynamicColor.resolve(CupertinoColors.separator, context),
                        )
                        : const SizedBox.shrink(),
            itemBuilder: (context, index) {
              final bot = data[index];
              return PlatformListTile(
                isThreeLine: true,
                trailing:
                    Theme.of(context).platform == TargetPlatform.iOS
                        ? Row(
                          children: [
                            if (bot.verified == true) ...[
                              const Icon(Icons.verified_outlined),
                              const SizedBox(width: 5),
                            ],
                            const CupertinoListTileChevron(),
                          ],
                        )
                        : bot.verified == true
                        ? const Icon(Icons.verified_outlined)
                        : null,
                title: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: UserFullNameWidget(
                    user: bot.lightUser,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                subtitle: Column(
                  children: [
                    Row(
                      children:
                          [Perf.blitz, Perf.rapid, Perf.classical].map((perf) {
                            final rating = bot.perfs[perf]?.rating;
                            final nbGames = bot.perfs[perf]?.games ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0, top: 4.0, bottom: 4.0),
                              child: Row(
                                children: [
                                  Icon(perf.icon, size: 16),
                                  const SizedBox(width: 4.0),
                                  if (rating != null && nbGames > 0)
                                    Text('$rating', style: const TextStyle(color: Colors.grey))
                                  else
                                    const Text('  -  '),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                    Text(bot.profile?.bio ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                onTap: () {
                  final session = ref.read(authSessionProvider);
                  if (session == null) {
                    showPlatformSnackbar(
                      context,
                      context.l10n.challengeRegisterToSendChallenges,
                      type: SnackBarType.error,
                    );
                    return;
                  }
                  final isOddBot = oddBots.contains(bot.lightUser.name.toLowerCase());
                  Navigator.of(context).push(
                    isOddBot
                        ? ChallengeOddBotsScreen.buildRoute(context, bot.lightUser)
                        : CreateChallengeScreen.buildRoute(context, bot.lightUser),
                  );
                },
                onLongPress: () {
                  showAdaptiveBottomSheet<void>(
                    context: context,
                    useRootNavigator: true,
                    isDismissible: true,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (context) => _ContextMenu(bot: bot),
                  );
                },
              );
            },
          ),
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (e, s) {
        debugPrint('Could not load bots: $e');
        return FullScreenRetryRequest(onRetry: () => ref.refresh(_onlineBotsProvider));
      },
    );
  }
}

class _ContextMenu extends ConsumerWidget {
  const _ContextMenu({required this.bot});

  final User bot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomSheetScrollableContainer(
      children: [
        Padding(
          padding: Styles.horizontalBodyPadding.add(const EdgeInsets.only(bottom: 16.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserFullNameWidget(user: bot.lightUser, style: Styles.title),
              const SizedBox(height: 8.0),
              if (bot.profile?.bio != null)
                Linkify(
                  onOpen: (link) async {
                    if (link.originText.startsWith('@')) {
                      final username = link.originText.substring(1);
                      Navigator.of(context).push(
                        UserScreen.buildRoute(
                          context,
                          LightUser(id: UserId.fromUserName(username), name: username),
                        ),
                      );
                    } else {
                      launchUrl(Uri.parse(link.url));
                    }
                  },
                  linkifiers: const [UrlLinkifier(), EmailLinkifier(), UserTagLinkifier()],
                  text: bot.profile!.bio!,
                  maxLines: 20,
                  overflow: TextOverflow.ellipsis,
                  linkStyle: const TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.none,
                  ),
                ),
            ],
          ),
        ),
        const PlatformDivider(),
        BottomSheetContextMenuAction(
          onPressed: () {
            Navigator.of(context).push(UserScreen.buildRoute(context, bot.lightUser));
          },
          icon: Icons.person,
          child: Text(context.l10n.profile),
        ),
      ],
    );
  }
}
