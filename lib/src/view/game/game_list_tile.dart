import 'package:dartchess/dartchess.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rooktook/src/model/analysis/analysis_controller.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/common/perf.dart';
import 'package:rooktook/src/model/game/archived_game.dart';
import 'package:rooktook/src/model/game/game_filter.dart';
import 'package:rooktook/src/model/game/game_share_service.dart';
import 'package:rooktook/src/model/game/game_status.dart';
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/styles/lichess_colors.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/l10n.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/screen.dart';
import 'package:rooktook/src/utils/share.dart';
import 'package:rooktook/src/view/analysis/analysis_screen.dart';
import 'package:rooktook/src/view/game/game_common_widgets.dart';
import 'package:rooktook/src/view/game/status_l10n.dart';
import 'package:rooktook/src/widgets/adaptive_bottom_sheet.dart';
import 'package:rooktook/src/widgets/board_thumbnail.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/user_full_name.dart';
import 'package:random_avatar/random_avatar.dart';

final _dateFormatter = DateFormat.yMMMd().add_Hm();

/// A list tile for a game in a game list.
class GameListTile extends StatelessWidget {
  const GameListTile({
    required this.item,
    this.padding,
    this.onPressedBookmark,
    this.gameListContext,
    this.tileColor,
    this.titleColor,
    this.rating,
  });

  final LightArchivedGameWithPov item;
  final EdgeInsetsGeometry? padding;
  final Future<void> Function(BuildContext context)? onPressedBookmark;
  final Color? tileColor;
  final Color? titleColor;
  final int? rating;

  /// The context of the game list that opened this screen, if available.
  final (UserId?, GameFilterState)? gameListContext;

  @override
  Widget build(BuildContext context) {
    final (game: game, pov: youAre) = item;

    final opponent = item.pov == Side.white ? item.game.black : item.game.white;
    final opponentRating = opponent.rating! + opponent.ratingDiff!;
    final me = youAre == Side.white ? game.white : game.black;
    //final opponent = youAre == Side.white ? game.black : game.white;

    Widget getResultIcon(LightArchivedGame game, Side mySide) {
      if (game.status == GameStatus.aborted || game.status == GameStatus.noStart) {
        return const Icon(CupertinoIcons.xmark_square_fill, color: LichessColors.grey);
      } else {
        // return game.winner == null
        //     ? Icon(CupertinoIcons.equal_square_fill, color: context.lichessColors.brag)
        //     : game.winner == mySide
        //     ? Icon(CupertinoIcons.plus_square_fill, color: context.lichessColors.good)
        //     : Icon(CupertinoIcons.minus_square_fill, color: context.lichessColors.error);
        return game.winner == null
            ? Container(
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('D', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            )
            : game.winner == mySide
            ? Container(
              decoration: const BoxDecoration(color: Color(0xff54C339), shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('W', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            )
            : Container(
              decoration: const BoxDecoration(color: Color(0xffF77178), shape: BoxShape.circle),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Text('L', style: TextStyle(color: Colors.white, fontSize: 10)),
              ),
            );
      }
    }

    return _GameListTile(
      name: opponent.user?.name,
      game: game,
      color: tileColor,
      mySide: youAre,
      padding: padding,

      onTap:
          () => openGameScreen(
            context,
            game: item.game,
            orientation: item.pov,
            loadingLastMove: game.lastMove,
            lastMoveAt: game.lastMoveAt,
            gameListContext: gameListContext,
          ),
      icon: game.perf.icon,
      opponentTitle: UserFullNameWidget.player(
        user: opponent.user,
        aiLevel: opponent.aiLevel,
        // rating: opponent.rating,
        style: TextStyle(color: titleColor ?? Colors.black),
      ),
      onPressedBookmark: onPressedBookmark,
      subtitle: Text(
        opponentRating == null ? 'N/A' : '$opponentRating',
        style: const TextStyle(color: Color(0xff959494)),
      ),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [getResultIcon(game, youAre)]),
    );
  }
}

class _GameListTile extends StatelessWidget {
  const _GameListTile({
    required this.game,
    required this.mySide,
    required this.opponentTitle,
    required this.onPressedBookmark,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.color,
    this.name,
  });

