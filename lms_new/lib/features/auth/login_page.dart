import 'package:flutter/material.dart';
import '../../core/dio_client.dart';
import '../../core/token_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final emailCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _busy = false;

  Future<void> _login() async {
    setState(() => _busy = true);
    try {
      final r = await DioClient.i().dio.post(
        '/users/token/',
        data: {
          // backend login payload နဲ့ကိုက်အောင် ပြောင်းနိုင်
          'username': usernameCtrl.text.trim(),
          'password': passCtrl.text,
        },
      );

      final data = (r.data as Map);

      // backend response keys မတူနိုင်လို့ fallback တွေ ထားပေး
      final access =
          data['access']?.toString() ??
          data['access_token']?.toString() ??
          data['token']?.toString();

      final refresh =
          data['refresh']?.toString() ?? data['refresh_token']?.toString();

      if (access == null || access.isEmpty) {
        throw Exception('No access token returned.');
      }

      // ✅ TokenStore ထဲကို သိမ်း — project style အတိုင်း
      await TokenStore.writeAccess(access);
      if (refresh != null && refresh.isNotEmpty) {
        await TokenStore.writeRefresh(refresh);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/classrooms');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameCtrl,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.username,
                ],
                decoration: const InputDecoration(
                  labelText: 'Email / Username',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(labelText: 'Password'),
                onSubmitted: (_) => _busy ? null : _login(),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _login,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login),
                label: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
