import 'dart:ui';

import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart' show ColorScheme, Colors;
import 'package:material_color_utilities/material_color_utilities.dart';

typedef ColorSchemes = ({ColorScheme light, ColorScheme dark});

ColorSchemes? _dynamicColorSchemes;

CorePalette? _corePalette;

ChessboardColorScheme? _boardColorScheme;

/// Set the system core palette if available (android 12+ only).
///
/// It also defines the system board colors based on the core palette.
void setSystemColors(CorePalette? palette, ColorSchemes? schemes) {
  _corePalette ??= palette;
  _dynamicColorSchemes ??= schemes;

  if (palette != null) {
    _dynamicColorSchemes ??= (
      light: palette.toColorScheme(),
      dark: palette.toColorScheme(brightness: Brightness.dark),
    );

    final darkSquare = Color(0xffD0D7DD);
    final lightSquare = Colors.white;

    _boardColorScheme ??= ChessboardColorScheme(
      darkSquare: darkSquare,
      lightSquare: lightSquare,
      background: SolidColorChessboardBackground(lightSquare: lightSquare, darkSquare: darkSquare),
      whiteCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
      ),
      blackCoordBackground: SolidColorChessboardBackground(
        lightSquare: lightSquare,
        darkSquare: darkSquare,
        coordinates: true,
        orientation: Side.black,
      ),
      lastMove: HighlightDetails(solidColor: Color(0xffFFEE93)),
      selected: HighlightDetails(solidColor: Color(0xffFFEE93)),
      validMoves: Color(0xffFFEE93),
      validPremoves: Color(0xffFFEE93),
    );
  }
}

/// Get the core palette if available (android 12+ only).
CorePalette? getCorePalette() {
  return _corePalette;
}

/// Get the system color schemes based on the core palette, if available (android 12+).
ColorSchemes? getDynamicColorSchemes() {
  return _dynamicColorSchemes;
}

/// Get the board colors based on the core palette, if available (android 12+).
ChessboardColorScheme? getBoardColorScheme() {
  return _boardColorScheme;
}
