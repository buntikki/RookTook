import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:rooktook/src/model/tournament/Tournament.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_card.dart';
import 'package:rooktook/src/view/tournament/pages/tournament_detail_screen.dart';
import 'package:rooktook/src/view/tournament/provider/tournament_provider.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<String> tabs = ['All Events', 'My Events'];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fetchPr = ref.watch(fetchTournamentsProvider);
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
      body: fetchPr.when(
        data:
            (data) => Column(
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
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2D30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff464a4f), width: .5),
                  ),
                  child: Row(
                    children: List.generate(tabs.length, (index) {
                      final String tab = tabs[index];
                      return Expanded(child: _buildTabButton(index, tab));
                    }),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTournamentList(data),
                      _buildTournamentList([]), // duplicate for now
                    ],
                  ),
                ),
              ],
            ),
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const Center(child: const CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(_selectedIndex);
          // filterData(index);
        });
      },
      child: Container(
        height: 40.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentList(List<Tournament> tournaments) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        ref.read(fetchTournamentsProvider);
      },
      child: ListView.separated(
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
