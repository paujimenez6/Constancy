import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/data/models/user_model.dart';
import 'features/auth/screens/mfa_challenge_screen.dart';
import 'features/auth/screens/update_password_screen.dart';
import 'features/navigation/screens/main_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'generated/l10n.dart';
import 'features/auth/data/repositories/auth_provider.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'core/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eppzouncrrfkzkuapgjg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwcHpvdW5jcnJma3prdWFwZ2pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NDE3NDcsImV4cCI6MjA5MDExNzc0N30.ByTuSooYY_i7BrEFDRvyQ0bA52v2TR3i7voH-FL9jhg',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        Provider(create: (_) => AuthRepository()),
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

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (session == null || event == AuthChangeEvent.signedOut) {
        authProvider.logout();
        if (mounted) setState(() => _isRecoveringPassword = false);
        return;
      }

      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() => _isRecoveringPassword = true);
        return;
      }

      if (session != null) {

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
            final userData = await Supabase.instance.client
                .from('profiles')
                .select()
                .eq('id', session.user.id)
                .single();
            authProvider.setUser(UserModel.fromJson(userData));
          } catch (e) {
            debugPrint("Error sincronitzant perfil: $e");
          }
        }

        if (event == AuthChangeEvent.userUpdated && _isRecoveringPassword) {
          setState(() => _isRecoveringPassword = false);
        }
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