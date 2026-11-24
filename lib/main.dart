import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/main_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IventoryApp());
}

class IventoryApp extends StatelessWidget {
  const IventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}
