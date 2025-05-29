// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/authentication.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/services/api_service.dart';
import '../../screens/role_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final AuthService _authService = AuthService();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  String? _error;
  int _resendTimer = 30;
  bool _canResend = false;
  final String _correctOtp = '123456';

  ApplicationSettings? _settings;
  bool _isLogoLoading = true; // Separate loading state for logo fetch
  String? _logoError; // Separate error state for logo fetch

  String? _currentVerificationId;

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.addListener(_checkOtpCompletion);
    }
    _currentVerificationId = widget.verificationId;
    _startResendTimer();
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

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startResendTimer();
      } else if (mounted && _resendTimer == 0) {
        // Ensure we only set _canResend to true once when the timer reaches 0
        // and the component is mounted.
        // This also prevents infinite loops if mounted becomes false unexpectedly.
        if (!_canResend) {

          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  void _checkOtpCompletion() {
    final isComplete =
        _controllers.every((controller) => controller.text.isNotEmpty);
    if (isComplete != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isComplete;
        _error = null;
      });
    }
  }

  Future<void> _verifyOtp(BuildContext context) async {
    if (!_isButtonEnabled || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String otp = _controllers.map((c) => c.text).join();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      await _authService.setLoggedIn(true, phoneNumber: '+91${widget.phoneNumber}');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Invalid OTP or verification failed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String phoneNumber = '+91${widget.phoneNumber}';
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: widget.resendToken,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _error = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _currentVerificationId = verificationId;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP resent successfully!'),
                duration: Duration(seconds: 2),
              ),
            );
            _startResendTimer();
          }
          setState(() {
            _resendTimer = 30;
            _canResend = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to resend OTP.';
      });
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedPhoneNumber;
    try {
      if (widget.phoneNumber.length == 10) {
        formattedPhoneNumber =
            '${widget.phoneNumber.substring(0, 5)}-${widget.phoneNumber.substring(5)}';
      } else {
        throw 'Invalid phone number length';
      }
    } catch (e) {
      formattedPhoneNumber = 'Unknown';
      setState(() {
        _error = 'Invalid phone number format';
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              const SizedBox(height: 40),
              Text(
                'Enter code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the OTP sent to +91 $formattedPhoneNumber',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF1E90FF)),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _resendTimer > 0
                        ? '00:${_resendTimer.toString().padLeft(2, '0')}'
                        : '00:00',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _canResend && !_isLoading ? _resendCode : null,
                    child: Text(
                      "Didn't receive code? Resend",
                      style: TextStyle(
                        fontSize: 16,
                        color: _canResend && !_isLoading
                            ? const Color(0xFF1E90FF)
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading
                      ? () => _verifyOtp(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}