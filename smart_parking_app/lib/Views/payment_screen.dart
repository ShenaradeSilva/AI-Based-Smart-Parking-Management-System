import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPaymentMethod = 0;
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Credit Card',
      'icon': Icons.credit_card,
      'details': '**** **** **** 1234',
      'cardType': 'Visa',
      'expiry': '12/25',
    },
    {
      'type': 'PayPal',
      'icon': Icons.payment,
      'details': 'user@example.com',
      'cardType': 'PayPal',
      'expiry': 'N/A',
    },
    {
      'type': 'Google Pay',
      'icon': Icons.payment,
      'details': 'user@gmail.com',
      'cardType': 'Google Pay',
      'expiry': 'N/A',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Color(0xFF2D3748)),
            onPressed: () => _showAddPaymentMethodDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _paymentMethods.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No payment methods added',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add a payment method to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(method['icon'] as IconData,
                                  color: Colors.blue),
                            ),
                            title: Text(method['type'] as String),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(method['details'] as String),
                                if (method['cardType'] != 'PayPal' &&
                                    method['cardType'] != 'Google Pay')
                                  Text('Expires: ${method['expiry']}',
                                      style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditPaymentMethodDialog(
                                          context, index);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmation(context, index);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete,
                                              size: 16, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = index;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _paymentMethods.isEmpty
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${_paymentMethods[_selectedPaymentMethod]['type']} selected as default'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Save Payment Method',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => _showAddPaymentMethodDialog(context),
                child: const Text('Add New Payment Method',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String selectedType = 'Credit Card';
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment Method'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Payment Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Credit Card', child: Text('Credit Card')),
                      DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                      DropdownMenuItem(
                          value: 'Google Pay', child: Text('Google Pay')),
                    ],
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == 'Credit Card') ...[
                    TextFormField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card number';
                        }
                        if (value.length < 16) {
                          return 'Invalid card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: expiryController,
                            decoration: const InputDecoration(
                              labelText: 'MM/YY',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Cardholder Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cardholder name';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: selectedType == 'PayPal'
                            ? 'PayPal Email'
                            : 'Google Pay Email',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter valid email';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _paymentMethods.add({
                      'type': selectedType,
                      'icon': selectedType == 'Credit Card'
                          ? Icons.credit_card
                          : Icons.payment,
                      'details': selectedType == 'Credit Card'
                          ? '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}'
                          : nameController.text,
                      'cardType': selectedType,
                      'expiry': selectedType == 'Credit Card'
                          ? expiryController.text
                          : 'N/A',
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$selectedType added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditPaymentMethodDialog(BuildContext context, int index) {
    final method = _paymentMethods[index];
    final isCard = method['type'] == 'Credit Card';

    final formKey = GlobalKey<FormState>();
    final cardNumberController = TextEditingController(
      text: isCard
          ? (method['details'] as String).replaceAll('**** **** **** ', '')
          : '',
    );
    final expiryController =
        TextEditingController(text: isCard ? (method['expiry'] as String) : '');
    final nameOrEmailController = TextEditingController(
      text: isCard ? '' : method['details'] as String,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit ${method['type']}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCard) ...[
                  TextFormField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (value.length < 16) return 'Invalid card number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: expiryController,
                    decoration: const InputDecoration(
                      labelText: 'MM/YY',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: nameOrEmailController,
                    decoration: InputDecoration(
                      labelText: method['type'] == 'PayPal'
                          ? 'PayPal Email'
                          : 'Google Pay Email',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                setState(() {
                  if (isCard) {
                    _paymentMethods[index]['details'] =
                        '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}';
                    _paymentMethods[index]['expiry'] = expiryController.text;
                  } else {
                    _paymentMethods[index]['details'] =
                        nameOrEmailController.text;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment method updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Payment Method'),
          content: Text(
              'Are you sure you want to delete ${_paymentMethods[index]['type']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _paymentMethods.removeAt(index);
                  if (_selectedPaymentMethod >= _paymentMethods.length) {
                    _selectedPaymentMethod = _paymentMethods.isEmpty
                        ? 0
                        : _paymentMethods.length - 1;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment method deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
