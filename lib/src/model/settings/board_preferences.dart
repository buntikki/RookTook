import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rooktook/l10n/l10n.dart';
import 'package:rooktook/src/model/settings/preferences_storage.dart';
import 'package:rooktook/src/styles/styles.dart';
import 'package:rooktook/src/utils/color_palette.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rooktook/src/utils/custom_piece_set.dart';

part 'board_preferences.freezed.dart';
part 'board_preferences.g.dart';

const kBoardDefaultBrightnessFilter = 1.0;
const kBoardDefaultHueFilter = 0.0;

@Riverpod(keepAlive: true)
class BoardPreferences extends _$BoardPreferences with PreferencesStorage<BoardPrefs> {
  @override
  @protected
  PrefCategory get prefCategory => PrefCategory.board;

  @override
  @protected
  BoardPrefs get defaults => BoardPrefs.defaults;

  @override
  BoardPrefs fromJson(Map<String, dynamic> json) => BoardPrefs.fromJson(json);

  @override
  BoardPrefs build() {
    return fetch();
  }

  Future<void> setPieceSet(PieceSet pieceSet) {
    return save(state.copyWith(pieceSet: pieceSet));
  }

  Future<void> setBoardTheme(BoardTheme boardTheme) async {
    await save(state.copyWith(boardTheme: boardTheme));
  }

  Future<void> setPieceShiftMethod(PieceShiftMethod pieceShiftMethod) async {
    await save(state.copyWith(pieceShiftMethod: pieceShiftMethod));
  }

  Future<void> toggleHapticFeedback() {
    return save(state.copyWith(hapticFeedback: !state.hapticFeedback));
  }

  Future<void> toggleImmersiveModeWhilePlaying() {
    return save(
      state.copyWith(immersiveModeWhilePlaying: !(state.immersiveModeWhilePlaying ?? false)),
    );
  }

  Future<void> toggleShowLegalMoves() {
    return save(state.copyWith(showLegalMoves: !state.showLegalMoves));
  }

  Future<void> toggleBoardHighlights() {
    return save(state.copyWith(boardHighlights: !state.boardHighlights));
  }

  Future<void> toggleCoordinates() {
    return save(state.copyWith(coordinates: !state.coordinates));
  }

  Future<void> toggleBorder() {
    return save(state.copyWith(showBorder: !state.showBorder));
  }

  Future<void> togglePieceAnimation() {
    return save(state.copyWith(pieceAnimation: !state.pieceAnimation));
  }

  Future<void> toggleMagnifyDraggedPiece() {
    return save(state.copyWith(magnifyDraggedPiece: !state.magnifyDraggedPiece));
  }

  Future<void> setDragTargetKind(DragTargetKind dragTargetKind) {
    return save(state.copyWith(dragTargetKind: dragTargetKind));
  }

  Future<void> setMaterialDifferenceFormat(MaterialDifferenceFormat materialDifferenceFormat) {
    return save(state.copyWith(materialDifferenceFormat: materialDifferenceFormat));
  }

  Future<void> setClockPosition(ClockPosition clockPosition) {
    return save(state.copyWith(clockPosition: clockPosition));
  }

  Future<void> toggleEnableShapeDrawings() {
    return save(state.copyWith(enableShapeDrawings: !state.enableShapeDrawings));
  }

  Future<void> setShapeColor(ShapeColor shapeColor) {
    return save(state.copyWith(shapeColor: shapeColor));
  }

  Future<void> adjustColors({double? brightness, double? hue}) {
    return save(state.copyWith(brightness: brightness ?? state.brightness, hue: hue ?? state.hue));
  }
}

@Freezed(fromJson: true, toJson: true)
class BoardPrefs with _$BoardPrefs implements Serializable {
  const BoardPrefs._();

