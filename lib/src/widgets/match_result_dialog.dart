import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/game/game.dart';
import 'package:lichess_mobile/src/model/game/game_controller.dart';
import 'package:lichess_mobile/src/model/game/game_status.dart';
import 'package:lichess_mobile/src/model/game/playable_game.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/view/game/status_l10n.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';
import 'package:random_avatar/random_avatar.dart';

class MatchResultDialog extends ConsumerStatefulWidget {
  const MatchResultDialog({required this.id, required this.onNewOpponentCallback, super.key});

  final GameFullId id;

  /// Callback to load a new opponent.
  final void Function(PlayableGame game) onNewOpponentCallback;

  @override
  ConsumerState<MatchResultDialog> createState() => _MatchResultDialogState();
}

class _MatchResultDialogState extends ConsumerState<MatchResultDialog> {
  late Timer _buttonActivationTimer;
  bool _activateButtons = false;

  @override
  void initState() {
    _buttonActivationTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _activateButtons = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _buttonActivationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrlProvider = gameControllerProvider(widget.id);
    final gameState = ref.watch(ctrlProvider).requireValue;
    final BaseGame game;

    game = gameState.game;

    return Dialog(
      backgroundColor: const Color(0xff2B2D30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            if (game.winner != null)
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: " ${game.winner == Side.white ? 'White' : 'Black'}",
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const TextSpan(
                      text: ' WINS',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xff54C339),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              )
            else
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "It's a", style: TextStyle(fontSize: 24, color: Colors.white)),
                    TextSpan(
                      text: ' DRAW',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xff54C339),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              gameStatusL10n(
                context,
                variant: game.meta.variant,
                status: game.status,
                lastPosition: game.lastPosition,
                winner: game.winner,
                isThreefoldRepetition: game.isThreefoldRepetition,
              ),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      RandomAvatar('${gameState.game.me?.user?.name}', height: 70, width: 70),
                      const SizedBox(height: 8),
                      Text(
                        '${gameState.game.me?.user?.name}',maxLines: 1,overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 120, child: Divider()),

                      if (game.status.value >= GameStatus.mate.value)
                        Text(
                          game.winner == null
                              ? '½-½'
                              : game.winner == game.youAre
                              ? '1-0'
                              : '0-1',
                          style: const TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      const SizedBox(width: 120, child: Divider()),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      RandomAvatar('${gameState.game.opponent?.user?.name}', height: 70, width: 70),
                      const SizedBox(height: 8),
                      Text(
                        '${gameState.game.opponent?.user?.name}',maxLines: 1,overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Visibility(
              visible: game.me?.ratingDiff != null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Rating', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 12),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xffFFF9E5),
                        // borderRadius: BorderRadius.circular(8.0),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: game.me?.ratingDiff == null
                          ? const Icon(Icons.remove,color: Colors.blue,) // or a placeholder widget
                          : SvgPicture.asset(
                        game.me!.ratingDiff! < 0
                            ? 'assets/images/Arrow_Down.svg'
                            : 'assets/images/Arrow_Up.svg',
                      ),
                    ),
                    // const Icon(Icons.bolt, color: Colors.amber, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      '${game.me!.rating ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      game.me?.ratingDiff == null
                          ? '' // or '±0' or '—' or any placeholder text you prefer
                          : game.me!.ratingDiff! < 0
                          ? '${game.me?.ratingDiff}'
                          : '+${game.me?.ratingDiff}',
                      style: TextStyle(
                        color: game.me?.ratingDiff == null
                            ? Colors.grey // or your neutral color
                            : game.me!.ratingDiff! < 0
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 400),
              firstCurve: Curves.easeOutExpo,
              secondCurve: Curves.easeInExpo,
              sizeCurve: Curves.easeInOut,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Text('Your opponent has offered a rematch', textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FatButton(
                          semanticsLabel: context.l10n.rematch,
                          child: const Text('Accept rematch'),
                          onPressed: () {
                            ref.read(ctrlProvider.notifier).proposeOrAcceptRematch();
                          },
                        ),
                        SecondaryButton(
                          semanticsLabel: context.l10n.rematch,
                          child: const Text('Decline'),
                          onPressed: () {
                            ref.read(ctrlProvider.notifier).declineRematch();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState:
                  gameState.game.opponent?.offeringRematch ?? false
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
            ),
            if (gameState.game.me?.offeringRematch == true)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(ctrlProvider.notifier).declineRematch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff585B5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text(
                    'Cancel Rematch',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              )
            else if (gameState.canOfferRematch)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _activateButtons &&
                              gameState.game.opponent?.onGame == true &&
                              gameState.game.opponent?.offeringRematch != true
                          ? () {
                            ref.read(ctrlProvider.notifier).proposeOrAcceptRematch();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff585B5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text(
                    'REMATCH',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (gameState.canGetNewOpponent)
              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed:
                      _activateButtons
                          ? () {
                            Navigator.of(context).popUntil((route) => route is! PopupRoute);
                            widget.onNewOpponentCallback(gameState.game);
                          }
                          : null,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff585B5E),

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text(
                    'NEW OPPONENT',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
