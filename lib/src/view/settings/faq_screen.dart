import 'package:flutter/material.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> list;
  static Route<dynamic> buildRoute(BuildContext context, List<Map<String, String>> list) {
    return buildScreenRoute(context, screen: FAQScreen(list: list), title: 'FAQs');
  }

  const FAQScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('FAQs'),
        elevation: 0,
        leading: const BackButton(),
      ),
      body: ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(color: Colors.transparent, height: 8),
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
      ),
    );
  }
}
