import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomPieceSet {
  static const String basePath = 'assets/pieces/custom'; // Change path accordingly

  static final Map<PieceKind, AssetImage> assets = {
    PieceKind.whiteKing: const AssetImage('$basePath/whiteKing.png'),
    PieceKind.whiteQueen: const AssetImage('$basePath/whiteQueen.png'),
    PieceKind.whiteRook: const AssetImage('$basePath/whiteRook.png'),
    PieceKind.whiteBishop: const AssetImage('$basePath/whiteBishop.png'),
    PieceKind.whiteKnight: const AssetImage('$basePath/whiteKnight.png'),
    PieceKind.whitePawn: const AssetImage('$basePath/whitePawn.png'),
    PieceKind.blackKing: const AssetImage('$basePath/blackKing.png'),
    PieceKind.blackQueen: const AssetImage('$basePath/blackQueen.png'),
    PieceKind.blackRook: const AssetImage('$basePath/blackRook.png'),
    PieceKind.blackBishop: const AssetImage('$basePath/blackBishop.png'),
    PieceKind.blackKnight: const AssetImage('$basePath/blackKnight.png'),
    PieceKind.blackPawn: const AssetImage('$basePath/blackPawn.png'),
  };

  static AssetImage get(PieceKind kind) => assets[kind]!;
}

