import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Effective date: 2025-09-30',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),

              // 1. Acceptance of Terms
              Text('1. Acceptance of Terms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'By accessing or using our services, you agree to be bound by these Terms and Conditions.',
              ),
              SizedBox(height: 16),

              // 2. User Accounts
              Text('2. User Accounts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'You are responsible for maintaining the confidentiality of your account and password.',
              ),
              SizedBox(height: 16), 

              // 3. User Conduct
              Text('3. User Conduct',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'You agree not to use the service for any unlawful purpose or in any way that might harm, damage, or disparage any other party.',
              ),
              SizedBox(height: 16),

              // 4. Intellectual Property
              Text('4. Intellectual Property',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'All content included on this site, such as text, graphics, logos, is the property of our company.',
              ),
              SizedBox(height: 16),

              // 5. Termination
              Text('5. Termination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We may terminate or suspend your account immediately, without prior notice, for any reason whatsoever.',
              ),
              SizedBox(height: 16),

              // 6. Changes to Terms
              Text('6. Changes to Terms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We reserve the right to modify these terms at any time. We will provide notice of significant changes.',
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
