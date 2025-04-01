import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStartedScreen3 extends StatelessWidget {
  const GetStartedScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Logo at the top
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SvgPicture.asset(
              'assets/images/logo.svg', // Use the same logo as in GetStartedScreen1 and GetStartedScreen2
              placeholderBuilder: (BuildContext context) =>
                  const CircularProgressIndicator(),
              height: 100, // Match the height used in previous screens
              semanticsLabel: 'SteelBuddy Logo', // Accessibility label
            ),
          ),
          // Main content (text and illustration)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sell & purchase products,',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'buy, sell, and succeed!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SvgPicture.asset(
                    'assets/images/welcomescreen3.svg',
                    placeholderBuilder: (BuildContext context) =>
                        const CircularProgressIndicator(),
                    height: 200, // Match the height used in GetStartedScreen2
                    semanticsLabel: 'Sell and Purchase Illustration',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
