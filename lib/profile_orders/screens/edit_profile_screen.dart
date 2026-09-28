import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _street;
  late final TextEditingController _city;
  late final TextEditingController _state;
  late final TextEditingController _country;
  late final TextEditingController _postalCode;
  late final TextEditingController _last4;

  String? _imagePath;
  late PaymentType _paymentType;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _street = TextEditingController(text: p.address.street);
    _city = TextEditingController(text: p.address.city);
    _state = TextEditingController(text: p.address.state);
    _country = TextEditingController(text: p.address.country);
    _postalCode = TextEditingController(text: p.address.postalCode);
    _last4 = TextEditingController(text: p.paymentMethod.last4 ?? '');
    _imagePath = p.profileImagePath;
    _paymentType = p.paymentMethod.type;
  }

  @override
  void dispose() {
    for (final c in [
      _name, _email, _phone, _street, _city, _state, _country, _postalCode,
      _last4,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (file != null && mounted) setState(() => _imagePath = file.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final updated = UserProfile(
      id: widget.profile.id,
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      profileImagePath: _imagePath,
      address: ShippingAddress(
        street: _street.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        country: _country.text.trim(),
        postalCode: _postalCode.text.trim(),
      ),
      paymentMethod: PaymentMethod(
        type: _paymentType,
        last4: _paymentType == PaymentType.card ? _last4.text.trim() : null,
      ),
    );

    final ok = await provider.save(updated);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Could not save changes')),
      );
    }
  }

  String? Function(String?) _required(String label) => (value) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(v)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validateLast4(String? value) {
    if (_paymentType != PaymentType.card) return null;
    if (!RegExp(r'^[0-9]{4}$').hasMatch(value?.trim() ?? '')) {
      return 'Enter the last 4 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<ProfileProvider>().isSaving;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  ProfileAvatar(name: _name.text, imagePath: _imagePath),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      tooltip: 'Change photo',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Personal details', style: titleStyle),
            const SizedBox(height: 8),
            _field(_name, 'Name', validator: _required('Name'),
                capitalization: TextCapitalization.words),
            _field(_email, 'Email', validator: _validateEmail,
                keyboardType: TextInputType.emailAddress),
            _field(_phone, 'Phone number', validator: _validatePhone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            Text('Shipping address', style: titleStyle),
            const SizedBox(height: 8),
            _field(_street, 'Street address', validator: _required('Street address'),
                capitalization: TextCapitalization.words),
            _field(_city, 'City', validator: _required('City'),
                capitalization: TextCapitalization.words),
            _field(_state, 'State', validator: _required('State'),
                capitalization: TextCapitalization.words),
            _field(_country, 'Country', validator: _required('Country'),
                capitalization: TextCapitalization.words),
            _field(_postalCode, 'Postal code', validator: _required('Postal code'),
                capitalization: TextCapitalization.characters),
            const SizedBox(height: 16),
            Text('Payment method', style: titleStyle),
            const SizedBox(height: 8),
            DropdownButtonFormField<PaymentType>(
              value: _paymentType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final type in PaymentType.values)
                  DropdownMenuItem(value: type, child: Text(type.label)),
              ],
              onChanged: (type) {
                if (type != null) setState(() => _paymentType = type);
              },
            ),
            if (_paymentType == PaymentType.card) ...[
              const SizedBox(height: 12),
              _field(
                _last4,
                'Card last 4 digits',
                validator: _validateLast4,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
