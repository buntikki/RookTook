import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/network/connectivity.dart';
import 'package:rooktook/src/styles/lichess_icons.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/view/over_the_board/over_the_board_screen.dart';
import 'package:rooktook/src/view/play/create_custom_game_screen.dart';
import 'package:rooktook/src/view/play/online_bots_screen.dart';
import 'package:rooktook/src/widgets/list.dart';

/// A widget that displays the options for creating a game.
class CreateGameOptions extends ConsumerWidget {
  const CreateGameOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityChangesProvider).valueOrNull?.isOnline ?? false;
    final isPlayban = ref.watch(accountProvider).valueOrNull?.playban != null;

    return Column(
      children: [
        _Section(
          children: [
            _CreateGamePlatformButton(
              onTap:
                  isOnline && !isPlayban
                      ? () {
                        ref.invalidate(accountProvider);
                        Navigator.of(context).push(CreateCustomGameScreen.buildRoute(context));
                      }
                      : null,
              icon: Icons.tune,
              label: context.l10n.custom,
            ),
            _CreateGamePlatformButton(
              onTap:
                  isOnline
                      ? () {
                        Navigator.of(context).push(OnlineBotsScreen.buildRoute(context));
                      }
                      : null,
              icon: Icons.computer,
              label: context.l10n.onlineBots,
            ),
          ],
        ),
        _Section(
          children: [
            _CreateGamePlatformButton(
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).push(OverTheBoardScreen.buildRoute(context));
              },
              icon: LichessIcons.chess_board,
              label: 'Over the board',
            ),
          ],
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? ListSection(hasLeading: true, children: children)
        : Padding(
          padding: Styles.horizontalBodyPadding.add(Styles.sectionTopPadding),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        );
  }
}

class _CreateGamePlatformButton extends StatelessWidget {
  const _CreateGamePlatformButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;

  final String label;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: PlatformListTile(
            leading: Icon(icon, size: 28),
            trailing: const CupertinoListTileChevron(),
            title: Text(label, style: Styles.mainListTileTitle),
            onTap: onTap,
          ),
        )
        : FilledButton.tonalIcon(onPressed: onTap, icon: Icon(icon), label: Text(label));
  }
}
