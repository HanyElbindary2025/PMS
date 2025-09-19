import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tickets_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';
import 'create_request_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int _selected = 0; // 0: Dashboard, 1: Create, 2: Tickets, 3: Users
	final _pages = const [DashboardPage(), CreateRequestPage(), TicketsPage(), UserManagementPage()];
	final _titles = const ['Dashboard', 'Create Request', 'My Tickets', 'Users'];
	String _role = 'CREATOR';

	@override
	void initState() {
		super.initState();
		SharedPreferences.getInstance().then((sp) {
			setState(() { _role = sp.getString('userRole') ?? 'CREATOR'; });
		});
	}

	Future<void> _logout() async {
		final sp = await SharedPreferences.getInstance();
		await sp.remove('authToken');
		await sp.remove('userRole');
		if (!mounted) return;
		Navigator.of(context).pushAndRemoveUntil(
			MaterialPageRoute(builder: (context) => const LoginPage()),
			(route) => false,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: Text(_titles[_selected])),
			drawer: Drawer(
				child: SafeArea(
					child: ListView(
						children: [
							const DrawerHeader(child: Text('PMS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
						ListTile(selected: _selected == 0, leading: const Icon(Icons.dashboard_customize), title: const Text('Dashboard'), onTap: () => setState(() => _selected = 0)),
						ListTile(selected: _selected == 1, leading: const Icon(Icons.add_box_outlined), title: const Text('Create Request'), onTap: () => setState(() => _selected = 1)),
						ListTile(selected: _selected == 2, leading: const Icon(Icons.list_alt), title: const Text('My Tickets'), onTap: () => setState(() => _selected = 2)),
						if (_role == 'ADMIN') ListTile(selected: _selected == 3, leading: const Icon(Icons.group), title: const Text('User Management'), onTap: () => setState(() => _selected = 3)),
							const Divider(),
							ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: _logout),
						],
					),
				),
			),
			body: _pages[_selected],
		);
	}
}


