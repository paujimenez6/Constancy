import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _validateEmail(String? value, S strings) {
    if (value == null || value.isEmpty) return strings.fieldRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return strings.invalidEmail;
    return null;
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
              TextFormField(controller: _nomController, decoration: InputDecoration(labelText: strings.nameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _cognomController, decoration: InputDecoration(labelText: strings.lastNameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _nicknameController, decoration: InputDecoration(labelText: strings.usernameLabel), validator: (v) => v!.isEmpty ? strings.fieldRequired : null),
              const SizedBox(height: 10),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: strings.emailLabel), keyboardType: TextInputType.emailAddress, validator: (v) => _validateEmail(v, strings)),
              const SizedBox(height: 10),

              TextFormField(
                  controller: _passwordController,
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
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.creatingAccount)));

                      await context.read<AuthRepository>().signUp(
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