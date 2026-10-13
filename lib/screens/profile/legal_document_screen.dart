import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum _LegalDocument {
  terms,
  privacy,
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen.terms({super.key})
    : _document = _LegalDocument.terms;

  const LegalDocumentScreen.privacy({super.key})
    : _document = _LegalDocument.privacy;

  final _LegalDocument _document;

  bool get _isTerms => _document == _LegalDocument.terms;

  @override
  Widget build(BuildContext context) {
    final sections = _isTerms ? _termsSections : _privacySections;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isTerms ? 'Terms & Conditions' : 'Privacy Policy'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            _isTerms
                ? 'Using ShelfSpace'
                : 'Your information and privacy',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.burgundy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _isTerms
                ? 'These terms explain the basic rules for using the ShelfSpace app and bookstore services.'
                : 'This policy describes the information ShelfSpace uses to provide your bookstore experience.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          for (final section in sections) ...[
            Text(
              section.$1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              section.$2,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  static const _termsSections = <(String, String)>[
    (
      'Your account',
      'Provide accurate account details and keep your sign-in credentials private. You are responsible for activity carried out through your account. Contact Support if you believe your account has been accessed without permission.',
    ),
    (
      'Catalog and availability',
      'Book descriptions, prices, and stock are shown as provided by the store and may change. An item in your cart or wishlist is not reserved until an order is successfully placed.',
    ),
    (
      'Orders and payment',
      'Review your cart, delivery details, and payment method before submitting an order. Order confirmation and progress are shown in My Orders. If an order or payment appears incorrect, contact Support with the order details.',
    ),
    (
      'Acceptable use',
      'Use ShelfSpace lawfully and do not interfere with the app, attempt unauthorized access, or misuse another person’s account or information.',
    ),
    (
      'Changes and availability',
      'Features may be updated or temporarily unavailable while the service is maintained. We may update these terms as the service changes; the current version is the one displayed here.',
    ),
    (
      'Contact',
      'For questions about these terms or an order, open Help & Support from Settings.',
    ),
  ];

  static const _privacySections = <(String, String)>[
    (
      'Information you provide',
      'ShelfSpace uses account details such as your name, email address, and phone number to provide sign-in and account features. Delivery details are used to process and display your orders.',
    ),
    (
      'Wishlist, cart, and orders',
      'Books you save, add to your cart, or order are associated with your account so the app can show your selections, order history, and delivery progress.',
    ),
    (
      'How information is used',
      'Information is used to operate the catalog, authenticate your account, manage shopping and orders, provide support, and protect the service.',
    ),
    (
      'Storage and sharing',
      'Account and store information is handled by the ShelfSpace app and its configured backend. Information may be processed by providers needed to operate the service, such as hosting, authentication, or email delivery. Payment method details saved in the app are limited to the last four digits of a card.',
    ),
    (
      'Retention and your choices',
      'Information is kept as needed to provide account, order, and support features. You can manage saved books in your wishlist and contact Support about your account information or a privacy request.',
    ),
    (
      'Security and updates',
      'Reasonable safeguards are used to protect information, but no online service can guarantee absolute security. This policy may be updated as ShelfSpace features change; the current version is displayed here.',
    ),
    (
      'Contact',
      'For privacy questions or requests, open Help & Support from Settings.',
    ),
  ];
}
