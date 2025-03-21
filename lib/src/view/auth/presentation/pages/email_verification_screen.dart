import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';


class EmailInputScreen extends StatelessWidget {
  const EmailInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13191D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff2B2D30),
                  border: Border.all(color: const Color(0xff464A4F), width: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Handle back button press
                  },
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'Enter Your\nEmail Address',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'We will send you a confirmation code',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xff8F9193))
              ),
              const SizedBox(height: 32),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Email ID',
                  hintStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xff7D8082)),
                  filled: true,
                  fillColor: const Color(0xff2B2D30),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: SvgPicture.asset(
                      'assets/images/svg/email_icon.svg',
                      height: 16.0,
                      width: 16,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Color(0xff7D8082), BlendMode.srcIn) ,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
                ),
                style: const TextStyle(color: Colors.white),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle continue button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD964),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
