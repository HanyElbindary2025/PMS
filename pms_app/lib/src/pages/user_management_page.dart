import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
	const UserManagementPage({super.key});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text('User Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
					const SizedBox(height: 12),
					Card(
						child: Padding(
							padding: const EdgeInsets.all(16),
							child: Column(
								children: [
									const Align(alignment: Alignment.centerLeft, child: Text('Create User', style: TextStyle(fontWeight: FontWeight.w600))),
									const SizedBox(height: 12),
									const TextField(decoration: InputDecoration(labelText: 'Email')),
									const SizedBox(height: 12),
									const TextField(decoration: InputDecoration(labelText: 'Name')),
									const SizedBox(height: 12),
									DropdownButtonFormField<String>(
										decoration: const InputDecoration(labelText: 'Role'),
										items: const [
											DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
											DropdownMenuItem(value: 'EDITOR', child: Text('Editor')),
											DropdownMenuItem(value: 'CREATOR', child: Text('Creator')),
											DropdownMenuItem(value: 'READER', child: Text('Read Only')),
										],
										onChanged: (_) {},
									),
									const SizedBox(height: 12),
									FilledButton(onPressed: () {}, child: const Text('Create')),
								],
							),
						),
					),
					const SizedBox(height: 16),
					const Text('Users (stubbed list for now)'),
					const SizedBox(height: 8),
					Expanded(
						child: ListView.separated(
							itemBuilder: (_, i) => ListTile(
								title: Text('user$i@example.com'),
								subtitle: const Text('Role: ADMIN'),
								trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
							),
							separatorBuilder: (_, __) => const Divider(height: 1),
							itemCount: 5,
						),
					),
				],
			),
		);
	}
}


