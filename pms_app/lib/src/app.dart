import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

class PmsApp extends StatefulWidget {
	const PmsApp({super.key});

	@override
	State<PmsApp> createState() => _PmsAppState();
}

class _PmsAppState extends State<PmsApp> {
	Future<bool> _isLoggedIn() async {
		final sp = await SharedPreferences.getInstance();
		// For development: uncomment the next line to force logout
		// await sp.remove('authToken');
		return sp.getString('authToken') != null;
	}

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			debugShowCheckedModeBanner: false,
			title: 'PMS',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1f6feb)),
				useMaterial3: true,
			),
			home: FutureBuilder(
				future: _isLoggedIn(),
				builder: (context, snap) {
					if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
					return snap.data == true ? const HomePage() : const LoginPage();
				},
			),
		);
	}
}


