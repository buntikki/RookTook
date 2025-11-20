import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/navigation.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/view/home/home_tab_screen.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class PromoteTournamentScreen extends ConsumerStatefulWidget {
  const PromoteTournamentScreen({super.key});

  static MaterialPageRoute<dynamic> route() =>
      MaterialPageRoute<dynamic>(builder: (context) => const PromoteTournamentScreen());

  @override
  ConsumerState<PromoteTournamentScreen> createState() => _PromoteTournamentScreenState();
}

class _PromoteTournamentScreenState extends ConsumerState<PromoteTournamentScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final fetchTournamentsPr = ref.watch(fetchTournamentsProvider);
    return fetchTournamentsPr.when(
      data: (tournaments) {
        final pageCount = tournaments.length > 3 ? 3 : tournaments.length;
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/promote_tournament_bg.png')),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      buildScreenRoute<void>(context, screen: const BottomNavScaffold()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff54C339),
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xff54C339),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                const Text(
                  'Play Tournament',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const Text(
                  'Get Started with Tournament',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff8F9193),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: pageCount,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: CompeteTournamentCard(
                              promoteTournament: true,
                              width: MediaQuery.of(context).size.width,
                              tournament: tournaments[index],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: List.generate(pageCount, (index) {
                    final isActive = index == currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: isActive ? 16 : 8,
                      decoration: BoxDecoration(
                        color: const Color(0xff54C339).withValues(alpha: isActive ? 1 : .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
