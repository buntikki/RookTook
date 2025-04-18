import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomPieceSet {
  static const String basePath = 'assets/pieces/custom'; // Change path accordingly

  static final Map<PieceKind, AssetImage> assets = {
    PieceKind.whiteKing: AssetImage('$basePath/whiteKing.png'),
    PieceKind.whiteQueen: AssetImage('$basePath/whiteQueen.png'),
    PieceKind.whiteRook: AssetImage('$basePath/whiteRook.png'),
    PieceKind.whiteBishop: AssetImage('$basePath/whiteBishop.png'),
    PieceKind.whiteKnight: AssetImage('$basePath/whiteKnight.png'),
    PieceKind.whitePawn: AssetImage('$basePath/whitePawn.png'),
    PieceKind.blackKing: AssetImage('$basePath/blackKing.png'),
    PieceKind.blackQueen: AssetImage('$basePath/blackQueen.png'),
    PieceKind.blackRook: AssetImage('$basePath/blackRook.png'),
    PieceKind.blackBishop: AssetImage('$basePath/blackBishop.png'),
    PieceKind.blackKnight: AssetImage('$basePath/blackKnight.png'),
    PieceKind.blackPawn: AssetImage('$basePath/blackPawn.png'),
  };

  static AssetImage get(PieceKind kind) => assets[kind]!;
}

