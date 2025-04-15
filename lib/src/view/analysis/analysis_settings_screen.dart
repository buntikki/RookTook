import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/analysis/analysis_controller.dart';
import 'package:rooktook/src/model/analysis/analysis_preferences.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/analysis/stockfish_settings.dart';
import 'package:rooktook/src/view/opening_explorer/opening_explorer_settings.dart';
import 'package:rooktook/src/widgets/adaptive_bottom_sheet.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/platform_scaffold.dart';
import 'package:rooktook/src/widgets/settings.dart';

class AnalysisSettingsScreen extends ConsumerWidget {
  const AnalysisSettingsScreen(this.options);

  final AnalysisOptions options;

  static Route<dynamic> buildRoute(BuildContext context, {required AnalysisOptions options}) {
    return buildScreenRoute(
      context,
      screen: AnalysisSettingsScreen(options),
      title: context.l10n.settingsSettings,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrlProvider = analysisControllerProvider(options);
    final prefs = ref.watch(analysisPreferencesProvider);
    final asyncState = ref.watch(ctrlProvider);

    switch (asyncState) {
      case AsyncData(:final value):
        return PlatformScaffold(
          appBarTitle: Text(context.l10n.settingsSettings),
          body: ListView(
            children: [
              ListSection(
                children: [
                  SwitchSettingTile(
                    title: Text(context.l10n.inlineNotation),
                    value: prefs.inlineNotation,
                    onChanged:
                        (value) =>
                            ref.read(analysisPreferencesProvider.notifier).toggleInlineNotation(),
                  ),
                  SwitchSettingTile(
                    // TODO: translate
                    title: const Text('Small board'),
                    value: prefs.smallBoard,
                    onChanged:
                        (value) =>
                            ref.read(analysisPreferencesProvider.notifier).toggleSmallBoard(),
                  ),
                ],
              ),
              if (value.isComputerAnalysisAllowed)
                ListSection(
                  header: SettingsSectionTitle(context.l10n.computerAnalysis),
                  children: [
                    SwitchSettingTile(
                      title: Text(context.l10n.enable),
                      value: prefs.enableComputerAnalysis,
                      onChanged: (_) {
                        ref.read(ctrlProvider.notifier).toggleComputerAnalysis();
                      },
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState:
                          value.isComputerAnalysisAllowedAndEnabled
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        children: [
                          SwitchSettingTile(
                            title: Text(context.l10n.evaluationGauge),
                            value: prefs.showEvaluationGauge,
                            onChanged:
                                (value) =>
                                    ref
                                        .read(analysisPreferencesProvider.notifier)
                                        .toggleShowEvaluationGauge(),
                          ),
                          SwitchSettingTile(
                            title: Text(context.l10n.toggleGlyphAnnotations),
                            value: prefs.showAnnotations,
                            onChanged:
                                (_) =>
                                    ref
                                        .read(analysisPreferencesProvider.notifier)
                                        .toggleAnnotations(),
                          ),
                          SwitchSettingTile(
                            title: Text(context.l10n.mobileShowComments),
                            value: prefs.showPgnComments,
                            onChanged:
                                (_) =>
                                    ref
                                        .read(analysisPreferencesProvider.notifier)
                                        .togglePgnComments(),
                          ),
                          SwitchSettingTile(
                            title: Text(context.l10n.bestMoveArrow),
                            value: prefs.showBestMoveArrow,
                            onChanged:
                                (value) =>
                                    ref
                                        .read(analysisPreferencesProvider.notifier)
                                        .toggleShowBestMoveArrow(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState:
                    value.isComputerAnalysisAllowedAndEnabled
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: StockfishSettingsWidget(
                  onSetEngineSearchTime: (value) {
                    ref.read(ctrlProvider.notifier).setEngineSearchTime(value);
                  },
                  onSetEngineCores: (value) {
                    ref.read(ctrlProvider.notifier).setEngineCores(value);
                  },
                  onSetNumEvalLines: (value) {
                    ref.read(ctrlProvider.notifier).setNumEvalLines(value);
                  },
                ),
              ),
              ListSection(
                children: [
                  PlatformListTile(
                    title: Text(context.l10n.openingExplorer),
                    onTap:
                        () => showAdaptiveBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          isDismissible: true,
                          builder: (_) => const OpeningExplorerSettings(),
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      case AsyncError(:final error):
        debugPrint('Error loading analysis: $error');
        return const SizedBox.shrink();
      case _:
        return const CenterLoadingIndicator();
    }
  }
}
