import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/home_page.dart';
import 'package:pms_app/config/app_config.dart';

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
		final email = _email.text.trim().toLowerCase();
		String role = 'CREATOR'; // Default role
		String? userId;
		
		// Try to fetch role from backend first
		try {
            final response = await http.get(
                Uri.parse('${AppConfig.baseUrl}/users'),
				headers: {'Content-Type': 'application/json'},
			);
			
        if (response.statusCode == 200) {
          final users = json.decode(response.body) as List;
          final user = users.firstWhere(
            (u) => (u['email'] as String).toLowerCase() == email,
            orElse: () => null,
          );
          
          if (user != null) {
            role = user['role'] as String;
            userId = user['id'] as String;
            print('✅ Role and ID fetched from backend: $role, $userId for $email');
          } else {
            print('⚠️ User not found in backend, using fallback role mapping');
            role = _getFallbackRole(email);
            userId = null;
          }
        } else {
          print('⚠️ Backend not available, using fallback role mapping');
          role = _getFallbackRole(email);
          userId = null;
        }
		} catch (e) {
			print('⚠️ Error fetching role from backend: $e, using fallback role mapping');
			role = _getFallbackRole(email);
			userId = null;
		}
		
		await sp.setString('authToken', 'demo-token');
		await sp.setString('userRole', role);
		await sp.setString('userEmail', email);
		if (userId != null) {
			await sp.setString('userId', userId);
		}
		if (!mounted) return;
		Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
	}

	String _getFallbackRole(String email) {
		// Fallback role mapping for demo accounts
		switch (email) {
			// New PMS accounts
			case 'admin@pms.com':
				return 'ADMIN';
			case 'service.manager@pms.com':
				return 'SERVICE_MANAGER';
			case 'technical.analyst@pms.com':
				return 'TECHNICAL_ANALYST';
			case 'solution.architect@pms.com':
				return 'SOLUTION_ARCHITECT';
			case 'developer@pms.com':
				return 'DEVELOPER';
			case 'qa.engineer@pms.com':
				return 'QA_ENGINEER';
			case 'devops@pms.com':
				return 'DEVOPS_ENGINEER';
			case 'customer@pms.com':
				return 'CREATOR';
			// Legacy test accounts
			case 'admin@test.com':
				return 'ADMIN';
			case 'manager@test.com':
				return 'SERVICE_MANAGER';
			case 'servicedesk@test.com':
				return 'SERVICE_DESK';
			case 'analyst@test.com':
				return 'TECHNICAL_ANALYST';
			case 'developer@test.com':
				return 'DEVELOPER';
			case 'qa@test.com':
				return 'QA_ENGINEER';
			case 'architect@test.com':
				return 'SOLUTION_ARCHITECT';
			case 'devops@test.com':
				return 'DEVOPS_ENGINEER';
			case 'creator@test.com':
				return 'CREATOR';
			case 'hany@admin.com':
				return 'ADMIN';
			default:
				return 'CREATOR'; // Default for any other email
		}
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


