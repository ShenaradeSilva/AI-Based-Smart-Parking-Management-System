import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../widgets/pf_logo.dart';
import 'login_screen.dart';
import '../dashboard_screen.dart';
import 'reset_password_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        if (_resendTimer > 0) {
          _startResendTimer();
        } else {
          setState(() {
            _canResend = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Logo and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PFLogo(size: 40),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 24),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5AAC),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'We\'ve sent a verification code to your email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              // Verification Code Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    width: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E5AAC),
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        _checkVerificationCode();
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No Code? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  if (_canResend)
                    TextButton(
                      onPressed: _resendCode,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          color: Color(0xFF2E5AAC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in $_resendTimer seconds',
                      style: const TextStyle(
                        color: Color(0xFF2E5AAC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 40),

              // Send Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Send'),
                ),
              ),

              const Spacer(),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const PFLogo(size: 40),
                  IconButton(
                    onPressed: () {
                      // Navigate back to LoginScreen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.close, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkVerificationCode() {
    String code = _controllers.map((controller) => controller.text).join();
    if (code.length == 4) {
      // Auto-verify if code is complete (simulated)
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.verifyResetCode(widget.email, code);

    setState(() => _isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.green),
      );

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            verificationCode: code, // pass the 4-digit code here
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;

    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    final response = await AuthService.requestPasswordReset(widget.email);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.red),
      );
    }

    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
