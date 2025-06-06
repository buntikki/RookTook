import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletFaqScreen extends StatefulWidget {
  const WalletFaqScreen({super.key, required this.silverFaqs, required this.goldFaqs});
  final List<Map<String, String>> silverFaqs;
  final List<Map<String, String>> goldFaqs;

  @override
  State<WalletFaqScreen> createState() => _WalletFaqScreenState();
}

class _WalletFaqScreenState extends State<WalletFaqScreen> with SingleTickerProviderStateMixin {
  late final TabController controller;
  final List<String> tabs = ['Silver Coins', 'Gold Coins'];
  int tabIndex = 0;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this, initialIndex: tabIndex);
    controller.addListener(() {
      if (controller.indexIsChanging) return; // Ignore intermediate state
      setState(() {
        tabIndex = controller.index;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Wallet FAQs'),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
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
              controller: controller,
              labelColor: Colors.black,
              labelStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: GoogleFonts.bricolageGrotesque().fontFamily,
              ),
              tabs: List.generate(tabs.length, (index) {
                return Tab(
                  icon: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/svg/${index == 0 ? 'silver' : 'gold'}_coin.svg',
                        height: 20,
                      ),
                      Text(tabs[index]),
                    ],
                  ),
                  // text: tabs[index],
                );
              }),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                WalletFaqListWidget(list: widget.silverFaqs),
                WalletFaqListWidget(list: widget.goldFaqs),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletFaqListWidget extends StatelessWidget {
  const WalletFaqListWidget({super.key, required this.list});
  final List<Map<String, String>> list;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: list.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final faq = list[index];
        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            unselectedWidgetColor: Colors.white,
            textTheme: const TextTheme(titleMedium: TextStyle(color: Colors.white)),
          ),
          child: ExpansionTile(
            expandedAlignment: Alignment.centerLeft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.transparent),
            ),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            collapsedBackgroundColor: const Color(0xFF1C1F26),
            backgroundColor: const Color(0xFF1C1F26),
            title: Text(faq['question']!, style: const TextStyle(color: Colors.white)),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(faq['answer']!, style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }
}
