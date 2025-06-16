import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false; // For login button
  String? _error; // For login errors
  final String _allowedNumber = '1234567890'; // Allowed phone number

  ApplicationSettings? _settings;
  bool _isLogoLoading = true; // Separate loading state for logo fetch
  String? _logoError; // Separate error state for logo fetch

  int? _resendToken; // Store resend token for OTP resending

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _fetchApplicationSettings();
  }

  Future<void> _fetchApplicationSettings() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
        _isLogoLoading = false;
      });
    } catch (e) {
      setState(() {
        _logoError = 'Error fetching logo: $e';
        _isLogoLoading = false;
      });
    }
  }

  void _validatePhone() {
    setState(() {
      _isValid = _phoneController.text.length == 10;
    });
  }

  Future<void> _login() async {
    if (!_isValid || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final String phoneNumber = '+91${_phoneController.text}';

    // Dev bypass for test number
    if (_phoneController.text == '2345678901' || _phoneController.text == '2345678902') {
      Navigator.pushReplacementNamed(
        context,
        '/otp',
        arguments: {
          'phoneNumber': _phoneController.text,
          'verificationId': 'test-verification-id',
          'resendToken': 0,
        },
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Extra validation before calling Firebase
    if (_phoneController.text.isEmpty || _phoneController.text.length != 10) {
      setState(() {
        _isLoading = false;
        _error = 'Please enter a valid 10-digit mobile number.';
      });
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Firebase: verificationCompleted');
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _error = e.message ?? 'Verification failed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_error!),
              backgroundColor: Colors.red,
            ),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _resendToken = resendToken;
          });
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/otp',
              arguments: {
                'phoneNumber': _phoneController.text,
                'verificationId': verificationId,
                'resendToken': resendToken,
              },
            );
          }
          print('Firebase: codeSent');
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error ?? 'Error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: _isLogoLoading
                      ? const CircularProgressIndicator()
                      : _logoError != null
                          ? const Icon(
                              Icons.image_not_supported,
                              size: 70,
                              color: Colors.grey,
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
                const SizedBox(height: 48),
                // Welcome Text
                Text(
                  'Enter your mobile number',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We will send you a verification code',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 32),
                // Phone Number Input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 16),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Enter mobile number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '+91',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isValid && !_isLoading ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Get OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}