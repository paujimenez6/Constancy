import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../generated/l10n.dart';
import '../../auth/data/repositories/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.navProfile),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        backgroundImage: user.imatgePerfil != null
                            ? NetworkImage(user.imatgePerfil!)
                            : null,
                        child: user.imatgePerfil == null
                            ? Text(
                          user.nickname[0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary
                          ),
                        )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(user.nickname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(user.correu, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(strings.xpLevel(user.nivellXP)),
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildProfileOption(
              icon: Icons.edit_outlined,
              title: strings.editProfile,
              textColor: Colors.black,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            _buildProfileOption(
              icon: Icons.settings_outlined,
              title: strings.settings,
              textColor: Colors.black,
              onTap: () {
                // Properament: Settings
              },
            ),
            const Divider(height: 40, thickness: 1),
            _buildProfileOption(
              icon: Icons.logout,
              title: strings.logout,
              textColor: Colors.red,
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.read<AuthProvider>().logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required IconData icon, required String title, required VoidCallback onTap, required Color textColor,}) {
    Color color = textColor;
    if (icon == Icons.logout) color = Colors.red;
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      onTap: onTap,
    );
  }
}