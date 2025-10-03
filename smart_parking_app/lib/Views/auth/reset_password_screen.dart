import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/pf_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  bool _showPassword = false;
  bool _showConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PFLogo(size: 40),
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
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
                const SizedBox(height: 40),

                // Title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5AAC),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your new password below',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter new password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showConfirm ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Reset Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePasswordResetFlow,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Reset Password'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePasswordResetFlow() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Verify the code
      final verifyResponse = await AuthService.verifyResetCode(
        widget.email,
        widget.verificationCode,
      );

      if (verifyResponse?['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(verifyResponse?['message'] ?? 'Verification failed'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Step 2: Reset the password
      final resetResponse = await AuthService.resetPassword(
        widget.email,
        widget.verificationCode,
        _passwordController.text.trim(),
      );

      final success = resetResponse?['success'] == true;
      final message = resetResponse?['message'] ?? 'Something went wrong';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
