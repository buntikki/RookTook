import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_card.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = ['All Events', 'My Events'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Ignore intermediate state

      _handleApiCallOnTabSwitch(_tabController.index);
    });
  }

  void _handleApiCallOnTabSwitch(int index) {
    if (index == 0) {
      ref.invalidate(fetchTournamentsProvider);
    } else {
      ref.invalidate(fetchUserTournamentsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fetchPr = ref.watch(fetchTournamentsProvider);
    final fetchUserPr = ref.watch(fetchUserTournamentsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13191D),
        elevation: 0,
        automaticallyImplyLeading: false,

        // title: const Padding(
        //   padding: EdgeInsets.symmetric(vertical: 16.0),
        //   child: Text('Tournament', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        // ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(top: 0),
            child: const Text(
              'Tournament',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff464a4f), width: .5),
            ),
            child: TabBar(
              indicatorWeight: 0,
              indicatorPadding: const EdgeInsets.all(4),
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              controller: _tabController,
              labelColor: Colors.black,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.bricolageGrotesque().fontFamily,
              ),
              tabs: List.generate(tabs.length, (index) {
                return Tab(text: tabs[index]);
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                fetchPr.when(
                  data:
                      (data) => BuildTournamentList(
                        tournaments: data,
                        onRefresh: () {
                          ref.invalidate(fetchTournamentsProvider);
                        },
                      ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
                fetchUserPr.when(
                  data:
                      (data) => BuildMyTournamentList(
                        tournaments: data,
                        onRefresh: () {
                          ref.invalidate(fetchUserTournamentsProvider);
                        },
                      ),
                  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
                // duplicate for now
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuildTournamentList extends StatelessWidget {
  const BuildTournamentList({super.key, required this.tournaments, required this.onRefresh});
  final List<Tournament> tournaments;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        onRefresh();
      },
      child:
          tournaments.isEmpty
              ? const Center(child: Text('No tournaments right now'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tournaments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  return TournamentCard(tournament: tournament, index: index);
                },
              ),
    );
  }
}

class BuildMyTournamentList extends StatelessWidget {
  const BuildMyTournamentList({super.key, required this.tournaments, required this.onRefresh});
  final List<Tournament> tournaments;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final List<Tournament> activeTournaments =
        tournaments
            .where(
              (element) =>
                  DateTime.fromMillisecondsSinceEpoch(element.endTime).isAfter(DateTime.now()),
            )
            .toList();
    final List<Tournament> endedTournaments =
        tournaments
            .where(
              (element) =>
                  DateTime.fromMillisecondsSinceEpoch(element.endTime).isBefore(DateTime.now()),
            )
            .toList();
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        onRefresh();
      },
      child:
          tournaments.isEmpty
              ? const Center(child: Text('No tournaments right now'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeTournaments.isNotEmpty)
                      Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Events',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          ListView.separated(
                            itemCount: activeTournaments.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tournament = activeTournaments[index];
                              return TournamentCard(
                                tournament: tournament,
                                index: index,
                                isShowJoinedTag: false,
                              );
                            },
                          ),
                          const Divider(color: Color(0xFF2B2D30), thickness: .5),
                        ],
                      ),
                    if (endedTournaments.isNotEmpty)
                      Column(
                        spacing: 16,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Past Events',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                          ListView.separated(
                            itemCount: endedTournaments.length > 10 ? 10 : endedTournaments.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final tournament = endedTournaments[index];
                              return TournamentCard(
                                tournament: tournament,
                                index: index,
                                isShowJoinedTag: false,
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
