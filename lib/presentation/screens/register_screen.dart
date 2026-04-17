import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _cognomController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _cognomController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _validateEmail(String? value, S strings) {
    if (value == null || value.isEmpty) return strings.fieldRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return strings.invalidEmail;
    return null;
  }

  Future<bool> _showConsentDialog() async {
    final strings = S.of(context);
    final theme = Theme.of(context);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.0
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.privacy_tip_outlined, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                strings.consentTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                strings.consentDescription,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(strings.decline),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(strings.accept),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50.0, left: 24.0, right: 24.0, bottom: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(strings.registerTitle, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              const SizedBox(height: 20),
              TextFormField(controller: _nomController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zà-üÀ-ÜñÑ\s]'))], decoration: InputDecoration(labelText: strings.nameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _cognomController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zà-üÀ-ÜñÑ\s]'))], decoration: InputDecoration(labelText: strings.lastNameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _nicknameController, inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))], decoration: InputDecoration(labelText: strings.usernameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _emailController, inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s')), FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]'))], decoration: InputDecoration(labelText: strings.emailLabel), keyboardType: TextInputType.emailAddress, validator: (v) => _validateEmail(v, strings)),
              const SizedBox(height: 10),
              TextFormField(controller: _passwordController,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s')), FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E]'))],
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: strings.passwordLabel,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v!.length < 6 ? strings.passwordTooShort : null
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: strings.confirmPasswordLabel,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) return strings.passwordsDontMatch;
                  return null;
                },
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final hasConsented = await _showConsentDialog();
                    if (!hasConsented) return;

                    try {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.creatingAccount)));

                      await context.read<AuthProvider>().signUp(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                        nickname: _nicknameController.text.trim(),
                        nom: _nomController.text.trim(),
                        cognom: _cognomController.text.trim(),
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.registrationPending), backgroundColor: Colors.green)
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        String message;

                        if (e == 'EMAIL_EXISTS') {
                          message = strings.errorEmailExists;
                        } else if (e == 'NICKNAME_TAKEN') {
                          message = strings.errorNicknameTaken;
                        } else if (e == 'UNKNOWN') {
                          message = strings.errorUnknown;
                        } else {
                          message = e.toString();
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message), backgroundColor: Colors.red)
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(strings.registerButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}