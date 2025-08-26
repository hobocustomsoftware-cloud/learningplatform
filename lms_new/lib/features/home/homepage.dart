// lib/features/home/homepage.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/dio_client.dart';
import '../../core/api_env.dart';
import '../courses/courses_page.dart';
import '../classroom/classroom_list_page.dart';
import '../auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _pinging = false;
  String? _lastPing;

  Future<void> _ping() async {
    setState(() {
      _pinging = true;
      _lastPing = null;
    });
    try {
      // backend health (exists if you added /api/live; otherwise use live-classes)
      final res = await DioClient.i().dio.get(ApiEnv.api('/live'));
      setState(() => _lastPing = 'OK: ${res.data}');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backend OK: ${res.statusCode}')));
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Ping failed';
      setState(() => _lastPing = 'ERR: $msg');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _pinging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cards = <_HomeCard>[
      _HomeCard(
        title: 'Courses',
        icon: Icons.menu_book_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CoursesPage()),
        ),
      ),
      _HomeCard(
        title: 'Live Classes',
        icon: Icons.live_tv_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClassroomListPage()),
        ),
      ),
      _HomeCard(
        title: 'API Ping',
        icon: Icons.health_and_safety_rounded,
        trailing: _pinging
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow_rounded),
        onTap: _pinging ? null : _ping,
        subtitle: _lastPing,
      ),
      _HomeCard(
        title: 'Logout',
        icon: Icons.logout_rounded,
        onTap: () async {
          // clear tokens if you used flutter_secure_storage
          // (safe even if not present)
          try {
            // ignore: use_build_context_synchronously
            final storageClear = ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Logged out')));
            // If you store with FlutterSecureStorage:
            // const storage = FlutterSecureStorage();
            // await storage.delete(key: 'access_token');
            // await storage.delete(key: 'refresh_token');
            await storageClear.closed;
          } finally {
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (_) => false,
            );
          }
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LMS Home'),
        actions: [
          IconButton(
            tooltip: 'Ping',
            onPressed: _pinging ? null : _ping,
            icon: const Icon(Icons.wifi_tethering_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: cards.length,
        itemBuilder: (_, i) => _HomeCardTile(card: cards[i]),
      ),
    );
  }
}

class _HomeCard {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  _HomeCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.subtitle,
    this.trailing,
  });
}

class _HomeCardTile extends StatelessWidget {
  final _HomeCard card;
  const _HomeCardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: card.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF151922),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(card.icon, size: 28),
                  const Spacer(),
                  if (card.trailing != null) card.trailing!,
                ],
              ),
              const Spacer(),
              Text(card.title, style: Theme.of(context).textTheme.titleMedium),
              if (card.subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  card.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