  final LightArchivedGame game;
  final Side mySide;
  final Widget opponentTitle;
  final Future<void> Function(BuildContext context)? onPressedBookmark;

  final IconData? icon;
  final Widget? subtitle;
  final Widget? trailing;
  final GestureTapCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      color: color ?? Colors.white,
      child: ListTile(
        tileColor: Colors.white12,
        shape: const RoundedRectangleBorder(),
        leading:
            icon == Perf.blitz.icon
                ? Image.asset('assets/images/blitz.png', height: 20, width: 20)
                : icon == Perf.rapid.icon
                ? Image.asset('assets/images/rapid_game.png', height: 20, width: 20)
                : const SizedBox(),
        onTap: onTap,
        title: Row(
          children: [
            ClipOval(
              child: Center(
                child: RandomAvatar('$name', height: 36, width: 36),
                //  Image.asset(
                //   'assets/images/avatar.png', // Replace with your asset or use network image
                //   fit: BoxFit.cover,
                //   height: 36,
                //   width: 36,
                //   errorBuilder: (context, error, stackTrace) {
                //     return const Icon(Icons.person, color: Colors.black54, size: 24);
                //   },
                // ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                opponentTitle,
                SizedBox(
                  child:
                      subtitle != null
                          ? DefaultTextStyle.merge(
                            child: subtitle!,
                            style: TextStyle(color: textShade(context, Styles.subtitleOpacity)),
                          )
                          : null,
                ),
              ],
            ),
          ],
        ),
        onLongPress: () {
          /*showAdaptiveBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isDismissible: true,
            isScrollControlled: true,
            showDragHandle: true,
            builder:
                (context) => GameContextMenu(
                  game: game,
                  mySide: mySide,
                  showGameSummary: true,
                  opponentTitle: opponentTitle,
                  onPressedBookmark: onPressedBookmark,
                ),
          );*/
        },
        trailing: trailing,
      ),
    );
    // PlatformListTile(
    //   onTap: onTap,
    //   onLongPress: () {
    //     showAdaptiveBottomSheet<void>(
    //       context: context,
    //       useRootNavigator: true,
    //       isDismissible: true,
    //       isScrollControlled: true,
    //       showDragHandle: true,
    //       builder:
    //           (context) => GameContextMenu(
    //             game: game,
    //             mySide: mySide,
    //             showGameSummary: true,
    //             opponentTitle: opponentTitle,
    //             onPressedBookmark: onPressedBookmark,
    //           ),
    //     );
    //   },
    //   leading: icon != null ? Icon(icon) : null,
    //   title: opponentTitle,
    //   subtitle:
    //       subtitle != null
    //           ? DefaultTextStyle.merge(
    //             child: subtitle!,
    //             style: TextStyle(color: textShade(context, Styles.subtitleOpacity)),
    //           )
    //           : null,
    //   trailing: trailing,
    //   padding: padding,
    // );
  }
}

class GameContextMenu extends ConsumerWidget {
  const GameContextMenu({
    required this.game,
    required this.mySide,
    required this.opponentTitle,
    required this.onPressedBookmark,
    required this.showGameSummary,
  });

  final LightArchivedGame game;
  final Side mySide;
  final Widget opponentTitle;
  final Future<void> Function(BuildContext context)? onPressedBookmark;

  final bool showGameSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orientation = mySide;

    final customColors = Theme.of(context).extension<CustomColors>();

    final isLoggedIn = ref.watch(isLoggedInProvider);

