import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'generated/l10n.dart';
import 'features/auth/data/repositories/auth_provider.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eppzouncrrfkzkuapgjg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwcHpvdW5jcnJma3prdWFwZ2pnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NDE3NDcsImV4cCI6MjA5MDExNzc0N30.ByTuSooYY_i7BrEFDRvyQ0bA52v2TR3i7voH-FL9jhg',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => AuthRepository()),
      ],
      child: const ConstancyApp(),
    ),
  );
}

class ConstancyApp extends StatelessWidget {
  const ConstancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const fontFamily = 'Inter';
    return MaterialApp(
      title: 'Constancy',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,

      themeMode: ThemeMode.system,

      //Tema Clar
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x172748),
          brightness: Brightness.light,
        ),
      ),

      //Tema Fosc
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0x172748),
          brightness: Brightness.dark,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}