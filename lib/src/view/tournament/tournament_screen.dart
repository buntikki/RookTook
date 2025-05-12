import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rooktook/src/model/tournament/Tournament.dart';
import 'package:rooktook/src/view/tournament/tournament_detail_screen.dart';

class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key});

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends ConsumerState<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> tournaments = List.generate(6, (index) {
    return {
      'title': 'Chess Tournament ',
      'entryFee': 200,
      'userCoins': 1000,
      'date': 'Apr 11, 2025',
      'seats': '12/20 Seats Left',
    };
  });

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13191D),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Tournament',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  _buildTabButton(
                    0,
                    'All Events'
                  ),
                  _buildTabButton(
                    1,
                    'My Events'
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTournamentList(),
          _buildTournamentList(), // duplicate for now
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            // filterData(index);
          });
        },
        child: Container(
          height: 40.0,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8.0),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<TournamentDetailScreen>(
                builder: (_) => TournamentDetailScreen(
                  tournament: Tournament(
                    title: 'Tournament $index',
                    entryFee: 100 + index,
                    reward: 250 +index,
                    date: 'Apr 1$index, 2025',
                    seatsLeft: '1$index/20 Seats Left',
                    bannerImage: 'assets/images/chess_tournament_banner.png',
                  ),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2B2D30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/puzzle_board.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tournament['title']} $index',
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SvgPicture.asset('assets/images/svg/silver_coin.svg', height: 18.0),
                              const SizedBox(width: 4),
                              Text(
                                "${tournament['entryFee']} ",
                                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 16.0,),
                              ),
                              const Text(
                                'Coin (Entry Fee)',
                                style: TextStyle(color: Colors.white70,fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1.0,),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset('assets/images/svg/gold_coin.svg', height: 18.0),
                    const SizedBox(width: 4),
                    Text("${tournament['userCoins']}", style: const TextStyle(color: Color(0xffD4AA40))),
                    const SizedBox(width: 12),
                    SvgPicture.asset('assets/images/svg/tournament_clock.svg', height: 18.0),
                    const SizedBox(width: 4),
                    Text(tournament['date'] as String, style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 12),
                    SvgPicture.asset('assets/images/svg/participants.svg', height: 18.0),
                    const SizedBox(width: 4),
                    Text(tournament['seats'] as String, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
