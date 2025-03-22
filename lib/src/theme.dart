import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/model/settings/general_preferences.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/color_palette.dart';

const kPageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

const kProgressIndicatorTheme = ProgressIndicatorThemeData(
  // ignore: deprecated_member_use
  year2023: false,
);

const kSliderTheme = SliderThemeData(
  // ignore: deprecated_member_use
  year2023: false,
);

/// Makes the app theme based on the given [generalPrefs] and [boardPrefs] and the current [context].
({ThemeData light, ThemeData dark}) makeAppTheme(
  BuildContext context,
  GeneralPrefs generalPrefs,
  BoardPrefs boardPrefs,
) {
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

  if (generalPrefs.backgroundColor == null && generalPrefs.backgroundImage == null) {
    return _makeDefaultTheme(context, generalPrefs, boardPrefs, isIOS);
  } else {
    return _makeBackgroundImageTheme(
      context,
      baseTheme:
          generalPrefs.backgroundImage?.baseTheme ?? generalPrefs.backgroundColor!.$1.baseTheme,
      seedColor:
          generalPrefs.backgroundImage?.seedColor ??
          (generalPrefs.backgroundColor!.$2
              ? generalPrefs.backgroundColor!.$1.darker
              : generalPrefs.backgroundColor!.$1.color),
      isIOS: isIOS,
      isBackgroundImage: generalPrefs.backgroundImage != null,
    );
  }
}

/// A custom theme extension that adds lichess custom properties to the theme.
@immutable
class CustomTheme extends ThemeExtension<CustomTheme> {
  const CustomTheme({required this.rowEven, required this.rowOdd});

  final Color rowEven;
  final Color rowOdd;

  @override
  CustomTheme copyWith({Color? rowEven, Color? rowOdd}) {
    return CustomTheme(rowEven: rowEven ?? this.rowEven, rowOdd: rowOdd ?? this.rowOdd);
  }

  @override
  CustomTheme lerp(ThemeExtension<CustomTheme>? other, double t) {
    if (other is! CustomTheme) {
      return this;
    }
    return CustomTheme(
      rowEven: Color.lerp(rowEven, other.rowEven, t) ?? rowEven,
      rowOdd: Color.lerp(rowOdd, other.rowOdd, t) ?? rowOdd,
    );
  }
}

/// A [BuildContext] extension that provides the [lichessTheme] property.
extension CustomThemeBuildContext on BuildContext {
  CustomTheme get _defaultLichessTheme => CustomTheme(
    rowEven: ColorScheme.of(this).surfaceContainer,
    rowOdd: ColorScheme.of(this).surfaceContainerHigh,
  );

  CustomTheme get lichessTheme => Theme.of(this).extension<CustomTheme>() ?? _defaultLichessTheme;
}

// --

