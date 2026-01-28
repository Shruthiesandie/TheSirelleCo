import 'package:flutter/material.dart';
import 'splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/app_locale.dart';
import 'controllers/app_theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'home/home_page.dart';
import 'pages/membership_page.dart';
import 'pages/cart_page.dart';
import 'pages/profile_page.dart';
import 'pages/search_page.dart';
import 'pages/love_page.dart';
import 'pages/allcategories_page.dart';
import 'pages/login_page.dart';
import 'pages/create_account_page.dart';
import 'pages/username_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppLocale.load();
  await AppTheme.load();

  runApp(const MyRootApp());
}

class MyRootApp extends StatelessWidget {
  const MyRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.locale,
      builder: (_, locale, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeMode,
          builder: (_, themeMode, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: const [
                Locale('en'),
                Locale('hi'),
                Locale('kn'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const SplashScreen(),
              routes: {
                "/home": (_) => const HomePage(),
                "/membership": (_) => const MembershipPage(),
                "/cart": (_) => const CartPage(),
                "/profile": (_) => const ProfilePage(),
                "/search": (_) => const SearchPage(),
                "/love": (_) => const LovePage(),
                "/categories": (_) => const AllCategoriesPage(),
                "/login": (_) => LoginPage(),
                "/register": (_) => const CreateAccountPage(),
                "/username": (_) => const UsernamePage(),
              },
              themeMode: themeMode,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
            );
          },
        );
      },
    );
  }
}