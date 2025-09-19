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
		// Role mapping for demo accounts
		final email = _email.text.trim().toLowerCase();
		String role = 'CREATOR'; // Default role
		
		// Map specific demo accounts to their roles
		switch (email) {
			// New PMS accounts
			case 'admin@pms.com':
				role = 'ADMIN';
				break;
			case 'service.manager@pms.com':
				role = 'SERVICE_MANAGER';
				break;
			case 'technical.analyst@pms.com':
				role = 'TECHNICAL_ANALYST';
				break;
			case 'solution.architect@pms.com':
				role = 'SOLUTION_ARCHITECT';
				break;
			case 'developer@pms.com':
				role = 'DEVELOPER';
				break;
			case 'qa.engineer@pms.com':
				role = 'QA_ENGINEER';
				break;
			case 'devops@pms.com':
				role = 'DEVOPS_ENGINEER';
				break;
			case 'customer@pms.com':
				role = 'CREATOR';
				break;
			// Legacy test accounts
			case 'admin@test.com':
				role = 'ADMIN';
				break;
			case 'manager@test.com':
				role = 'SERVICE_MANAGER';
				break;
			case 'servicedesk@test.com':
				role = 'SERVICE_DESK';
				break;
			case 'analyst@test.com':
				role = 'TECHNICAL_ANALYST';
				break;
			case 'developer@test.com':
				role = 'DEVELOPER';
				break;
			case 'qa@test.com':
				role = 'QA_ENGINEER';
				break;
			case 'architect@test.com':
				role = 'SOLUTION_ARCHITECT';
				break;
			case 'devops@test.com':
				role = 'DEVOPS_ENGINEER';
				break;
			case 'creator@test.com':
				role = 'CREATOR';
				break;
			case 'hany@admin.com':
				role = 'ADMIN';
				break;
			default:
				role = 'CREATOR'; // Default for any other email
		}
		
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


