import 'package:flutter/material.dart';
import 'package:rooktook/src/view/wallet/wallet_page.dart';

class WalletLedgerPage extends StatelessWidget {
  const WalletLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Ledger', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(height: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return LedgerTile(isBorder: true, radius: 12);
        },
      ),
    );
  }
}
