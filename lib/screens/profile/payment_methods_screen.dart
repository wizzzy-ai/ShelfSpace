import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'type': 'Cash on Delivery',
      'subtitle': 'Pay when your order arrives',
      'icon': Icons.payments_outlined,
      'isDefault': true,
    },
  ];

  void _showAddPaymentMethod() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Add Payment Method',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 18),
                _PaymentChoice(
                  icon: Icons.credit_card_outlined,
                  title: 'Debit / Credit Card',
                  subtitle: 'Save a card for faster checkout',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showCardForm();
                  },
                ),
                const SizedBox(height: 10),
                _PaymentChoice(
                  icon: Icons.account_balance_outlined,
                  title: 'Bank Transfer',
                  subtitle: 'Pay using your bank account',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    setState(() {
                      _paymentMethods.add({
                        'type': 'Bank Transfer',
                        'subtitle': 'Pay using bank transfer',
                        'icon': Icons.account_balance_outlined,
                        'isDefault': false,
                      });
                    });
                  },
                ),
                const SizedBox(height: 10),
                _PaymentChoice(
                  icon: Icons.payments_outlined,
                  title: 'Cash on Delivery',
                  subtitle: 'Pay when your order arrives',
                  onTap: () {
                    Navigator.pop(sheetContext);

                    setState(() {
                      _paymentMethods.add({
                        'type': 'Cash on Delivery',
                        'subtitle': 'Pay when your order arrives',
                        'icon': Icons.payments_outlined,
                        'isDefault': false,
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCardForm({int? editIndex}) {
    final existing =
        editIndex != null ? _paymentMethods[editIndex] : null;

    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final nameController = TextEditingController();

    if (existing != null) {
      cardNumberController.text =
          existing['cardNumber']?.toString() ?? '';
      expiryController.text =
          existing['expiry']?.toString() ?? '';
      nameController.text =
          existing['cardName']?.toString() ?? '';
    }

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    editIndex == null
                        ? 'Add Card'
                        : 'Edit Card',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: nameController,
                    textCapitalization:
                        TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter the cardholder name';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      prefixIcon: Icon(
                        Icons.credit_card_outlined,
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter the card number';
                      }

                      final digits =
                          value.replaceAll(' ', '');

                      if (digits.length < 12) {
                        return 'Please enter a valid card number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: expiryController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      hintText: 'MM/YY',
                      prefixIcon: Icon(
                        Icons.calendar_month_outlined,
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter the expiry date';
                      }

                      if (!RegExp(
                        r'^\d{2}/\d{2}$',
                      ).hasMatch(value.trim())) {
                        return 'Use MM/YY format';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        final rawCard =
                            cardNumberController.text
                                .replaceAll(' ', '');

                        final lastFour = rawCard.length >= 4
                            ? rawCard.substring(
                                rawCard.length - 4,
                              )
                            : rawCard;

                        final card = {
                          'type': 'Debit / Credit Card',
                          'subtitle':
                              '•••• •••• •••• $lastFour',
                          'icon':
                              Icons.credit_card_outlined,
                          'cardNumber': lastFour,
                          'expiry':
                              expiryController.text.trim(),
                          'cardName':
                              nameController.text.trim(),
                          'isDefault': false,
                        };

                        setState(() {
                          if (editIndex != null) {
                            _paymentMethods[editIndex] = card;
                          } else {
                            _paymentMethods.add(card);
                          }
                        });

                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        editIndex == null
                            ? 'Add Card'
                            : 'Save Changes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setDefault(int index) {
    setState(() {
      for (var i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i]['isDefault'] = i == index;
      }
    });
  }

  void _deleteMethod(int index) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Remove payment method?'),
          content: const Text(
            'This payment method will be removed from your account.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final wasDefault =
                      _paymentMethods[index]['isDefault'] ==
                          true;

                  _paymentMethods.removeAt(index);

                  if (wasDefault &&
                      _paymentMethods.isNotEmpty) {
                    _paymentMethods[0]['isDefault'] = true;
                  }
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _editMethod(int index) {
    final method = _paymentMethods[index];

    if (method['type'] == 'Debit / Credit Card') {
      _showCardForm(editIndex: index);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'This payment method does not require editing.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: _paymentMethods.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                110,
              ),
              itemCount: _paymentMethods.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];

                return _PaymentMethodCard(
                  type: method['type'] as String,
                  subtitle: method['subtitle'] as String,
                  icon: method['icon'] as IconData,
                  isDefault:
                      method['isDefault'] as bool,
                  onSetDefault: () {
                    _setDefault(index);
                  },
                  onEdit: () {
                    _editMethod(index);
                  },
                  onDelete: () {
                    _deleteMethod(index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPaymentMethod,
        backgroundColor: AppColors.burgundy,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Payment'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color:
                    AppColors.burgundy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.credit_card_outlined,
                color: AppColors.burgundy,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No payment methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add a payment method to make checkout faster.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      AppColors.burgundy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String type;
  final String subtitle;
  final IconData icon;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.type,
    required this.subtitle,
    required this.icon,
    required this.isDefault,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault
              ? AppColors.burgundy
              : AppColors.border,
          width: isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      AppColors.burgundy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.burgundy,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'default') {
                    onSetDefault();
                  } else if (value == 'edit') {
                    onEdit();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (!isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Text('Set as Default'),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ];
                },
              ),
            ],
          ),
          if (isDefault) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors.burgundy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Default payment method',
                  style: TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}