  @Assert('brightness >= 0.2 && brightness <= 1.4, hue >= 0.0 && hue <= 360.0')
  const factory BoardPrefs({
    required PieceSet pieceSet,
    required BoardTheme boardTheme,
    bool? immersiveModeWhilePlaying,
    required bool hapticFeedback,
    required bool showLegalMoves,
    required bool boardHighlights,
    required bool coordinates,
    required bool pieceAnimation,
    @JsonKey(
      defaultValue: MaterialDifferenceFormat.materialDifference,
      unknownEnumValue: MaterialDifferenceFormat.materialDifference,
    )
    required MaterialDifferenceFormat materialDifferenceFormat,
    @JsonKey(defaultValue: ClockPosition.right, unknownEnumValue: ClockPosition.right)
    required ClockPosition clockPosition,
    @JsonKey(defaultValue: PieceShiftMethod.either, unknownEnumValue: PieceShiftMethod.either)
    required PieceShiftMethod pieceShiftMethod,

    /// Whether to enable shape drawings on the board for games and puzzles.
    @JsonKey(defaultValue: true) required bool enableShapeDrawings,
    @JsonKey(defaultValue: true) required bool magnifyDraggedPiece,
    @JsonKey(defaultValue: DragTargetKind.circle, unknownEnumValue: DragTargetKind.circle)
    required DragTargetKind dragTargetKind,
    @JsonKey(defaultValue: ShapeColor.green, unknownEnumValue: ShapeColor.green)
    required ShapeColor shapeColor,
    @JsonKey(defaultValue: false) required bool showBorder,
    @JsonKey(defaultValue: kBoardDefaultBrightnessFilter) required double brightness,
    @JsonKey(defaultValue: kBoardDefaultHueFilter) required double hue,
  }) = _BoardPrefs;

  static const defaults = BoardPrefs(
    pieceSet: PieceSet.staunty,
    boardTheme: BoardTheme.brown,
    immersiveModeWhilePlaying: false,
    hapticFeedback: true,
    showLegalMoves: true,
    boardHighlights: true,
    coordinates: true,
    pieceAnimation: true,
    materialDifferenceFormat: MaterialDifferenceFormat.materialDifference,
    clockPosition: ClockPosition.right,
    pieceShiftMethod: PieceShiftMethod.either,
    enableShapeDrawings: true,
    magnifyDraggedPiece: true,
    dragTargetKind: DragTargetKind.circle,
    shapeColor: ShapeColor.green,
    showBorder: false,
    brightness: kBoardDefaultBrightnessFilter,
    hue: kBoardDefaultHueFilter,
  );

  bool get hasColorAdjustments =>
      brightness != kBoardDefaultBrightnessFilter || hue != kBoardDefaultHueFilter;

  ChessboardSettings toBoardSettings() {
    final darkSquare = Color(0xffD0D7DD);
    final lightSquare = Colors.white;
    return ChessboardSettings(
      pieceAssets: PieceAssets(CustomPieceSet.assets),
      colorScheme: ChessboardColorScheme(
        darkSquare: darkSquare,
        lightSquare: lightSquare,
        background: SolidColorChessboardBackground(
          lightSquare: lightSquare,
          darkSquare: darkSquare,
        ),
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
      ),

      //  boardTheme.colors,
      brightness: brightness,
      hue: hue,
      border:
          showBorder
              ? BoardBorder(color: darken(boardTheme.colors.darkSquare, 0.2), width: 16.0)
              : null,
      showValidMoves: showLegalMoves,
      showLastMove: boardHighlights,
      enableCoordinates: coordinates,
      animationDuration: pieceAnimationDuration,
      dragFeedbackScale: magnifyDraggedPiece ? 2.0 : 1.0,
      dragFeedbackOffset: Offset(0.0, magnifyDraggedPiece ? -1.0 : 0.0),
      dragTargetKind: dragTargetKind,
      pieceShiftMethod: pieceShiftMethod,
      drawShape: DrawShapeOptions(enable: enableShapeDrawings, newShapeColor: shapeColor.color),
    );
  }

  factory BoardPrefs.fromJson(Map<String, dynamic> json) {
    return _$BoardPrefsFromJson(json);
  }

  Duration get pieceAnimationDuration =>
      pieceAnimation ? const Duration(milliseconds: 150) : Duration.zero;
}

/// Colors taken from lila: https://github.com/lichess-org/chessground/blob/54a7e71bf88701c1109d3b9b8106b464012b94cf/src/state.ts#L178
enum ShapeColor {
  green,
  red,
  blue,
  yellow;

  Color get color => Color(switch (this) {
    ShapeColor.green => 0x15781B,
    ShapeColor.red => 0x882020,
    ShapeColor.blue => 0x003088,
    ShapeColor.yellow => 0xe68f00,
  }).withAlpha(0xAA);
}

