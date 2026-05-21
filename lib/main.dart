import 'package:Constancy/persistence/repositories/achievement_repository.dart';
import 'package:Constancy/persistence/repositories/league_repository.dart';
import 'package:Constancy/persistence/repositories/mission_repository.dart';
import 'package:Constancy/persistence/repositories/notification_repository.dart';
import 'package:Constancy/persistence/repositories/shop_repository.dart';
import 'package:Constancy/presentation/providers/achievement_provider.dart';
import 'package:Constancy/presentation/providers/league_provider.dart';
import 'package:Constancy/presentation/providers/mission_provider.dart';
import 'package:Constancy/presentation/providers/notification_provider.dart';
import 'package:Constancy/presentation/providers/shop_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'domain/services/achievement_service.dart';
import 'domain/services/league_service.dart';
import 'domain/services/mission_service.dart';
import 'domain/services/notification_service.dart';
import 'domain/services/shop_service.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
        Provider(create: (_) => MissionRepository()),
        Provider(create: (_) => ShopRepository()),
        Provider(create: (_) => AchievementRepository()),
        Provider(create: (_) => NotificationRepository()),
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
        ProxyProvider<MissionRepository, MissionService>(
          update: (context, missionRepo, previous) => previous ?? MissionService(missionRepo),
        ),
        ProxyProvider<ShopRepository, ShopService>(
          update: (context, shopRepo, previous) => ShopService(shopRepo),
        ),
        ProxyProvider<AchievementRepository, AchievementService>(
          update: (context, achievementRepo, previous) => AchievementService(achievementRepo),
        ),
        ProxyProvider<NotificationRepository, NotificationService>(
          update: (context, notificationRepo, previous) => NotificationService(notificationRepo),
        ),
        ChangeNotifierProxyProvider2<AuthService, AchievementService, AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>(), context.read<AchievementService>(),),
          update: (context, authService, achievementService, previous) =>
          previous ?? AuthProvider(authService, achievementService),
        ),
        ChangeNotifierProxyProvider3<SocialService, MissionService, AchievementService, SocialProvider>(
          create: (context) => SocialProvider(context.read<SocialService>(),context.read<MissionService>(),context.read<AchievementService>(),),
          update: (context, socialService, missionService, achievementService, previous) =>
          previous ?? SocialProvider(socialService, missionService, achievementService),
        ),
        ChangeNotifierProxyProvider3<HabitService, MissionService, AchievementService, HabitProvider>(
          create: (context) => HabitProvider(context.read<HabitService>(), context.read<MissionService>(), context.read<AchievementService>(),),
          update: (context, habitService, missionService, achievementService, previous) =>
          previous ?? HabitProvider(habitService, missionService, achievementService),
        ),
        ChangeNotifierProxyProvider2<LeagueService, MissionService, LeagueProvider>(
          create: (context) => LeagueProvider(context.read<LeagueService>(), context.read<MissionService>(),),
          update: (context, leagueService, missionService, previous) => previous ?? LeagueProvider(leagueService, missionService),
        ),
        ChangeNotifierProxyProvider<MissionService, MissionProvider>(
          create: (context) => MissionProvider(context.read<MissionService>()),
          update: (context, missionService, previous) => previous ?? MissionProvider(missionService),
        ),
        ChangeNotifierProxyProvider<ShopService, ShopProvider>(
          create: (context) => ShopProvider(context.read<ShopService>()),
          update: (context, shopService, previous) => previous ?? ShopProvider(shopService),
        ),
        ChangeNotifierProxyProvider<AchievementService, AchievementProvider>(
          create: (context) => AchievementProvider(context.read<AchievementService>()),
          update: (context, achievementService, previous) => previous ?? AchievementProvider(achievementService),
        ),
        ChangeNotifierProxyProvider2<NotificationService, AuthService, NotificationProvider>(
          create: (context) => NotificationProvider(context.read<NotificationService>(), context.read<AuthService>()),
          update: (context, notificationService, authService, previous) => previous ?? NotificationProvider(notificationService, authService),
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
    final notificationProvider = context.read<NotificationProvider>();

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

          notificationProvider.initializeNotifications(session.user.id);
          notificationProvider.setupListeners();
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
      navigatorKey: navigatorKey,
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