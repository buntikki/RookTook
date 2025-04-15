import 'dart:async';

import 'package:dartchess/dartchess.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:rooktook/src/model/engine/engine.dart';
import 'package:stockfish/stockfish.dart';

class FakeStockfishFactory extends StockfishFactory {
  const FakeStockfishFactory();

  @override
  Future<Stockfish> call() async => Future.value(FakeStockfish());
}

/// A fake implementation of [Stockfish].
class FakeStockfish implements Stockfish {
  FakeStockfish();

  final _state = ValueNotifier<StockfishState>(StockfishState.ready);
  final _stdoutController = StreamController<String>();

  Position? _position;

  @override
  set stdin(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    switch (parts.first) {
      case 'uci':
        _stdoutController.add('uciok\n');
      case 'isready':
        _stdoutController.add('readyok\n');
      case 'position':
        if (parts.length > 1 && parts[1] == 'fen') {
          final movesPartIndex = parts.indexWhere((p) => p == 'moves');
          if (parts.length > 2) {
            _position = Position.setupPosition(
              Rule.chess,
              Setup.parseFen(
                parts.sublist(2, movesPartIndex != -1 ? movesPartIndex : null).join(' '),
              ),
            );
          }
          if (movesPartIndex != -1) {
            for (var i = movesPartIndex + 1; i < parts.length; i++) {
              final move = Move.parse(parts[i]);
              if (move != null) {
                _position = _position!.play(move);
              }
            }
          }
        }
      case 'go':
        if (parts.length > 1 && parts[1] == 'movetime') {
          if (parts.length > 2) {
            final moveTime = int.tryParse(parts[2]);
            if (moveTime != null) {
              // Emits only 2 info lines, because of the throttler in evaluation service there is no
              // need to emit more.
              // Only the last line will be used after waiting the throttle duration. Which means
              // the depth will always be 15 before throttle delay and 16 after.
              // The cp value will always 23.
              for (var i = 1; i < 3; i++) {
                _stdoutController.add(
                  'info depth ${14 + i} seldepth 8 multipv 1 score cp ${_position?.turn == Side.black ? '-' : ''}23 nodes ${359 * (i + 14)} nps 359000 hashfull 0 tbhits 0 time ${100 * (i + 14)} pv e2e4 e7e5 g1f3 b8c6 f1b5 g8f6\n',
                );
              }
              _stdoutController.add('bestmove e2e4 ponder e7e5\n');
            }
          }
        }
    }
  }

  @override
  void dispose() {}

  @override
  ValueListenable<StockfishState> get state => _state;

  @override
  Stream<String> get stdout => _stdoutController.stream;

  @override
  Completer<Stockfish>? get completer => throw UnimplementedError();
}
