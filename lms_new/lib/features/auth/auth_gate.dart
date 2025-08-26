import 'package:flutter/material.dart';
import '../../core/token_store.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child});
  final Widget child;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _boot(); // ❗️initState က Future မပြန်တတ်အောင် သီးသန့် method
  }

  Future<void> _boot() async {
    final token = await TokenStore.readAccess();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      _authed = false;
      _checking = false;
      setState(() {});
      // redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }
    _authed = true;
    _checking = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_authed) {
      // frame callback ထဲက redirect သွားမယ်၊ ဒီနေရာက skeleton ပြနေစပြီး
      return const Scaffold(body: SizedBox.shrink());
    }
    return widget.child;
  }
}
