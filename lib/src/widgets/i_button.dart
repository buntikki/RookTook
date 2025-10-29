import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IButton extends StatelessWidget {
  const IButton({super.key, required this.text, required this.title});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xff939393), height: 24),
                  Text(text),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
      child: SvgPicture.asset('assets/images/svg/info.svg', height: 16, width: 16),
    );
  }
}
