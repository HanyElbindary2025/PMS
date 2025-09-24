import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pms_app/config/app_config.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final List<String> _lookupTypes = ['PROJECT', 'PLATFORM', 'CATEGORY', 'PRIORITY'];
  String _selectedType = 'PROJECT';
  final List<Map<String, dynamic>> _lookups = [];
  bool _loading = false;
  
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/lookups'));
      if (res.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(json.decode(res.body));
        setState(() {
          _lookups.clear();
          _lookups.addAll(data);
        });
      }
    } catch (e) {
      _showError('Failed to load lookups: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addLookup() async {
    if (_valueController.text.trim().isEmpty) {
      _showError('Value is required');
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/lookups'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': _selectedType,
          'value': _valueController.text.trim(),
          'order': int.tryParse(_orderController.text.trim()) ?? 0,
        }),
      );

      if (res.statusCode == 201) {
        _valueController.clear();
        _orderController.clear();
        _loadLookups();
        _showSuccess('Lookup added successfully');
      } else {
        _showError('Failed to add lookup: ${res.statusCode}');
      }
    } catch (e) {
      _showError('Failed to add lookup: $e');
    }
  }

  Future<void> _deleteLookup(String id) async {
    try {
      final res = await http.delete(Uri.parse('${AppConfig.baseUrl}/lookups/$id'));
      if (res.statusCode == 204) {
        _loadLookups();
        _showSuccess('Lookup deleted successfully');
      } else {
        _showError('Failed to delete lookup: ${res.statusCode}');
      }
    } catch (e) {
      _showError('Failed to delete lookup: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  List<Map<String, dynamic>> get _filteredLookups {
    return _lookups.where((l) => l['type'] == _selectedType).toList()
      ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings - Dropdown Management'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Add new lookup
                  Expanded(
                    flex: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Add New Dropdown Option',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            
                            // Type dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                              ),
                              items: _lookupTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedType = value!);
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Value field
                            TextField(
                              controller: _valueController,
                              decoration: const InputDecoration(
                                labelText: 'Value',
                                border: OutlineInputBorder(),
                                hintText: 'Enter the dropdown option text',
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Order field
                            TextField(
                              controller: _orderController,
                              decoration: const InputDecoration(
                                labelText: 'Order (optional)',
                                border: OutlineInputBorder(),
                                hintText: 'Display order (0 = first)',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Add button
                            FilledButton(
                              onPressed: _addLookup,
                              child: const Text('Add Option'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right side - List existing lookups
                  Expanded(
                    flex: 2,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Manage $_selectedType Options',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _loadLookups,
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Refresh',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Lookups list
                            Expanded(
                              child: _filteredLookups.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No options found for this type.\nAdd some using the form on the left.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _filteredLookups.length,
                                      itemBuilder: (context, index) {
                                        final lookup = _filteredLookups[index];
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue.shade100,
                                              child: Text('${lookup['order'] ?? 0}'),
                                            ),
                                            title: Text(lookup['value']),
                                            subtitle: Text('Order: ${lookup['order'] ?? 0}'),
                                            trailing: IconButton(
                                              onPressed: () => _deleteLookup(lookup['id']),
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              tooltip: 'Delete',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
