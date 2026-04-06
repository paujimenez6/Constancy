import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../generated/l10n.dart';
import '../../navigation/screens/main_screen.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/auth_provider.dart';

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

                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: Image.asset(
                      'assets/images/Logo_Constancy.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  strings.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  strings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: strings.emailLabel,
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _validateEmail(value, strings),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: strings.passwordLabel,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: colorScheme.primary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? strings.fieldRequired : null,
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        context.read<AuthProvider>().isManualLogin = true;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.validatingData)));

                        final user = await context.read<AuthRepository>().signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );

                        if (mounted) {
                          context.read<AuthProvider>().setUser(user);

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(strings.welcomeUser(user.nickname)))
                          );
                          final supabase = Supabase.instance.client;
                          print("sessió: ${supabase.auth.currentSession?.user.id}");
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()),);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.loginError), backgroundColor: Colors.red)
                        );
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
                  child: Text(
                    strings.loginButton,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen())
                  ),
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