/// The chessboard theme.
enum BoardTheme {
  system('System', 'system'),
  blue('Blue', 'blue'),
  blue2('Blue 2', 'blue2'),
  blue3('Blue 3', 'blue3'),
  blueMarble('Blue Marble', 'blue-marble'),
  canvas('Canvas', 'canvas'),
  wood('Wood', 'wood'),
  wood2('Wood 2', 'wood2'),
  wood3('Wood 3', 'wood3'),
  wood4('Wood 4', 'wood4'),
  maple('Maple', 'maple'),
  maple2('Maple 2', 'maple2'),
  brown('Brown', 'brown'),
  leather('Leather', 'leather'),
  green('Green', 'green'),
  marble('Marble', 'marble'),
  greenPlastic('Green Plastic', 'green-plastic'),
  grey('Grey', 'grey'),
  metal('Metal', 'metal'),
  olive('Olive', 'olive'),
  newspaper('Newspaper', 'newspaper'),
  purpleDiag('Purple-Diag', 'purple-diag'),
  pinkPyramid('Pink', 'pink'),
  horsey('Horsey', 'horsey');

  final String label;
  final String gifApiName;

  const BoardTheme(this.label, this.gifApiName);

  ChessboardColorScheme get colors {
    switch (this) {
      case BoardTheme.system:
        return getBoardColorScheme() ?? ChessboardColorScheme.blue;
      case BoardTheme.blue:
        return ChessboardColorScheme.blue;
      case BoardTheme.blue2:
        return ChessboardColorScheme.blue2;
      case BoardTheme.blue3:
        return ChessboardColorScheme.blue3;
      case BoardTheme.blueMarble:
        return ChessboardColorScheme.blueMarble;
      case BoardTheme.canvas:
        return ChessboardColorScheme.canvas;
      case BoardTheme.wood:
        return ChessboardColorScheme.wood;
      case BoardTheme.wood2:
        return ChessboardColorScheme.wood2;
      case BoardTheme.wood3:
        return ChessboardColorScheme.wood3;
      case BoardTheme.wood4:
        return ChessboardColorScheme.wood4;
      case BoardTheme.maple:
        return ChessboardColorScheme.maple;
      case BoardTheme.maple2:
        return ChessboardColorScheme.maple2;
      case BoardTheme.brown:
        return ChessboardColorScheme.brown;
      case BoardTheme.leather:
        return ChessboardColorScheme.leather;
      case BoardTheme.green:
        return ChessboardColorScheme.green;
      case BoardTheme.marble:
        return ChessboardColorScheme.marble;
      case BoardTheme.greenPlastic:
        return ChessboardColorScheme.greenPlastic;
      case BoardTheme.grey:
        return ChessboardColorScheme.grey;
      case BoardTheme.metal:
        return ChessboardColorScheme.metal;
      case BoardTheme.olive:
        return ChessboardColorScheme.olive;
      case BoardTheme.newspaper:
        return ChessboardColorScheme.newspaper;
      case BoardTheme.purpleDiag:
        return ChessboardColorScheme.purpleDiag;
      case BoardTheme.pinkPyramid:
        return ChessboardColorScheme.pinkPyramid;
      case BoardTheme.horsey:
        return ChessboardColorScheme.horsey;
    }
  }

  Widget get thumbnail =>
      this == BoardTheme.system
          ? SizedBox(
            height: 44,
            width: 44 * 6,
            child: Row(
              children: [
                for (final c in const [1, 2, 3, 4, 5, 6])
                  Container(
                    width: 44,
                    color: c.isEven ? Color(0xffD0D7DD) : Colors.white,
                    // ? BoardTheme.system.colors.darkSquare
                    // : BoardTheme.system.colors.lightSquare,
                  ),
              ],
            ),
          )
          : Image.asset(
            'assets/board-thumbnails/$name.jpg',
            height: 44,
            errorBuilder: (context, o, st) => const SizedBox.shrink(),
          );
}

enum MaterialDifferenceFormat {
  materialDifference(label: 'Material difference'),
  capturedPieces(label: 'Captured pieces'),
  hidden(label: 'Hidden');

  const MaterialDifferenceFormat({required this.label});

  final String label;

  bool get visible => this != MaterialDifferenceFormat.hidden;

  String l10n(AppLocalizations l10n) => switch (this) {
    //TODO: Add l10n
    MaterialDifferenceFormat.materialDifference => materialDifference.label,
    MaterialDifferenceFormat.capturedPieces => capturedPieces.label,
    MaterialDifferenceFormat.hidden => hidden.label,
  };
}

enum ClockPosition {
  left,
  right;

  // TODO: l10n
  String get label => switch (this) {
    ClockPosition.left => 'Left',
    ClockPosition.right => 'Right',
  };
}

String dragTargetKindLabel(DragTargetKind kind) => switch (kind) {
  DragTargetKind.circle => 'Circle',
  DragTargetKind.square => 'Square',
  DragTargetKind.none => 'None',
};
