import 'dart:async';
import 'package:flutter/material.dart';

import 'core/dio_client.dart';
import 'features/home/homepage.dart';
import 'features/courses/course_detail_page.dart';
import 'features/classroom/classroom_list_page.dart';
import 'features/classroom/classroom_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DioClient.i().init(); // ❗️Token interceptor, baseUrl စတင်ဖို့ အရေးကြီး

  FlutterError.onError = (details) => FlutterError.presentError(details);

  runZonedGuarded(() => runApp(const MyApp()), (e, s) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _theme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFFE11D48),
        secondary: const Color(0xFF64748B),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F1115),
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (d) => Material(
      color: const Color(0xFF0F1115),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            '😬 Oops!\n${d.exception}\n\n${d.stack}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );

    return MaterialApp(
      title: 'LMS',
      debugShowCheckedModeBanner: false,
      theme: _theme(),

      // ✅ App ဖွင့်ချင်း AuthGate နဲ့ ပတ်လမ်း — token မရှိရင် /login သို့
      home: const AuthGate(child: HomePage()),

      // ✅ Static routes
      routes: {
        '/login': (_) => const LoginPage(),
        '/classrooms': (_) => const ClassroomListPage(),
      },

      // ✅ Dynamic routes
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        final courseMatch = RegExp(r'^/course/(\d+)$').firstMatch(name);
        if (courseMatch != null) {
          final id = int.parse(courseMatch.group(1)!);
          return MaterialPageRoute(
            builder: (_) => CourseDetailPage(id: id),
            settings: settings,
          );
        }

        final roomMatch = RegExp(r'^/classroom/(\d+)$').firstMatch(name);
        if (roomMatch != null) {
          final id = int.parse(roomMatch.group(1)!);
          return MaterialPageRoute(
            builder: (_) => ClassroomPage(classId: id),
            settings: settings,
          );
        }

        return _errorRoute('No route for $name');
      },
    );
  }

  Route _errorRoute(String msg) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Route error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              msg,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
