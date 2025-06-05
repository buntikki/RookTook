import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/view/shop/presentation/shop_screen.dart';
import 'package:rooktook/src/view/shop/provider/shop_provider.dart';

class CreateOrderFormScreen extends ConsumerStatefulWidget {
  const CreateOrderFormScreen({super.key, required this.item});
  final ShopItemModel item;

  @override
  ConsumerState<CreateOrderFormScreen> createState() => _CreateOrderFormScreenState();
}

class _CreateOrderFormScreenState extends ConsumerState<CreateOrderFormScreen> {
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent, title: const Text('Order Details')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 16,
                  children: [
                    const Text(
                      'Product',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    ShopItemCard(item: widget.item, isShowArrow: false),
                    const Divider(),
                    const Text(
                      'User Details',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          'Full Name',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        TextFormField(
                          controller: nameController,
                          maxLength: 64,
                          decoration: InputDecoration(
                            counterText: '',
                            border: border,
                            enabledBorder: border,
                            errorBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            hintText: 'Enter full name',
                          ),
                          inputFormatters: [NoEmojiFormatter()],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Full Name can't be empty";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          'Mobile',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        TextFormField(
                          style: const TextStyle(fontSize: 16, color: Color(0xffEFEDED)),
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          controller: mobileController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number can't be empty";
                            }
                            if (value.length < 10) {
                              return 'Phone number is incomplete';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            border: border,
                            counterText: '',
                            enabledBorder: border,
                            errorBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            hintText: 'xxxxxxxxxx',
                            prefixIconConstraints: const BoxConstraints.tightFor(width: 44),
                            hintStyle: const TextStyle(fontSize: 14, color: Color(0xff7D8082)),
                            prefixIcon: const Center(
                              child: Text(
                                '+91',
                                style: TextStyle(fontSize: 16, color: Color(0xffEFEDED)),
                              ),
                            ),
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        TextFormField(
                          controller: emailController,
                          maxLength: 64,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            counterText: '',
                            border: border,
                            enabledBorder: border,
                            errorBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            hintText: 'abc@example.com',
                          ),
                          inputFormatters: [NoEmojiFormatter()],
                          validator: (value) {
                            final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (value == null || value.isEmpty) {
                              return "Email can't be empty";
                            } else if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        const Text(
                          'Full Address (with PinCode)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                        ),
                        TextFormField(
                          controller: addressController,
                          keyboardType: TextInputType.streetAddress,
                          maxLength: 120,
                          decoration: InputDecoration(
                            counterText: '',
                            border: border,
                            enabledBorder: border,
                            errorBorder: border,
                            focusedBorder: border,
                            focusedErrorBorder: border,
                            hintText: 'Enter full address',
                          ),
                          inputFormatters: [NoEmojiFormatter()],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Address can't be empty";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16.0).copyWith(top: 0),
            child: MaterialButton(
              minWidth: double.infinity,
              color: const Color(0xFF54C339),
              onPressed: () {
                if (_formkey.currentState!.validate()) {
                  ref
                      .read(shopProvider.notifier)
                      .createOrder(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        address: addressController.text.trim(),
                        number: mobileController.text.trim(),
                        productId: widget.item.id,
                        context: context,
                      );
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'SUBMIT',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoEmojiFormatter extends TextInputFormatter {
  static final RegExp _emojiRegex = RegExp(
    r'[\u{1F600}-\u{1F6FF}]|' // Emoticons
    r'[\u{1F300}-\u{1F5FF}]|' // Misc Symbols and Pictographs
    r'[\u{1F700}-\u{1F77F}]|' // Alchemical Symbols
    r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols and Pictographs
    r'[\u{2600}-\u{26FF}]|' // Misc symbols
    r'[\u{2700}-\u{27BF}]', // Dingbats
    unicode: true,
  );

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(_emojiRegex, '');
    return newValue.copyWith(
      text: newText,
      selection: updateCursorPosition(newText, newValue.selection),
    );
  }

  // Preserve the cursor position
  TextSelection updateCursorPosition(String text, TextSelection selection) {
    final newOffset = selection.baseOffset > text.length ? text.length : selection.baseOffset;
    return TextSelection.collapsed(offset: newOffset);
  }
}
