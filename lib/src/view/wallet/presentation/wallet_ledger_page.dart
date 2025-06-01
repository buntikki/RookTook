import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/view/wallet/presentation/wallet_page.dart';
import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';

class WalletLedgerPage extends ConsumerStatefulWidget {
  const WalletLedgerPage({super.key});

  @override
  ConsumerState<WalletLedgerPage> createState() => _WalletLedgerPageState();
}

class _WalletLedgerPageState extends ConsumerState<WalletLedgerPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(fetchWalletPageDetails);
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(walletProvider).ledgerList;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: const Text('Ledger', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          final ledger = list.reversed.toList()[index];
          return LedgerTile(isBorder: true, radius: 12, ledger: ledger);
        },
      ),
    );
  }
}
