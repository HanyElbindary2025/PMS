import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tickets_page.dart';
import 'dashboard_page.dart';
import 'user_management_page.dart';
import 'create_request_page.dart';
import 'professional_tickets_page.dart';
import 'professional_dashboard_page.dart';
import 'admin_settings_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
	const HomePage({super.key});

	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int _selected = 0; // 0: Dashboard, 1: Create, 2: Tickets, 3: Users
	bool _useProfessionalUI = true; // Toggle between basic and professional UI
	String _role = 'CREATOR';
	
	List<Widget> get _pages => _useProfessionalUI 
		? [ProfessionalDashboardPage(), CreateRequestPage(), ProfessionalTicketsPage(), UserManagementPage(), AdminSettingsPage()]
		: [DashboardPage(), CreateRequestPage(), TicketsPage(), UserManagementPage(), AdminSettingsPage()];
	
	List<String> get _titles => _useProfessionalUI
		? ['Professional Dashboard', 'Create Request', 'Professional Tickets', 'Users', 'Admin Settings']
		: ['Dashboard', 'Create Request', 'My Tickets', 'Users', 'Admin Settings'];

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
			appBar: AppBar(
				title: Text(_titles[_selected]),
				actions: [
					PopupMenuButton<String>(
						onSelected: (value) {
							if (value == 'toggle_ui') {
								setState(() => _useProfessionalUI = !_useProfessionalUI);
							}
						},
						itemBuilder: (context) => [
							PopupMenuItem(
								value: 'toggle_ui',
								child: Row(
									children: [
										Icon(_useProfessionalUI ? Icons.toggle_on : Icons.toggle_off),
										const SizedBox(width: 8),
										Text(_useProfessionalUI ? 'Switch to Basic UI' : 'Switch to Professional UI'),
									],
								),
							),
						],
						child: const Icon(Icons.settings),
					),
				],
			),
			drawer: Drawer(
				child: SafeArea(
					child: ListView(
						children: [
							DrawerHeader(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										const Text('Professional PMS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
										const SizedBox(height: 8),
										Text('Role: $_role', style: TextStyle(color: Colors.grey.shade600)),
										Text('UI: ${_useProfessionalUI ? 'Professional' : 'Basic'}', style: TextStyle(color: Colors.grey.shade600)),
									],
								),
							),
							ListTile(
								selected: _selected == 0,
								leading: const Icon(Icons.dashboard_customize),
								title: Text(_useProfessionalUI ? 'Professional Dashboard' : 'Dashboard'),
								onTap: () => setState(() => _selected = 0),
							),
							ListTile(
								selected: _selected == 1,
								leading: const Icon(Icons.add_box_outlined),
								title: const Text('Create Request'),
								onTap: () => setState(() => _selected = 1),
							),
							ListTile(
								selected: _selected == 2,
								leading: const Icon(Icons.list_alt),
								title: Text(_useProfessionalUI ? 'Professional Tickets' : 'My Tickets'),
								onTap: () => setState(() => _selected = 2),
							),
							if (_role == 'ADMIN') ...[
								ListTile(
									selected: _selected == 3,
									leading: const Icon(Icons.group),
									title: const Text('User Management'),
									onTap: () => setState(() => _selected = 3),
								),
								ListTile(
									selected: _selected == 4,
									leading: const Icon(Icons.settings),
									title: const Text('Admin Settings'),
									onTap: () => setState(() => _selected = 4),
								),
							],
							const Divider(),
							ListTile(
								leading: const Icon(Icons.logout),
								title: const Text('Logout'),
								onTap: _logout,
							),
						],
					),
				),
			),
			body: _pages[_selected],
		);
	}
}


