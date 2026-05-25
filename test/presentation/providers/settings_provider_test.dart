import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Constancy/presentation/providers/settings_provider.dart';

void main() {
  late SettingsProvider provider;

  setUp(() {
    provider = SettingsProvider();
  });

  group('SettingsProvider 100% Coverage', () {

    test('Valors inicials són correctes', () {
      expect(provider.themeMode, ThemeMode.system);
      expect(provider.locale, const Locale('ca'));
    });

    test('setThemeMode actualitza l\'estat i notifica', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
      expect(notified, isTrue);
    });

    test('setLocale actualitza l\'estat i notifica', () {
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      const newLocale = Locale('es');
      provider.setLocale(newLocale);

      expect(provider.locale, newLocale);
      expect(notified, isTrue);
    });
  });
}