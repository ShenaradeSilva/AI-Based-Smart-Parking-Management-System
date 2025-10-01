import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Effective date: 2025-09-30',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 24),

              // 1. Information We Collect
              Text('1. Information We Collect',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We collect information you provide directly to us, such as when you create an account, including your name, email address, and profile picture.',
              ),
              SizedBox(height: 16),

              // 2. How We Use Your Information
              Text('2. How We Use Your Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We use the information we collect to provide, maintain, and improve our services, and to communicate with you about products, services, offers, and events.',
              ),
              SizedBox(height: 16),

              // 3. Information Sharing
              Text('3. Information Sharing',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We do not sell your personal information. We may share information with vendors and service providers who need access to perform work on our behalf.',
              ),
              SizedBox(height: 16),

              // 4. Data Security
              Text('4. Data Security',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We implement appropriate security measures to protect your personal information from unauthorized access.',
              ),
              SizedBox(height: 16),

              // 5. Your Choices
              Text('5. Your Choices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'You may update, correct, or delete information about you at any time by logging into your account.',
              ),
              SizedBox(height: 16),

              // 6. Changes to This Policy
              Text('6. Changes to This Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text(
                'We may change this privacy policy from time to time. We will post any changes on this page.',
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
