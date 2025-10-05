import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../widgets/pf_logo.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import '../../Models/user_data.dart';
import '../../services/auth_service.dart';
import '../dashboard_screen.dart';
import '../legal/terms_screen.dart';
import '../../utils/country_codes.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // Country code and vehicle type
  CountryCode _selectedCountryCode = CountryCodes.defaultCountry;
  String _selectedVehicleType = 'Car';

  final List<CountryCode> _countryCodes = CountryCodes.allCountryCodes;
  final List<String> _vehicleTypes = const ['Car', 'Jeep', 'Van', 'Bike'];

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
                // Header with Logo and Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PFLogo(size: 40),
                    IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
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
                  'Create your Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5AAC),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Join Parking Flow and start booking parking spots easily.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outlined),
                    hintText: 'Enter your full name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'Enter your email address',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Mobile Number Field with Country Code
                Builder(builder: (context) {
                  final selectedDigits = _selectedCountryCode.digits;
                  return Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<CountryCode>(
                          isExpanded: true,
                          value: _selectedCountryCode,
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: _countryCodes
                              .map((country) => DropdownMenuItem<CountryCode>(
                                    value: country,
                                    child: Text(
                                        "${country.code} (${country.name})"),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => _countryCodes
                              .map((country) => Text(country.code))
                              .toList(),
                          onChanged: (country) => setState(() {
                            _selectedCountryCode =
                                country ?? CountryCodes.defaultCountry;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(selectedDigits),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Mobile No.',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            hintText: 'Enter $selectedDigits-digit number',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            final digitsOnly =
                                value.replaceAll(RegExp(r'\D'), '');
                            if (digitsOnly.length != selectedDigits) {
                              return 'Enter exactly $selectedDigits digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 20),

                // Vehicle Type Field
                DropdownButtonFormField<String>(
                  value: _selectedVehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Type',
                    prefixIcon: Icon(Icons.directions_car_filled_outlined),
                  ),
                  items: _vehicleTypes
                      .map((t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(t),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _selectedVehicleType = v ?? 'Car';
                  }),
                ),

                const SizedBox(height: 20),

                // Vehicle Registration Field
                TextFormField(
                  controller: _vehicleController,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Registration No.',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                    hintText: 'Eg.-CAB2256',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter vehicle registration number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Removed Profile Picture Upload Section
                const SizedBox(height: 0),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    hintText: 'Enter your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    // Backend policy: 8-12 chars, at least one letter and one digit
                    if (value.length < 8 || value.length > 12) {
                      return 'Password must be 8-12 characters';
                    }
                    final hasLetter = value.contains(RegExp(r'[A-Za-z]'));
                    final hasDigit = value.contains(RegExp(r'\d'));
                    if (!hasLetter || !hasDigit) {
                      return 'Include at least one letter and one number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    hintText: 'Confirm your password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Terms and Conditions Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF2E5AAC),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            const TextSpan(text: 'Agree to '),
                            TextSpan(
                              text: 'terms & conditions',
                              style: const TextStyle(
                                color: Color(0xFF2E5AAC),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TermsAndConditionsScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading || !_agreeToTerms ? null : _handleSignUp,
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
                        : const Text('Sign Up'),
                  ),
                ),

                const SizedBox(height: 20),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an account? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                          color: Color(0xFF2E5AAC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Concatenate full country code + entered number
      final mobileWithCode =
          '${_selectedCountryCode.code}${_mobileController.text.trim()}';
      // Note: use .code or .digits depending on your CountryCode class

      final resp = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        mobileWithCode, // send full number here
        _vehicleController.text.trim(),
        _selectedVehicleType,
        _passwordController.text,
      );

      if (resp['success'] == true && resp['data'] != null) {
        final user = resp['data']['user'] ?? {};
        // Update in-memory user for UI
        UserData.updateUserData({
          'name': user['name'] ?? _nameController.text,
          'email': user['email'] ?? _emailController.text,
          'phone': user['mobile'] ?? mobileWithCode,
          'vehicle': user['vehicle_number'] ?? _vehicleController.text,
          'vehicle_type': user['vehicle_type'] ?? _selectedVehicleType,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );

        // Navigate to Login Screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        final msg = resp['message']?.toString() ?? 'Registration failed';
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _vehicleController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