    return BottomSheetScrollableContainer(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ).add(const EdgeInsets.only(bottom: 8.0)),
          child: Text(
            context.l10n.resVsX(
              game.white.fullName(context.l10n),
              game.black.fullName(context.l10n),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5),
          ),
        ),
        if (showGameSummary)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).add(const EdgeInsets.only(bottom: 8.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (game.lastFen != null)
                        BoardThumbnail(
                          size: constraints.maxWidth - (constraints.maxWidth / 1.618),
                          fen: game.lastFen!,
                          orientation: mySide,
                          lastMove: game.lastMove,
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${game.clockDisplay} • ${game.rated ? context.l10n.rated : context.l10n.casual}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    _dateFormatter.format(game.lastMoveAt),
                                    style: TextStyle(
                                      color: textShade(context, Styles.subtitleOpacity),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (game.lastFen != null)
                                Text(
                                  gameStatusL10n(
                                    context,
                                    variant: game.variant,
                                    status: game.status,
                                    lastPosition: Position.setupPosition(
                                      game.variant.rule,
                                      Setup.parseFen(game.lastFen!),
                                    ),
                                    winner: game.winner,
                                  ),
                                  style: TextStyle(
                                    color:
                                        game.winner == null
                                            ? customColors?.brag
                                            : game.winner == mySide
                                            ? customColors?.good
                                            : customColors?.error,
                                  ),
                                ),
                              if (game.opening != null)
                                Text(
                                  game.opening!.name,
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: textShade(context, Styles.subtitleOpacity),
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        /*BottomSheetContextMenuAction(
          icon: Icons.biotech,
          onPressed:
              game.variant.isReadSupported
                  ? () {
                    Navigator.of(context).push(
                      AnalysisScreen.buildRoute(
                        context,
                        AnalysisOptions(orientation: orientation, gameId: game.id),
                      ),
                    );
                  }
                  : () {
                    showPlatformSnackbar(
                      context,
                      'This variant is not supported yet.',
                      type: SnackBarType.info,
                    );
                  },
          child: Text(context.l10n.gameAnalysis),
        ),*/
        if (isLoggedIn && onPressedBookmark != null)
          BottomSheetContextMenuAction(
            onPressed: () => onPressedBookmark?.call(context),
            icon: game.isBookmarked ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
            closeOnPressed: true,
            child: Text(game.isBookmarked ? 'Unbookmark this game' : context.l10n.bookmarkThisGame),
          ),
        if (!isTabletOrLarger(context)) ...[
          BottomSheetContextMenuAction(
            onPressed: () {
              launchShareDialog(context, uri: lichessUri('/${game.id}/${orientation.name}'));
            },
            icon:
                Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoIcons.share
                    : Icons.share,
            child: Text(context.l10n.mobileShareGameURL),
          ),
          BottomSheetContextMenuAction(
            icon: Icons.gif,
            child: Text(context.l10n.gameAsGIF),
            onPressed: () async {
              try {
                final (gif, _) = await ref
                    .read(gameShareServiceProvider)
                    .gameGif(game.id, orientation);
                if (context.mounted) {
                  launchShareDialog(
                    context,
                    files: [gif],
                    subject:
                        '${game.perf.title} • ${context.l10n.resVsX(game.white.fullName(context.l10n), game.black.fullName(context.l10n))}',
                  );
                }
              } catch (e) {
                debugPrint(e.toString());
                if (context.mounted) {
                  showPlatformSnackbar(context, 'Failed to get GIF', type: SnackBarType.error);
                }
              }
            },
          ),
          BottomSheetContextMenuAction(
            icon: Icons.text_snippet,
            child: Text('PGN: ${context.l10n.downloadAnnotated}'),
            onPressed: () async {
              try {
                final pgn = await ref.read(gameShareServiceProvider).annotatedPgn(game.id);
                if (context.mounted) {
                  launchShareDialog(context, text: pgn);
                }
              } catch (e) {
                if (context.mounted) {
                  showPlatformSnackbar(context, 'Failed to get PGN', type: SnackBarType.error);
                }
              }
            },
          ),
          BottomSheetContextMenuAction(
            icon: Icons.text_snippet,
            // TODO improve translation
            child: Text('PGN: ${context.l10n.downloadRaw}'),
            onPressed: () async {
              try {
                final pgn = await ref.read(gameShareServiceProvider).rawPgn(game.id);
                if (context.mounted) {
                  launchShareDialog(context, text: pgn);
                }
              } catch (e) {
                if (context.mounted) {
                  showPlatformSnackbar(context, 'Failed to get PGN', type: SnackBarType.error);
                }
              }
            },
          ),
        ],
      ],
    );
  }
}
