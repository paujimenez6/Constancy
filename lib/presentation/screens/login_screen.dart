import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String? _validateEmail(String? value, S strings) {
    if (value == null || value.isEmpty) return strings.fieldRequired;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return strings.invalidEmail;
    return null;
  }

  void _showForgotPasswordSheet(BuildContext context) {
    final emailController = TextEditingController();
    final sheetFormKey = GlobalKey<FormState>();
    final strings = S.of(context);
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        String? serverError;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: sheetFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(height: 24),
                        Icon(Icons.lock_reset_rounded, size: 48, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(strings.forgotPassword, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(strings.sendResetLinkSubTitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: strings.emailLabel,
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            errorText: serverError,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => _validateEmail(value, strings),
                          onChanged: (_) { if (serverError != null) setSheetState(() => serverError = null); },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (sheetFormKey.currentState!.validate()) {
                              final email = emailController.text.trim();
                              try {
                                final exists = await authProvider.checkEmailExists(email);
                                if (exists) {
                                  await authProvider.sendPasswordResetEmail(email);
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(strings.resetEmailSent), backgroundColor: Colors.green),
                                    );
                                  }
                                } else {
                                  setSheetState(() => serverError = strings.errorEmailNotExists);
                                }
                              } catch (e) {
                                setSheetState(() => serverError = strings.errorUnknown);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(strings.sendResetLink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Hero(
                  tag: 'logo',
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha:0.35), blurRadius: 20, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Image.asset('assets/images/Logo_Constancy.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(strings.loginTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 8),
                Text(strings.loginSubtitle, textAlign: TextAlign.center, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha:0.7))),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
                  ],
                  decoration: InputDecoration(labelText: strings.emailLabel, labelStyle: TextStyle(color: colorScheme.onSurfaceVariant)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _validateEmail(value, strings),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E]')),
                  ],
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: strings.passwordLabel,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colorScheme.primary),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? strings.fieldRequired : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => _showForgotPasswordSheet(context), child: Text(strings.forgotPassword)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.validatingData)));
                        await context.read<AuthProvider>().signIn(_emailController.text.trim(), _passwordController.text.trim());
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.loginError), backgroundColor: Colors.red));
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(strings.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
                  child: Text(strings.noAccount),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}