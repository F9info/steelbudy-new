import 'package:flutter/material.dart';
import 'package:steel_buddy/models/application_settings_model.dart';
import 'package:steel_buddy/services/api_service.dart';

class GetStartedScreen1 extends StatefulWidget {
  const GetStartedScreen1({super.key});

  @override
  State<GetStartedScreen1> createState() => _GetStartedScreen1State();
}

class _GetStartedScreen1State extends State<GetStartedScreen1> {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchApplicationSettings,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: _settings != null && _settings!.logo.isNotEmpty
                    ? Image.network(
                        _settings!.logo,
                        height: 100,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const CircularProgressIndicator();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            size: 100,
                            color: Colors.red,
                          );
                        },
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
              ),
            const SizedBox(height: 20),
            Text(
              _settings != null && _settings!.getStartedText.isNotEmpty
                  ? _settings!.getStartedText
                  : 'Simplifying steel transactions with ease!', // Fallback
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
