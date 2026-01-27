import 'package:flutter/material.dart';
import 'splash/splash_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'controllers/app_locale.dart';
import 'controllers/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class SessionManager {
  static const String _lastActiveKey = 'last_active_timestamp';
  static const int maxInactiveDays = 15;

  static Future<void> updateLastActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastActiveKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActive = prefs.getInt(_lastActiveKey);

    if (lastActive == null) return false;

    final last = DateTime.fromMillisecondsSinceEpoch(lastActive);
    final diff = DateTime.now().difference(last).inDays;

    return diff >= maxInactiveDays;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastActiveKey);
  }
}

class MyRootApp extends StatefulWidget {
  const MyRootApp({super.key});

  @override
  _MyRootAppState createState() => _MyRootAppState();
}

class _MyRootAppState extends State<MyRootApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      SessionManager.updateLastActive();
    }
  }

  Future<void> _checkSession() async {
    final expired = await SessionManager.isSessionExpired();

    if (expired) {
      await FirebaseAuth.instance.signOut();
      await SessionManager.clear();
    }
  }

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