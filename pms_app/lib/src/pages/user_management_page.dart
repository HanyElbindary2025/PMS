import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pms_app/config/app_config.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'CREATOR';
  List<Map<String, dynamic>> _users = [];
  bool _loading = false;
  bool _creating = false;

  final List<Map<String, String>> _roles = [
    {'value': 'ADMIN', 'label': 'System Administrator'},
    {'value': 'SERVICE_MANAGER', 'label': 'Service Manager'},
    {'value': 'SERVICE_DESK', 'label': 'Service Desk Agent'},
    {'value': 'TECHNICAL_ANALYST', 'label': 'Technical Analyst'},
    {'value': 'DEVELOPER', 'label': 'Senior Developer'},
    {'value': 'QA_ENGINEER', 'label': 'QA Engineer'},
    {'value': 'SOLUTION_ARCHITECT', 'label': 'Solution Architect'},
    {'value': 'DEVOPS_ENGINEER', 'label': 'DevOps Engineer'},
    {'value': 'CREATOR', 'label': 'Request Creator'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/users'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw API response: $data'); // Debug log
        setState(() {
          // Backend returns users directly as array, not wrapped in 'data' property
          _users = List<Map<String, dynamic>>.from(data ?? []);
        });
        print('Users loaded: ${_users.length}'); // Debug log
      } else {
        _showError('Failed to load users: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading users: $e'); // Debug log
      _showError('Failed to load users: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createUser() async {
    if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _creating = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'role': _selectedRole,
        }),
      );

      if (response.statusCode == 201) {
        _emailController.clear();
        _nameController.clear();
        _loadUsers();
        _showSuccess('User created successfully');
      } else {
        final error = json.decode(response.body);
        _showError('Failed to create user: ${error['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showError('Failed to create user: $e');
    } finally {
      setState(() => _creating = false);
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(Uri.parse('${AppConfig.baseUrl}/users/$userId'));
        if (response.statusCode == 200) {
          _loadUsers();
          _showSuccess('User deleted successfully');
        } else {
          _showError('Failed to delete user');
        }
      } catch (e) {
        _showError('Failed to delete user: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getRoleLabel(String role) {
    final roleData = _roles.firstWhere(
      (r) => r['value'] == role,
      orElse: () => {'value': role, 'label': role},
    );
    return roleData['label']!;
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red;
      case 'SERVICE_MANAGER':
        return Colors.purple;
      case 'SERVICE_DESK':
        return Colors.blue;
      case 'TECHNICAL_ANALYST':
        return Colors.orange;
      case 'DEVELOPER':
        return Colors.green;
      case 'QA_ENGINEER':
        return Colors.teal;
      case 'SOLUTION_ARCHITECT':
        return Colors.indigo;
      case 'DEVOPS_ENGINEER':
        return Colors.cyan;
      case 'CREATOR':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('User Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Create User Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create User', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Role',
                            border: OutlineInputBorder(),
                          ),
                          items: _roles.map((role) => DropdownMenuItem(
                            value: role['value'],
                            child: Text(role['label']!),
                          )).toList(),
                          onChanged: (value) {
                            setState(() => _selectedRole = value!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: _creating ? null : _createUser,
                        child: _creating 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Users List
          const Text('Users', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.separated(
                    itemCount: _users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final role = user['role'] ?? 'UNKNOWN';
                      final roleColor = _getRoleColor(role);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor,
                          child: Text(
                            (user['name'] ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['email'] ?? ''),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: roleColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: roleColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                _getRoleLabel(role),
                                style: TextStyle(
                                  color: roleColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteUser(user['id']),
                          tooltip: 'Delete user',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


