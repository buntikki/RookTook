// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:rooktook/src/view/wallet/provider/wallet_provider.dart';

final _border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: const BorderSide(color: Colors.grey),
);

class WalletAddCoinsPage extends ConsumerStatefulWidget {
  const WalletAddCoinsPage({super.key});

  @override
  ConsumerState<WalletAddCoinsPage> createState() => _WalletAddCoinsPageState();
}

class _WalletAddCoinsPageState extends ConsumerState<WalletAddCoinsPage> {
  final amountController = TextEditingController(text: '500');
  int amount = 500;
  @override
  void initState() {
    super.initState();
    amountController.addListener(() {
      final int parsedAmount = int.parse(
        amountController.text.trim().isEmpty ? '0' : amountController.text.trim(),
      );
      amount = parsedAmount > 1000 ? 1000 : parsedAmount;
      setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  double calculateGst() {
    return (amount * 28) / 100;
  }

  int getCoinsWithoutGST(int conversionRate) {
    return ((amount - calculateGst()) * conversionRate).toInt();
  }

  int getTotalCoins(int conversionRate) {
    return amount * conversionRate;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletProvider);
    final conversion = state.rechargeConversionRate;
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent, title: const Text('Add Silver Coin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 40,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff2B2D30),
                border: Border.all(color: const Color(0xff464A4F), width: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      spacing: 16,
                      children: [
                        SvgPicture.asset(
                          'assets/images/svg/silver_coin.svg',
                          height: 40,
                          width: 40,
                        ),
                        Column(
                          children: [
                            Text(
                              '${state.walletInfo.silverCoins}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                            ),
                            const Text(
                              'Current Silver coins',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Color(0xff7D8082),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xff2B291F),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                      border: Border(top: BorderSide(color: Color(0xff464A4F), width: .5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '₹1 = ${conversion.value} Silver Coins',
                      style: const TextStyle(color: Color(0xff959494)),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select amount',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xffEFEDED)),
                ),
                TextField(
                  controller: amountController,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  style: const TextStyle(fontSize: 16),
                  onChanged: (value) {
                    final int parsedValue = int.parse(value.isEmpty ? '0' : value.trim());
                    amountController.text = parsedValue > 1000 ? '1000' : value;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    border: _border,
                    enabledBorder: _border,
                    errorBorder: _border,
                    focusedBorder: _border,
                    focusedErrorBorder: _border,
                    hintText: 'Enter the amount',
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                Row(
                  spacing: 8,
                  children: List.generate(4, (index) {
                    final List<int> values = [10, 20, 50, 100];
                    final value = values[index];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          amountController.text = '$value';
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xff2B2D30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xff464A4F)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '₹$value',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xffEFEDED),
                              height: 0,
                            ),
                            textScaler: TextScaler.noScaling,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF4F4F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  Column(
                    spacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('You Pay', style: TextStyle(color: Colors.black)),
                            Text(
                              '₹$amount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('GST (28%)', style: TextStyle(color: Colors.black)),
                            Text(
                              '₹ -${calculateGst()}',
                              style: const TextStyle(color: Color(0xffF77178)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'You Get',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  Column(
                    spacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Silver Coins', style: TextStyle(color: Color(0xff9A710A))),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                                Text(
                                  '${getCoinsWithoutGST(conversion.value)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bonus Silver Coins', style: TextStyle(color: Colors.black)),
                            Row(
                              spacing: 4,
                              children: [
                                SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                                Text(
                                  '${getTotalCoins(conversion.value) - getCoinsWithoutGST(conversion.value)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff54C339),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xffFCEABD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Silver Coins',
                          style: TextStyle(color: Color(0xff222222), fontWeight: FontWeight.w600),
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            SvgPicture.asset('assets/images/svg/silver_coin.svg'),
                            Text(
                              '${getTotalCoins(conversion.value)}',
                              style: const TextStyle(
                                color: Color(0xff222222),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MaterialButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          height: 54,
          color: const Color(0xff54C339),
          onPressed: () async {
            final provider = ref.read(walletProvider.notifier);
            final phoneNumber = await provider.getPhoneNumber();
            if (phoneNumber == null) {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: const Color(0xFF1A1F23),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                context: context,
                builder:
                    (context) => PhoneNumberSheet(
                      onPressed: (value) {
                        provider.savePhoneNumber(value);
                        provider.createPaymentGateway(
                          amount: amount,
                          context: context,
                          phoneNumber: value,
                        );
                      },
                    ),
              );
            } else {
              ref
                  .read(walletProvider.notifier)
                  .createPaymentGateway(amount: amount, context: context, phoneNumber: phoneNumber);
            }
          },
          child: Text(
            'Proceed to pay'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class PhoneNumberSheet extends StatefulWidget {
  const PhoneNumberSheet({super.key, required this.onPressed});
  final void Function(String phonenUmber) onPressed;

  @override
  State<PhoneNumberSheet> createState() => _PhoneNumberSheetState();
}

class _PhoneNumberSheetState extends State<PhoneNumberSheet> {
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 28),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Enter Phone Number',
              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xffEFEDED), fontSize: 16),
            ),
            TextFormField(
              style: const TextStyle(fontSize: 16, color: Color(0xffEFEDED)),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              controller: phoneController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Phone number can't be empty";
                }
                if (value!.length < 10) {
                  return 'Phone number is incomplete';
                }
                return null;
              },
              decoration: InputDecoration(
                isDense: true,
                border: _border,
                counterText: '',
                enabledBorder: _border,
                errorBorder: _border,
                focusedBorder: _border,
                focusedErrorBorder: _border,
                hintText: 'xxxxxxxxxx',
                prefixIconConstraints: const BoxConstraints.tightFor(width: 44),
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xff7D8082)),
                prefixIcon: const Center(
                  child: Text('+91', style: TextStyle(fontSize: 16, color: Color(0xffEFEDED))),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            MaterialButton(
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              height: 54,
              color: const Color(0xff54C339),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  widget.onPressed(phoneController.text);
                }
              },
              child: const Text('SUBMIT', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
