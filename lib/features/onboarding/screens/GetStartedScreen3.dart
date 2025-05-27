import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/services/api_service.dart';

class GetStartedScreen3 extends StatefulWidget {
  const GetStartedScreen3({super.key});

  @override
  State<GetStartedScreen3> createState() => _GetStartedScreen3State();
}

class _GetStartedScreen3State extends State<GetStartedScreen3> {
  ApplicationSettings? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplicationSettings();
  }

  Future<void> _fetchApplicationSettings() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching settings: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse the getStartedText2 value into two parts
    String firstText = 'Sell & purchase products,'; // Fallback
    String secondText = 'buy, sell, and succeed!'; // Fallback
    if (_settings != null && _settings!.getStartedText2.isNotEmpty) {
      final parts = _settings!.getStartedText2.split('\n');
      if (parts.length >= 2) {
        firstText = parts[0]; // "Sell & purchase products"
        secondText = parts[1]
            .replaceAll('<span>', '')
            .replaceAll('</span>', ''); // "buy, sell, and succeed!"
      } else {
        firstText = _settings!.getStartedText2;
      }
    }

    return SafeArea(
      child: Column(
        children: [
          // Logo at the top
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: _isLoading
                ? const CircularProgressIndicator()
                : _error != null
                    ? Column(
                        children: [
                          Text(_error!),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchApplicationSettings,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    : _settings != null && _settings!.logo.isNotEmpty
                        ? Image.network(
                            _settings!.logo,
                            height: 70,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 70,
                                color: Colors.red,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 70,
                            color: Colors.grey,
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
                    firstText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondText,
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
                    height: 200,
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