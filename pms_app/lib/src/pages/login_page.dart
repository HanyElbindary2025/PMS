import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	final _email = TextEditingController();
	final _password = TextEditingController();
	bool _loading = false;
	String? _error;

	Future<void> _login() async {
		setState(() { _loading = true; _error = null; });
		await Future.delayed(const Duration(milliseconds: 400));
		// Demo: accept any non-empty email/password, store fake token & role
		if (_email.text.isEmpty || _password.text.isEmpty) {
			setState(() { _loading = false; _error = 'Please enter email and password'; });
			return;
		}
		final sp = await SharedPreferences.getInstance();
		// Simple role mapping for testing: emails containing 'sys' => ADMIN (system user)
		// otherwise CREATOR (normal requester)
		final email = _email.text.trim().toLowerCase();
		final role = email.contains('sys') ? 'ADMIN' : 'CREATOR';
		await sp.setString('authToken', 'demo-token');
		await sp.setString('userRole', role);
		await sp.setString('userEmail', email);
		if (!mounted) return;
		Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: ConstrainedBox(
					constraints: const BoxConstraints(maxWidth: 420),
					child: Padding(
						padding: const EdgeInsets.all(24),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								const Text('PMS Login', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
								const SizedBox(height: 16),
								TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')), 
								const SizedBox(height: 12),
								TextField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
								const SizedBox(height: 16),
								if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
								const SizedBox(height: 8),
								FilledButton(
									onPressed: _loading ? null : _login,
									child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Sign in'),
								),
							],
						),
					),
				),
			),
		);
	}
}


