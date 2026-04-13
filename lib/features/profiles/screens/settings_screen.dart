import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../generated/l10n.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/data/repositories/auth_provider.dart';
import '../../auth/data/repositories/auth_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _mfaEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMFAStatus();
  }

  Future<void> _loadMFAStatus() async {
    final enabled = await context.read<AuthRepository>().isMFAEnabled();
    if (mounted) {
      setState(() {
        _mfaEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Container(
        width: 145,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.colorScheme.primary),
            style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null || _isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          _buildDropdown<ThemeMode>(
            label: strings.theme,
            value: settings.themeMode,
            items: [
              DropdownMenuItem(value: ThemeMode.system, child: Text(strings.themeSystem)),
              DropdownMenuItem(value: ThemeMode.light, child: Text(strings.themeLight)),
              DropdownMenuItem(value: ThemeMode.dark, child: Text(strings.themeDark)),
            ],
            onChanged: (m) => settings.setThemeMode(m!),
          ),
          _buildDropdown<String>(
            label: strings.language,
            value: settings.locale.languageCode,
            items: [
              DropdownMenuItem(value: 'ca', child: Text(strings.langCatalan)),
              DropdownMenuItem(value: 'es', child: Text(strings.langSpanish)),
              DropdownMenuItem(value: 'en', child: Text(strings.langEnglish)),
            ],
            onChanged: (code) => settings.setLocale(Locale(code!)),
          ),
          _buildDropdown<TipusPrivacitat>(
            label: strings.privacy,
            value: user.configuracioPrivacitat,
            items:  [
              DropdownMenuItem(value: TipusPrivacitat.public, child: Text(strings.public)),
              DropdownMenuItem(value: TipusPrivacitat.privat, child: Text(strings.private)),
              DropdownMenuItem(value: TipusPrivacitat.amics, child: Text(strings.friends)),
            ],
            onChanged: (nouValor) async {
              if (nouValor != null) {
                await context.read<AuthRepository>().updatePrivacy(user.id, nouValor);
                if (mounted) {
                  context.read<AuthProvider>().updateProfilePrivacy(nouValor);
                }
              }
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),

          SwitchListTile(
            secondary: Icon(Icons.security_outlined, color: theme.colorScheme.primary),
            title: Text(strings.twoFactorAuth),
            subtitle: Text(_mfaEnabled ? strings.mfaEnabled : strings.mfaDisabled),
            value: _mfaEnabled,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (val) {
              if (val) {
                _showMFAEnrollmentDialog();
              } else {
                _confirmDisableMFA();
              }
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 32),
          ),

          ListTile(
            leading: const Icon(Icons.delete_outlined, color: Colors.red),
            title: Text(strings.deleteAccount, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _confirmDeleteAccount(),
          ),
        ],
      ),
    );
  }

  void _showMFAEnrollmentDialog() async {
    final strings = S.of(context);
    final authRepo = context.read<AuthRepository>();
    final theme = Theme.of(context);
    final codeController = TextEditingController();

    try {
      final enrollData = await authRepo.enrollMFA();
      final String secret = enrollData.totp.secret;
      final String factorId = enrollData.id;

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 24),
                Icon(Icons.shield_outlined, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(strings.mfaEnrollTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(strings.mfaEnrollSubtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      SelectableText(
                        secret,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 3,
                          color: theme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: secret));
                          _showTopToast(strings.secretCopied);
                        },
                        icon: const Icon(Icons.copy_outlined, size: 20),
                        label: Text(strings.copySecret),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(strings.mfaLabelCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: "000000",
                    hintStyle: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                    counterText: "",
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadMFAStatus();
                        },
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(strings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await authRepo.verifyMFA(factorId, codeController.text);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.mfaSuccess), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
                              _loadMFAStatus();
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.mfaError), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(strings.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error enrolament: $e");
    }
  }

  void _confirmDisableMFA() {
    final strings = S.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(
        context: context,
        icon: Icons.warning_amber_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        title: strings.twoFactorAuth,
        description: strings.mfaDisableConfirm,
        confirmLabel: strings.confirm,
        isDestructive: true,
        onConfirm: () async {
          final authRepo = context.read<AuthRepository>();
          final factorId = await authRepo.getMFAFactorId();
          if (factorId != null) {
            await authRepo.unenrollMFA(factorId);
            if (mounted) {
              Navigator.pop(context);
              _loadMFAStatus();
            }
          }
        },
      ),
    );
  }

  void _confirmDeleteAccount() {
    final strings = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildActionSheet(
        context: context,
        icon: Icons.dangerous_outlined,
        iconColor: Theme.of(context).colorScheme.primary,
        title: strings.deleteAccount,
        description: strings.deleteAccountConfirm,
        confirmLabel: strings.confirm,
        isDestructive: true,
        onConfirm: () async {
          await context.read<AuthRepository>().deleteAccount();
          if (mounted) {
            context.read<AuthProvider>().logout();
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.deletedAccount), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
            );
          }
        },
      ),
    );
  }

  Widget _buildActionSheet({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String confirmLabel,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final strings = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2)
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                        strings.cancel,
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isDestructive ? Colors.red : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTopToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF323232).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}