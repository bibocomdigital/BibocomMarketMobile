import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.errorMessage,
  });

  final void Function(String email, String phone, String password) onSubmit;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(_email.text.trim(), _phone.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MerchantTextField(
            controller: _email,
            hint: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              final phone = _phone.text.trim();
              if (email.isEmpty && phone.isEmpty) {
                return 'Email ou téléphone requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          MerchantTextField(
            controller: _phone,
            hint: 'Téléphone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          MerchantTextField(
            controller: _password,
            hint: 'Mot de passe',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.muted,
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Au moins 6 caractères';
              }
              return null;
            },
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: widget.isLoading ? null : _submit,
            child: Text(widget.isLoading ? 'Connexion...' : 'Se connecter'),
          ),
        ],
      ),
    );
  }
}
