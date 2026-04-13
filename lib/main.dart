import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/mfa_challenge_screen.dart';
import 'features/auth/screens/update_password_screen.dart';
import 'features/navigation/screens/main_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'generated/l10n.dart';
import 'features/auth/data/repositories/auth_provider.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'core/providers/settings_provider.dart';
import 'features/profiles/data/repositories/social_provider.dart';
import 'features/profiles/data/repositories/social_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => SocialRepository()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
      ],
      child: const ConstancyApp(),
    ),
  );
}

class ConstancyApp extends StatefulWidget {
  const ConstancyApp({super.key});

  @override
  State<ConstancyApp> createState() => _ConstancyAppState();
}

class _ConstancyAppState extends State<ConstancyApp> {
  bool _justVerified = false;
  bool _isRecoveringPassword = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    final authProvider = context.read<AuthProvider>();
    final authRepo = context.read<AuthRepository>();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (session == null || event == AuthChangeEvent.signedOut) {
        authProvider.logout();
        if (mounted) setState(() => _isRecoveringPassword = false);
        return;
      }

      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _isRecoveringPassword = true);
        return;
      }

      if (authProvider.isManualLogin && _justVerified) {
        setState(() => _justVerified = false);
      }

      if (event == AuthChangeEvent.signedIn && !authProvider.isManualLogin && authProvider.currentUser == null) {
        await Supabase.instance.client.auth.signOut();
        if (mounted) setState(() => _justVerified = true);
        return;
      }

      if (authProvider.currentUser == null || authProvider.currentUser!.id != session.user.id) {
        try {
          final userProfile = await authRepo.getUserProfile(session.user.id);
          authProvider.setUser(userProfile);
        } catch (e) {
          debugPrint("Error sincronitzant perfil: $e");
        }
      }

      if (event == AuthChangeEvent.userUpdated && _isRecoveringPassword) {
        setState(() => _isRecoveringPassword = false);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Inter';
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Constancy',
      debugShowCheckedModeBanner: false,

      locale: settings.locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      themeMode: settings.themeMode,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x172748),
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x172748),
          brightness: Brightness.dark,
        ),
      ),

      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;
          final authProvider = Provider.of<AuthProvider>(context);

          if (_isRecoveringPassword) {
            return UpdatePasswordScreen(
              onCancel: () {
                setState(() => _isRecoveringPassword = false);
              },
            );
          }

          if (_justVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.of(context).accountVerified),
                  backgroundColor: Colors.green,
                ),
              );
              _justVerified = false;
            });
          }
          if (session != null && !_justVerified && authProvider.currentUser?.id == session.user.id) {
            final bool hasMfaFactor = session.user.factors?.any((f) => f.status.name == 'verified') ?? false;
            final String currentAal = AuthRepository.getAalFromJWT(session.accessToken);

            if (hasMfaFactor && currentAal != 'aal2') return const MfaChallengeScreen();
            return const MainScreen();
          }

          else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}