import 'package:Constancy/persistence/repositories/league_repository.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'domain/services/league_service.dart';
import 'generated/l10n.dart';
import 'presentation/screens/mfa_challenge_screen.dart';
import 'presentation/screens/update_password_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/social_provider.dart';
import 'presentation/providers/habit_provider.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/social_service.dart';
import 'domain/services/habit_service.dart';
import 'persistence/repositories/auth_repository.dart';
import 'persistence/repositories/social_repository.dart';
import 'persistence/repositories/habit_repository.dart';

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
        Provider(create: (_) => HabitRepository()),
        Provider(create: (_) => LeagueRepository()),
        ProxyProvider<AuthRepository, AuthService>(
          update: (context, authRepo, previous) => AuthService(authRepo),
        ),
        ProxyProvider<SocialRepository, SocialService>(
          update: (context, socialRepo, previous) => SocialService(socialRepo),
        ),
        ProxyProvider<HabitRepository, HabitService>(
          update: (context, habitRepo, previous) => HabitService(habitRepo),
        ),
        ProxyProvider<LeagueRepository, LeagueService>(
          update: (context, leagueRepo, previous) => LeagueService(leagueRepo),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
          update: (context, authService, previous) => previous ?? AuthProvider(authService),
        ),
        ChangeNotifierProxyProvider<SocialService, SocialProvider>(
          create: (context) => SocialProvider(context.read<SocialService>()),
          update: (context, socialService, previous) => previous ?? SocialProvider(socialService),
        ),
        ChangeNotifierProxyProvider<HabitService, HabitProvider>(
          create: (context) => HabitProvider(context.read<HabitService>()),
          update: (context, habitService, previous) => previous ?? HabitProvider(habitService),
        ),
        ChangeNotifierProxyProvider<LeagueService, LeagueProvider>(
          create: (context) => LeagueProvider(context.read<LeagueService>()),
          update: (context, leagueService, previous) => previous ?? LeagueProvider(leagueService),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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