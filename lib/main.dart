import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'utils/theme_provider.dart';
import 'models/fishing_log.dart';
import 'models/user.dart';
import 'splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/log_detail_screen.dart';
import 'screens/fishing_log_list_screen.dart';
import 'screens/new_log_screen.dart';
import 'screens/edit_log_screen.dart';
import 'screens/login_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(FishingLogAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<FishingLog>('fishingLogs');
  await Hive.openBox<User>('users');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FishLog',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.lightBlue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot_password': (context) => const ForgotPasswordScreen(),
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/main':
                final username = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => MainScreen(username: username),
                );
              case '/fishing_log_list':
                final username = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => FishingLogListScreen(username: username),
                );
              case '/new_log':
                final username = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => NewLogScreen(username: username),
                );
              case '/edit_log':
                final logToEdit = settings.arguments as FishingLog;
                return MaterialPageRoute(
                  builder: (context) => EditLogScreen(logToEdit: logToEdit),
                );
              case '/log_detail':
                final fishingLog = settings.arguments as FishingLog;
                return MaterialPageRoute(
                  builder: (context) => LogDetailScreen(fishingLog: fishingLog),
                );
              case '/profile':
                final username = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: username),
                );
            }
            return null;
          },
        );
      },
    );
  }
}
