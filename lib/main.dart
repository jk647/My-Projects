import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/splash/splash_screen.dart';
import 'constants/theme_color.dart';
import 'models/task_model.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';

// Route observer for navigation tracking
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// App initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(SubTaskAdapter());
  Hive.registerAdapter(TaskPriorityAdapter());
  Hive.registerAdapter(TaskRepeatTypeAdapter());

  runApp(const TaskuraApp());
}

// Main app widget
class TaskuraApp extends StatelessWidget {
  const TaskuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taskura',
      
      // App theme configuration
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryYellow,
        scaffoldBackgroundColor: AppColors.backgroundBlack,
        
        // Button theme configuration
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryYellow,
            foregroundColor: Colors.black,
            minimumSize: const Size(88, 48),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        
        // Icon button theme configuration
        iconButtonTheme: IconButtonThemeData(
          style: const ButtonStyle(
            minimumSize: MaterialStatePropertyAll(Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ),
      
      // Global gesture detector for keyboard dismissal
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child!,
        );
      },
      
      // App routes
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
      
      // Navigation observers
      navigatorObservers: [routeObserver],
    );
  }
}
