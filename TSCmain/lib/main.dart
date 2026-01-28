import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
              home: const AuthGate(),
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _validateUser();
  }

  Future<void> _validateUser() async {
    final user = FirebaseAuth.instance.currentUser;

    // No user → go to Splash (normal flow)
    if (user == null) {
      _goToSplash();
      return;
    }

    try {
      // 🔥 Force token refresh
      await user.getIdToken(true);

      // Token valid → continue normal flow
      _goToSplash();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'user-disabled') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account was removed. Please log in again.',
            ),
          ),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (_) => false,
        );
      } else {
        _goToSplash();
      }
    }
  }

  void _goToSplash() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Temporary loader while validating session
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}