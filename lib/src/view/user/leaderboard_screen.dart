import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/user/leaderboard.dart';
import 'package:lichess_mobile/src/model/user/user_repository_providers.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/user/user_screen.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/platform_scaffold.dart';

/// Create a Screen with Top 10 players for each Lichess Variant
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static Route<dynamic> buildRoute(BuildContext context) {
    return buildScreenRoute(
      context,
      title: context.l10n.leaderboard,
      screen: const LeaderboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(appBarTitle: Text(context.l10n.leaderboard), body: const _Body());
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);

    return leaderboard.when(
      data: (data) {
        final List<Widget> list = [
          _Leaderboard(data.bullet, LichessIcons.bullet, 'BULLET'),
          // _Leaderboard(data.blitz, LichessIcons.blitz, 'BLITZ'),
          _Leaderboard(data.rapid, LichessIcons.rapid, 'RAPID'),
          // _Leaderboard(data.classical, LichessIcons.classical, 'CLASSICAL'),
          // _Leaderboard(data.ultrabullet, LichessIcons.ultrabullet, 'ULTRA BULLET'),
          // _Leaderboard(data.crazyhouse, LichessIcons.h_square, 'CRAZYHOUSE'),
          // _Leaderboard(data.chess960, LichessIcons.die_six, 'CHESS 960'),
          // _Leaderboard(data.kingOfThehill, LichessIcons.bullet, 'KING OF THE HILL'),
          // _Leaderboard(data.threeCheck, LichessIcons.three_check, 'THREE CHECK'),
          // _Leaderboard(data.atomic, LichessIcons.atom, 'ATOMIC'),
          // _Leaderboard(data.horde, LichessIcons.horde, 'HORDE'),
          // _Leaderboard(data.antichess, LichessIcons.antichess, 'ANTICHESS'),
          // _Leaderboard(data.racingKings, LichessIcons.racing_kings, 'RACING KINGS'),
        ];

        return SafeArea(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = math.min(3, (constraints.maxWidth / 300).floor());
                return LayoutGrid(
                  columnSizes: List.generate(crossAxisCount, (_) => 1.fr),
                  rowSizes: List.generate((list.length / crossAxisCount).ceil(), (_) => auto),
                  children: list,
                );
              },
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => const Center(child: Text('Could not load leaderboard.')),
    );
  }
}

/// A List Tile for the Leaderboard
///
/// Optionaly Provide the [perfIcon] for the Variant of the List
class LeaderboardListTile extends StatelessWidget {
  const LeaderboardListTile({required this.user, this.perfIcon, this.index});
  final LeaderboardUser user;
  final IconData? perfIcon;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      onTap: () {},
      leading: Container(
        height: 22,
        width: 36,
        // padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(index != null ? '#$index' : '', style: const TextStyle(fontSize: 12)),
      ),
      // perfIcon != null ? Icon(perfIcon) : null,
      title: Padding(
        padding: const EdgeInsets.only(right: 5.0),
        child: Row(
          children: [
            Image.asset('assets/images/avatar.png', height: 30, width: 30),
            const SizedBox(width: 12),
            if (user.title != null) ...[
              Container(
                width: 60, // Fixed width for all titles
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xff21B8E8),
                ),
                child: Center(
                  child: Text(
                    user.title!,
                    overflow: TextOverflow.visible, // Ensures the text isn't cut off
                    textAlign: TextAlign.center, // Centers the text within the container
                    // style: (style ?? const TextStyle()).copyWith(
                    //   color:
                    //       user?.title == 'BOT'
                    //           ? context.lichessColors.fancy
                    //           : context.lichessColors.brag,
                    //   fontWeight: user?.title == 'BOT' ? null : FontWeight.bold,
                    // ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              user.lightUser.name,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xffEFEDED),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        //  UserFullNameWidget(user: user.lightUser),
      ),
      // subtitle: perfIcon != null ? Text(user.rating.toString()) : null,
      trailing: Text(
        user.rating.toString(),
        style: const TextStyle(fontSize: 14, color: Color(0xffEFEDED)),
      ),

      //  perfIcon != null ? _Progress(user.progress) : Text(user.rating.toString()),
    );
  }

  void _handleTap(BuildContext context) {
   // Navigator.of(context).push(UserScreen.buildRoute(context, user.lightUser));
  }
}

class _Progress extends StatelessWidget {
  const _Progress(this.progress);
  final int progress;

  @override
  Widget build(BuildContext context) {
    if (progress == 0) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          progress > 0 ? LichessIcons.arrow_full_upperright : LichessIcons.arrow_full_lowerright,
          size: 16,
          color: progress > 0 ? context.lichessColors.good : context.lichessColors.error,
        ),
        Text(
          '${progress.abs()}',
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            color: progress > 0 ? context.lichessColors.good : context.lichessColors.error,
          ),
        ),
      ],
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard(this.userList, this.iconData, this.title);
  final List<LeaderboardUser> userList;
  final IconData iconData;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListSection(
        backgroundColor: const Color(0xff2B2D30),
        hasLeading: false,
        header: Row(
          children: [
            Icon(iconData, color: context.lichessColors.brag),
            const SizedBox(width: 10.0),
            Text(title),
          ],
        ),
        children:
            userList.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return LeaderboardListTile(index: index + 1, user: user);
            }).toList(),
      ),
    );
  }
}
