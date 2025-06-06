import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/account/account_preferences.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/game/game_controller.dart';
import 'package:rooktook/src/model/game/game_preferences.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/view/game/game_screen_providers.dart';
import 'package:rooktook/src/view/settings/board_settings_screen.dart';
import 'package:rooktook/src/widgets/adaptive_bottom_sheet.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/settings.dart';

class GameSettings extends ConsumerWidget {
  const GameSettings({required this.id, super.key});

  final GameFullId id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamePrefs = ref.watch(gamePreferencesProvider);
    final userPrefsAsync = ref.watch(userGamePrefsProvider(id));

    return BottomSheetScrollableContainer(
      children: [
        ListSection(
          materialFilledCard: true,
          children: [
            ...userPrefsAsync.maybeWhen(
              data: (data) {
                return [
                  if (data.prefs?.submitMove == true)
                    SwitchSettingTile(
                      title: Text(context.l10n.preferencesMoveConfirmation),
                      value: data.shouldConfirmMove,
                      onChanged: (value) {
                        ref.read(gameControllerProvider(id).notifier).toggleMoveConfirmation();
                      },
                    ),
                  if (data.prefs?.autoQueen == AutoQueen.always)
                    SwitchSettingTile(
                      title: Text(context.l10n.preferencesPromoteToQueenAutomatically),
                      value: data.canAutoQueen,
                      onChanged: (value) {
                        ref.read(gameControllerProvider(id).notifier).toggleAutoQueen();
                      },
                    ),
                  SwitchSettingTile(
                    title: Text(context.l10n.preferencesZenMode),
                    value: data.isZenModeEnabled,
                    onChanged: (value) {
                      ref.read(gameControllerProvider(id).notifier).toggleZenMode();
                    },
                  ),
                ];
              },
              orElse: () => [],
            ),
            SwitchSettingTile(
              title: Text(context.l10n.toggleTheChat),
              value: gamePrefs.enableChat ?? false,
              onChanged: (value) {
                ref.read(gamePreferencesProvider.notifier).toggleChat();
                ref.read(gameControllerProvider(id).notifier).onToggleChat(value);
              },
            ),
            /*SwitchSettingTile(
              title: Text(context.l10n.preferencesBlindfold),
              value: gamePrefs.blindfoldMode ?? false,
              onChanged: (value) {
                ref.read(gamePreferencesProvider.notifier).toggleBlindfoldMode();
              },
            ),*/
            PlatformListTile(
              // TODO translate
              title: const Text('Board settings'),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () {
                Navigator.of(
                  context,
                ).push(BoardSettingsScreen.buildRoute(context, fullscreenDialog: true));
              },
            ),
          ],
        ),
      ],
    );
  }
}
