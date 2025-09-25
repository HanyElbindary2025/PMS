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
		
		// Validate input
		if (_email.text.isEmpty || _password.text.isEmpty) {
			setState(() { _loading = false; _error = 'Please enter email and password'; });
			return;
		}
		
		final email = _email.text.trim().toLowerCase();
		
		// Try to fetch user from backend
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
            // User found - proceed with login
            final role = user['role'] as String;
            final userId = user['id'] as String;
            final userName = user['name'] as String;
            
            print('✅ User authenticated: $userName ($role) - $email');
            
            // Store user session
            final sp = await SharedPreferences.getInstance();
            await sp.setString('authToken', 'authenticated-token');
            await sp.setString('userRole', role);
            await sp.setString('userEmail', email);
            await sp.setString('userId', userId);
            await sp.setString('userName', userName);
            
            if (!mounted) return;
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
          } else {
            // User not found - show error
            setState(() { 
              _loading = false; 
              _error = 'Username not found. Please contact your administrator to create an account.'; 
            });
            print('❌ Login failed: User not found - $email');
          }
        } else {
          setState(() { 
            _loading = false; 
            _error = 'Unable to connect to server. Please try again later.'; 
          });
          print('❌ Login failed: Backend not available (${response.statusCode})');
        }
		} catch (e) {
			setState(() { 
        _loading = false; 
        _error = 'Connection error. Please check your internet connection and try again.'; 
      });
			print('❌ Login failed: Connection error - $e');
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
								const SizedBox(height: 8),
								const Text('Available accounts:', style: TextStyle(fontSize: 12, color: Colors.grey)),
								const Text('admin@pms.com, service.manager@pms.com, developer@pms.com', style: TextStyle(fontSize: 10, color: Colors.grey)),
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


