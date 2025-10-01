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
  String _selectedCountryCode = '+94'; // default Sri Lanka
  String _selectedVehicleType = 'Car';
  final List<Map<String, Object>> _countryCodes = const [
    {'code': '+93', 'name': 'Afghanistan', 'digits': 9},
    {'code': '+355', 'name': 'Albania', 'digits': 9},
    {'code': '+213', 'name': 'Algeria', 'digits': 9},
    {'code': '+376', 'name': 'Andorra', 'digits': 6},
    {'code': '+244', 'name': 'Angola', 'digits': 9},
    {'code': '+1-268', 'name': 'Antigua and Barbuda', 'digits': 7},
    {'code': '+54', 'name': 'Argentina', 'digits': 10},
    {'code': '+374', 'name': 'Armenia', 'digits': 8},
    {'code': '+61', 'name': 'Australia', 'digits': 9},
    {'code': '+43', 'name': 'Austria', 'digits': 10},
    {'code': '+994', 'name': 'Azerbaijan', 'digits': 9},
    {'code': '+1-242', 'name': 'Bahamas', 'digits': 7},
    {'code': '+973', 'name': 'Bahrain', 'digits': 8},
    {'code': '+880', 'name': 'Bangladesh', 'digits': 10},
    {'code': '+1-246', 'name': 'Barbados', 'digits': 7},
    {'code': '+375', 'name': 'Belarus', 'digits': 9},
    {'code': '+32', 'name': 'Belgium', 'digits': 9},
    {'code': '+501', 'name': 'Belize', 'digits': 7},
    {'code': '+229', 'name': 'Benin', 'digits': 8},
    {'code': '+1-441', 'name': 'Bermuda', 'digits': 7},
    {'code': '+975', 'name': 'Bhutan', 'digits': 8},
    {'code': '+591', 'name': 'Bolivia', 'digits': 8},
    {'code': '+267', 'name': 'Botswana', 'digits': 8},
    {'code': '+55', 'name': 'Brazil', 'digits': 10},
    {'code': '+673', 'name': 'Brunei', 'digits': 7},
    {'code': '+359', 'name': 'Bulgaria', 'digits': 9},
    {'code': '+226', 'name': 'Burkina Faso', 'digits': 8},
    {'code': '+257', 'name': 'Burundi', 'digits': 8},
    {'code': '+238', 'name': 'Cabo Verde', 'digits': 7},
    {'code': '+855', 'name': 'Cambodia', 'digits': 9},
    {'code': '+237', 'name': 'Cameroon', 'digits': 9},
    {'code': '+1', 'name': 'Canada', 'digits': 10},
    {'code': '+236', 'name': 'Central African Republic', 'digits': 8},
    {'code': '+235', 'name': 'Chad', 'digits': 8},
    {'code': '+56', 'name': 'Chile', 'digits': 9},
    {'code': '+86', 'name': 'China', 'digits': 11},
    {'code': '+57', 'name': 'Colombia', 'digits': 10},
    {'code': '+269', 'name': 'Comoros', 'digits': 7},
    {'code': '+243', 'name': 'Congo, Democratic Republic of the', 'digits': 9},
    {'code': '+242', 'name': 'Congo, Republic of the', 'digits': 9},
    {'code': '+682', 'name': 'Cook Islands', 'digits': 5},
    {'code': '+506', 'name': 'Costa Rica', 'digits': 8},
    {'code': '+225', 'name': "Côte d'Ivore", 'digits': 8},
    {'code': '+385', 'name': 'Croatia', 'digits': 9},
    {'code': '+53', 'name': 'Cuba', 'digits': 8},
    {'code': '+357', 'name': 'Cyprus', 'digits': 8},
    {'code': '+420', 'name': 'Czech Republic', 'digits': 9},
    {'code': '+45', 'name': 'Denmark', 'digits': 8},
    {'code': '+253', 'name': 'Djibouti', 'digits': 8},
    {'code': '+1-767', 'name': 'Dominica', 'digits': 7},
    {'code': '+593', 'name': 'Ecuador', 'digits': 9},
    {'code': '+20', 'name': 'Egypt', 'digits': 10},
    {'code': '+503', 'name': 'El Salvador', 'digits': 8},
    {'code': '+240', 'name': 'Equatorial Guinea', 'digits': 9},
    {'code': '+291', 'name': 'Eritrea', 'digits': 7},
    {'code': '+372', 'name': 'Estonia', 'digits': 8},
    {'code': '+251', 'name': 'Ethiopia', 'digits': 9},
    {'code': '+679', 'name': 'Fiji', 'digits': 7},
    {'code': '+358', 'name': 'Finland', 'digits': 9},
    {'code': '+33', 'name': 'France', 'digits': 9},
    {'code': '+241', 'name': 'Gabon', 'digits': 8},
    {'code': '+220', 'name': 'Gambia', 'digits': 7},
    {'code': '+995', 'name': 'Georgia', 'digits': 9},
    {'code': '+49', 'name': 'Germany', 'digits': 10},
    {'code': '+233', 'name': 'Ghana', 'digits': 9},
    {'code': '+350', 'name': 'Gibraltar', 'digits': 8},
    {'code': '+30', 'name': 'Greece', 'digits': 10},
    {'code': '+299', 'name': 'Greenland', 'digits': 6},
    {'code': '+1-473', 'name': 'Grenada', 'digits': 7},
    {'code': '+1-671', 'name': 'Guam', 'digits': 7},
    {'code': '+502', 'name': 'Guatemala', 'digits': 8},
    {'code': '+224', 'name': 'Guinea', 'digits': 9},
    {'code': '+245', 'name': 'Guinea-Bissau', 'digits': 7},
    {'code': '+592', 'name': 'Guyana', 'digits': 7},
    {'code': '+509', 'name': 'Haiti', 'digits': 8},
    {'code': '+504', 'name': 'Honduras', 'digits': 8},
    {'code': '+852', 'name': 'Hong Kong', 'digits': 8},
    {'code': '+36', 'name': 'Hungary', 'digits': 9},
    {'code': '+354', 'name': 'Iceland', 'digits': 7},
    {'code': '+91', 'name': 'India', 'digits': 10},
    {'code': '+62', 'name': 'Indonesia', 'digits': 9},
    {'code': '+98', 'name': 'Iran', 'digits': 10},
    {'code': '+964', 'name': 'Iraq', 'digits': 10},
    {'code': '+353', 'name': 'Ireland', 'digits': 9},
    {'code': '+972', 'name': 'Israel', 'digits': 9},
    {'code': '+39', 'name': 'Italy', 'digits': 10},
    {'code': '+1-876', 'name': 'Jamaica', 'digits': 7},
    {'code': '+81', 'name': 'Japan', 'digits': 10},
    {'code': '+962', 'name': 'Jordan', 'digits': 9},
    {'code': '+7', 'name': 'Kazakhstan', 'digits': 10},
    {'code': '+254', 'name': 'Kenya', 'digits': 9},
    {'code': '+686', 'name': 'Kiribati', 'digits': 5},
    {'code': '+850', 'name': 'North Korea', 'digits': 9},
    {'code': '+82', 'name': 'South Korea', 'digits': 9},
    {'code': '+965', 'name': 'Kuwait', 'digits': 8},
    {'code': '+996', 'name': 'Kyrgyzstan', 'digits': 9},
    {'code': '+856', 'name': 'Laos', 'digits': 9},
    {'code': '+371', 'name': 'Latvia', 'digits': 8},
    {'code': '+961', 'name': 'Lebanon', 'digits': 8},
    {'code': '+266', 'name': 'Lesotho', 'digits': 8},
    {'code': '+231', 'name': 'Liberia', 'digits': 8},
    {'code': '+218', 'name': 'Libya', 'digits': 9},
    {'code': '+423', 'name': 'Liechtenstein', 'digits': 7},
    {'code': '+370', 'name': 'Lithuania', 'digits': 8},
    {'code': '+352', 'name': 'Luxembourg', 'digits': 9},
    {'code': '+853', 'name': 'Macau', 'digits': 8},
    {'code': '+261', 'name': 'Madagascar', 'digits': 9},
    {'code': '+265', 'name': 'Malawi', 'digits': 9},
    {'code': '+60', 'name': 'Malaysia', 'digits': 9},
    {'code': '+960', 'name': 'Maldives', 'digits': 7},
    {'code': '+223', 'name': 'Mali', 'digits': 8},
    {'code': '+356', 'name': 'Malta', 'digits': 8},
    {'code': '+692', 'name': 'Marshall Islands', 'digits': 7},
    {'code': '+222', 'name': 'Mauritania', 'digits': 8},
    {'code': '+230', 'name': 'Mauritius', 'digits': 7},
    {'code': '+52', 'name': 'Mexico', 'digits': 10},
    {'code': '+691', 'name': 'Micronesia', 'digits': 7},
    {'code': '+373', 'name': 'Moldova', 'digits': 8},
    {'code': '+377', 'name': 'Monaco', 'digits': 8},
    {'code': '+976', 'name': 'Mongolia', 'digits': 8},
    {'code': '+382', 'name': 'Montenegro', 'digits': 8},
    {'code': '+1-664', 'name': 'Montserrat', 'digits': 7},
    {'code': '+212', 'name': 'Morocco', 'digits': 9},
    {'code': '+258', 'name': 'Mozambique', 'digits': 9},
    {'code': '+95', 'name': 'Myanmar (Burma)', 'digits': 9},
    {'code': '+264', 'name': 'Namibia', 'digits': 9},
    {'code': '+674', 'name': 'Nauru', 'digits': 7},
    {'code': '+977', 'name': 'Nepal', 'digits': 10},
    {'code': '+31', 'name': 'Netherlands', 'digits': 9},
    {'code': '+687', 'name': 'New Caledonia', 'digits': 6},
    {'code': '+64', 'name': 'New Zealand', 'digits': 9},
    {'code': '+505', 'name': 'Nicaragua', 'digits': 8},
    {'code': '+227', 'name': 'Niger', 'digits': 8},
    {'code': '+234', 'name': 'Nigeria', 'digits': 10},
    {'code': '+683', 'name': 'Niue', 'digits': 4},
    {'code': '+672', 'name': 'Norfolk Island', 'digits': 5},
    {'code': '+389', 'name': 'North Macedonia', 'digits': 8},
    {'code': '+1-670', 'name': 'Northern Mariana Islands', 'digits': 7},
    {'code': '+47', 'name': 'Norway', 'digits': 8},
    {'code': '+968', 'name': 'Oman', 'digits': 8},
    {'code': '+92', 'name': 'Pakistan', 'digits': 10},
    {'code': '+680', 'name': 'Palau', 'digits': 7},
    {'code': '+970', 'name': 'Palestine', 'digits': 9},
    {'code': '+507', 'name': 'Panama', 'digits': 8},
    {'code': '+675', 'name': 'Papua New Guinea', 'digits': 8},
    {'code': '+595', 'name': 'Paraguay', 'digits': 9},
    {'code': '+51', 'name': 'Peru', 'digits': 9},
    {'code': '+63', 'name': 'Philippines', 'digits': 10},
    {'code': '+48', 'name': 'Poland', 'digits': 9},
    {'code': '+351', 'name': 'Portugal', 'digits': 9},
    {'code': '+1-787', 'name': 'Puerto Rico', 'digits': 7},
    {'code': '+1-939', 'name': 'Puerto Rico', 'digits': 7},
    {'code': '+974', 'name': 'Qatar', 'digits': 8},
    {'code': '+40', 'name': 'Romania', 'digits': 9},
    {'code': '+7', 'name': 'Russia', 'digits': 10},
    {'code': '+250', 'name': 'Rwanda', 'digits': 9},
    {'code': '+685', 'name': 'Samoa', 'digits': 7},
    {'code': '+378', 'name': 'San Marino', 'digits': 10},
    {'code': '+239', 'name': 'Sao Tome and Principe', 'digits': 7},
    {'code': '+966', 'name': 'Saudi Arabia', 'digits': 9},
    {'code': '+221', 'name': 'Senegal', 'digits': 9},
    {'code': '+381', 'name': 'Serbia', 'digits': 9},
    {'code': '+248', 'name': 'Seychelles', 'digits': 7},
    {'code': '+232', 'name': 'Sierra Leone', 'digits': 8},
    {'code': '+65', 'name': 'Singapore', 'digits': 8},
    {'code': '+1-721', 'name': 'Sint Maarten', 'digits': 7},
    {'code': '+421', 'name': 'Slovakia', 'digits': 9},
    {'code': '+386', 'name': 'Slovenia', 'digits': 8},
    {'code': '+677', 'name': 'Solomon Islands', 'digits': 7},
    {'code': '+252', 'name': 'Somalia', 'digits': 8},
    {'code': '+27', 'name': 'South Africa', 'digits': 9},
    {'code': '+211', 'name': 'South Sudan', 'digits': 9},
    {'code': '+34', 'name': 'Spain', 'digits': 9},
    {'code': '+94', 'name': 'Sri Lanka', 'digits': 9},
    {'code': '+249', 'name': 'Sudan', 'digits': 9},
    {'code': '+597', 'name': 'Suriname', 'digits': 7},
    {'code': '+268', 'name': 'Swaziland', 'digits': 8},
    {'code': '+46', 'name': 'Sweden', 'digits': 9},
    {'code': '+41', 'name': 'Switzerland', 'digits': 9},
    {'code': '+963', 'name': 'Syria', 'digits': 9},
    {'code': '+255', 'name': 'Tanzania', 'digits': 9},
    {'code': '+66', 'name': 'Thailand', 'digits': 9},
    {'code': '+228', 'name': 'Togo', 'digits': 8},
    {'code': '+676', 'name': 'Tonga', 'digits': 7},
    {'code': '+1-868', 'name': 'Trinidad and Tobago', 'digits': 7},
    {'code': '+216', 'name': 'Tunisia', 'digits': 8},
    {'code': '+90', 'name': 'Turkey', 'digits': 10},
    {'code': '+993', 'name': 'Turkmenistan', 'digits': 8},
    {'code': '+688', 'name': 'Tuvalu', 'digits': 5},
    {'code': '+256', 'name': 'Uganda', 'digits': 9},
    {'code': '+380', 'name': 'Ukraine', 'digits': 9},
    {'code': '+971', 'name': 'United Arab Emirates', 'digits': 9},
    {'code': '+44', 'name': 'United Kingdom', 'digits': 10},
    {'code': '+1', 'name': 'United States', 'digits': 10},
    {'code': '+598', 'name': 'Uruguay', 'digits': 8},
    {'code': '+998', 'name': 'Uzbekistan', 'digits': 9},
    {'code': '+678', 'name': 'Vanuatu', 'digits': 7},
    {'code': '+379', 'name': 'Vatican City', 'digits': 10},
    {'code': '+58', 'name': 'Venezuela', 'digits': 10},
    {'code': '+84', 'name': 'Vietnam', 'digits': 9},
    {'code': '+212', 'name': 'Western Sahara', 'digits': 9},
    {'code': '+44', 'name': 'Wales', 'digits': 10},
    {'code': '+967', 'name': 'Yemen', 'digits': 9},
    {'code': '+260', 'name': 'Zambia', 'digits': 9},
    {'code': '+263', 'name': 'Zimbabwe', 'digits': 9},
    {'code': '+255', 'name': 'Zanzibar', 'digits': 9},
  ];
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
                  final selected = _countryCodes.firstWhere(
                    (c) => c['code'] == _selectedCountryCode,
                    orElse: () => const <String, Object>{
                      'code': '+94',
                      'name': 'Sri Lanka',
                      'digits': 9,
                    },
                  );
                  final int selectedDigits = selected['digits'] as int;
                  return Row(
                    children: [
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: _selectedCountryCode,
                          decoration: const InputDecoration(
                            labelText: 'Code',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          items: _countryCodes
                              .map((c) => DropdownMenuItem<String>(
                                    value: c['code'] as String,
                                    child: Text("${c['code']} (${c['name']})"),
                                  ))
                              .toList(),
                          selectedItemBuilder: (context) => _countryCodes
                              .map((c) => Text(c['code'] as String))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedCountryCode = v ?? '+94';
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
                                      builder: (_) => const TermsAndConditionsScreen(),
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
      final resp = await AuthService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        '${_selectedCountryCode}${_mobileController.text.trim()}',
        _vehicleController.text.trim(),
        _passwordController.text,
      );

      if (resp['success'] == true && resp['data'] != null) {
        final user = resp['data']['user'] ?? {};
        // Update in-memory user for UI
        UserData.updateUserData({
          'name': user['name'] ?? _nameController.text,
          'email': user['email'] ?? _emailController.text,
          'phone': user['mobile'] ?? _mobileController.text,
          'vehicle': user['vehicle_number'] ?? _vehicleController.text,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );

        // Navigate to Dashboard to show real data
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
