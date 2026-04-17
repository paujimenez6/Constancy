import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../providers/auth_provider.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final VoidCallback? onCancel;

  const UpdatePasswordScreen({super.key, this.onCancel});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSaving = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userEmail = context.select<AuthProvider, String?>((auth) => auth.currentUser?.correu);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.updatePasswordTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userEmail != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary.withValues(alpha:0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_circle_outlined, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            strings.updatingPasswordFor(userEmail),
                            style: TextStyle(fontSize: 14, color: colorScheme.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                TextFormField(
                  controller: _passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E]')),
                  ],
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: strings.newPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? strings.passwordTooShort : null,
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSaving = true);
                      try {
                        await context.read<AuthProvider>().updatePassword(_passwordController.text);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.passwordUpdated), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          String errorMsg = strings.errorUnknown;

                          if (e.toString().contains('same_password')) {
                            errorMsg = strings.errorSamePassword;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(errorMsg),
                                backgroundColor: Colors.red
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(strings.updatePasswordButton, style: const TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}