({ThemeData light, ThemeData dark}) _makeDefaultTheme(
  BuildContext context,
  GeneralPrefs generalPrefs,
  BoardPrefs boardPrefs,
  bool isIOS,
) {
  final boardTheme = boardPrefs.boardTheme;
  final systemScheme = getDynamicColorSchemes();
  final hasSystemColors = systemScheme != null && generalPrefs.systemColors == true;
  final defaultLight = ColorScheme.fromSeed(seedColor: boardTheme.colors.darkSquare);
  final defaultDark = ColorScheme.fromSeed(
    seedColor: boardTheme.colors.darkSquare,
    brightness: Brightness.dark,
  );

  final themeLight =
      hasSystemColors
          ? ThemeData.from(colorScheme: systemScheme.light)
          : ThemeData.from(colorScheme: defaultLight);
  final themeDark =
      hasSystemColors
          ? ThemeData.from(colorScheme: systemScheme.dark)
          : ThemeData.from(colorScheme: defaultDark);

  // Apply default font family to the themes
  final lightWithFont = themeLight.copyWith(
    textTheme: themeLight.textTheme.apply(fontFamily: 'BricolageGrotesque'),
    primaryTextTheme: themeLight.primaryTextTheme.apply(fontFamily: 'BricolageGrotesque'),
  );
  final darkWithFont = themeDark.copyWith(
    textTheme: themeDark.textTheme.apply(fontFamily: 'BricolageGrotesque'),
    primaryTextTheme: themeDark.primaryTextTheme.apply(fontFamily: 'BricolageGrotesque'),
  );

  final lightCupertino = CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: lightWithFont.colorScheme.primary,
    primaryContrastingColor: lightWithFont.colorScheme.onPrimary,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFF13191D),
    // scaffoldBackgroundColor: Colors.green,
    barBackgroundColor: const Color(0xE6F9F9F9),
    textTheme: cupertinoTextTheme(lightWithFont.colorScheme),
  );

  final darkCupertino = CupertinoThemeData(
    applyThemeToAll: true,
    primaryColor: Colors.white,
    primaryContrastingColor: darkWithFont.colorScheme.onPrimary,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xFF13191D),
    barBackgroundColor: Color(0xFF13191D),
    textTheme: cupertinoTextTheme(darkWithFont.colorScheme),
  );

  final cupertinoFloatingActionButtonTheme = FloatingActionButtonThemeData(
    backgroundColor: themeLight.colorScheme.secondaryFixedDim,
    foregroundColor: themeLight.colorScheme.onSecondaryFixedVariant,
  );

  return (
    light: lightWithFont.copyWith(
      cupertinoOverrideTheme: lightCupertino,
      splashFactory: isIOS ? NoSplash.splashFactory : null,
      cardTheme:
          isIOS
              ? CardThemeData(
                color: lightWithFont.colorScheme.surfaceContainerLowest,
                elevation: 0,
                margin: EdgeInsets.zero,
              )
              : null,
      listTileTheme: isIOS ? _cupertinoListTileTheme(lightCupertino) : null,
      bottomSheetTheme:
          isIOS
              ? BottomSheetThemeData(backgroundColor: lightCupertino.scaffoldBackgroundColor)
              : null,
      floatingActionButtonTheme: isIOS ? cupertinoFloatingActionButtonTheme : null,
      menuTheme:
          isIOS ? _makeCupertinoMenuThemeData(lightWithFont.colorScheme.surfaceContainerLowest) : null,
      pageTransitionsTheme: kPageTransitionsTheme,
      progressIndicatorTheme: kProgressIndicatorTheme,
      sliderTheme: kSliderTheme,
      extensions: [
        lichessCustomColors.harmonized(lightWithFont.colorScheme),
        if (isIOS)
          const CustomTheme(rowEven: Colors.white, rowOdd: Color.fromARGB(255, 247, 246, 245)),
      ],
    ),
    dark: darkWithFont.copyWith(
      cupertinoOverrideTheme: darkCupertino,
      splashFactory: isIOS ? NoSplash.splashFactory : null,
      cardTheme:
          isIOS
              ? CardThemeData(
                color: darkWithFont.colorScheme.surfaceContainerHigh,
                elevation: 0,
                margin: EdgeInsets.zero,
              )
              : null,
      listTileTheme: isIOS ? _cupertinoListTileTheme(darkCupertino) : null,
      bottomSheetTheme:
          isIOS
              ? BottomSheetThemeData(backgroundColor: darkCupertino.scaffoldBackgroundColor)
              : null,
      floatingActionButtonTheme: isIOS ? cupertinoFloatingActionButtonTheme : null,
      menuTheme: isIOS ? _makeCupertinoMenuThemeData(darkWithFont.colorScheme.surface) : null,
      pageTransitionsTheme: kPageTransitionsTheme,
      progressIndicatorTheme: kProgressIndicatorTheme,
      sliderTheme: kSliderTheme,
      extensions: [lichessCustomColors.harmonized(darkWithFont.colorScheme)],
    ),
  );
}

