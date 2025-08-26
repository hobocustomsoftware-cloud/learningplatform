import 'package:go_router/go_router.dart';
import '../features/home/homepage.dart';
import '../features/courses/course_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, _) => const HomePage()),
    GoRoute(
      path: '/course/:id', // 👈 register this
      builder: (_, st) {
        final id = int.parse(st.pathParameters['id']!);
        return CourseDetailPage(id: id);
      },
    ),
  ],
);