({ThemeData light, ThemeData dark}) _makeBackgroundImageTheme(
  BuildContext context, {
  required ThemeData baseTheme,
  required Color seedColor,
  required bool isIOS,
  required bool isBackgroundImage,
}) {
  final primary = baseTheme.colorScheme.primary;
  final onPrimary = baseTheme.colorScheme.onPrimary;
  
  // Apply custom font to base theme
  final baseThemeWithFont = baseTheme.copyWith(
    textTheme: baseTheme.textTheme.apply(fontFamily: 'BricolageGrotesque'),
    primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'BricolageGrotesque'),
  );
  
  final cupertinoTheme = CupertinoThemeData(
    primaryColor: primary,
    primaryContrastingColor: onPrimary,
    brightness: Brightness.dark,
    textTheme: cupertinoTextTheme(baseThemeWithFont.colorScheme),
    scaffoldBackgroundColor: Color(0xFF13191D),
    barBackgroundColor: baseThemeWithFont.colorScheme.surface.withValues(alpha: 0.6),
    applyThemeToAll: true,
  );

  final baseSurfaceAlpha = isBackgroundImage ? 0.5 : 0.3;

  final theme = baseThemeWithFont.copyWith(
    colorScheme: baseThemeWithFont.colorScheme.copyWith(
      surface: baseThemeWithFont.colorScheme.surface.withValues(alpha: baseSurfaceAlpha),
      surfaceContainerLowest: baseThemeWithFont.colorScheme.surfaceContainerLowest.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainerLow: baseThemeWithFont.colorScheme.surfaceContainerLow.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainer: baseThemeWithFont.colorScheme.surfaceContainer.withValues(alpha: baseSurfaceAlpha),
      surfaceContainerHigh: baseThemeWithFont.colorScheme.surfaceContainerHigh.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceContainerHighest: baseThemeWithFont.colorScheme.surfaceContainerHighest.withValues(
        alpha: baseSurfaceAlpha,
      ),
      surfaceDim: baseThemeWithFont.colorScheme.surfaceDim.withValues(alpha: baseSurfaceAlpha + 1),
      surfaceBright: baseThemeWithFont.colorScheme.surfaceBright.withValues(alpha: baseSurfaceAlpha - 2),
    ),
    cupertinoOverrideTheme: cupertinoTheme,
    listTileTheme: isIOS ? _cupertinoListTileTheme(cupertinoTheme) : null,
    cardTheme: isIOS ? const CardThemeData(elevation: 0, margin: EdgeInsets.zero) : null,
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor:
          isIOS
              ? lighten(baseThemeWithFont.colorScheme.surface, 0.1).withValues(alpha: 0.9)
              : baseThemeWithFont.colorScheme.surface.withValues(alpha: 0.9),
    ),
    dialogTheme: DialogThemeData(backgroundColor: baseThemeWithFont.colorScheme.surface.withValues(alpha: 0.9)),
    menuTheme:
        isIOS
            ? _makeCupertinoMenuThemeData(
              baseThemeWithFont.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
            )
            : MenuThemeData(
              style: MenuStyle(
                backgroundColor: WidgetStatePropertyAll(
                  baseThemeWithFont.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
                ),
              ),
            ),
    scaffoldBackgroundColor:Color(0xFF13191D),
    appBarTheme: baseThemeWithFont.appBarTheme.copyWith(backgroundColor: seedColor.withValues(alpha: 0.5)),
    splashFactory: isIOS ? NoSplash.splashFactory : null,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(
          backgroundColor: seedColor.withValues(alpha: 0),
        ),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      },
    ),

    progressIndicatorTheme: kProgressIndicatorTheme,
    sliderTheme: kSliderTheme,
    extensions: [lichessCustomColors.harmonized(baseThemeWithFont.colorScheme)],
  );

  return (light: theme, dark: theme);
}

MenuThemeData _makeCupertinoMenuThemeData(Color backgroundColor) {
  return MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(backgroundColor),
      elevation: const WidgetStatePropertyAll(0),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: Styles.cardBorderRadius),
      ),
    ),
  );
}

/// Makes a Cupertino text theme based on the given [colors].
CupertinoTextThemeData cupertinoTextTheme(ColorScheme colors) =>
    const CupertinoThemeData().textTheme.copyWith(
      primaryColor: Colors.white,
      textStyle: TextStyle(
        color: colors.onSurface,
        fontFamily: 'BricolageGrotesque',
        fontSize: 16,
      ),
      navTitleTextStyle: TextStyle(
        color: colors.onSurface,
        fontFamily: 'BricolageGrotesque',
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      navLargeTitleTextStyle: TextStyle(
        color: colors.onSurface,
        fontFamily: 'BricolageGrotesque',
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );

ListTileThemeData _cupertinoListTileTheme(CupertinoThemeData cupertinoTheme) => ListTileThemeData(
  titleTextStyle: cupertinoTheme.textTheme.textStyle,
  subtitleTextStyle: cupertinoTheme.textTheme.textStyle,
  leadingAndTrailingTextStyle: cupertinoTheme.textTheme.textStyle,
);
