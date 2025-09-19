import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateRequestPage extends StatefulWidget {
	const CreateRequestPage({super.key});

	@override
	State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
	final _title = TextEditingController();
	final _description = TextEditingController();
	final _email = TextEditingController();
	final _name = TextEditingController();
	final _sla = TextEditingController();

	bool _submitting = false;
	String? _error;

	// lookups
	List<String> _projects = [];
	List<String> _platforms = [];
	List<String> _categories = [];
	List<String> _priorities = [];
	String? _project;
	String? _platform;
	String? _category;
	String? _priority;

	Future<void> _loadLookups() async {
		final uri = Uri.parse('http://localhost:3000/lookups').replace(queryParameters: {
			'type': ['PROJECT','PLATFORM','CATEGORY','PRIORITY'],
		});
		final res = await http.get(uri);
		if (res.statusCode == 200) {
			final list = List<Map<String, dynamic>>.from(json.decode(res.body));
			setState(() {
				_projects = list.where((r) => r['type'] == 'CATEGORY' ? false : r['type'] == 'PROJECT').map((e) => (e['value'] as String)).toList();
				_platforms = list.where((r) => r['type'] == 'PLATFORM').map((e) => (e['value'] as String)).toList();
				_categories = list.where((r) => r['type'] == 'CATEGORY').map((e) => (e['value'] as String)).toList();
				_priorities = list.where((r) => r['type'] == 'PRIORITY').map((e) => (e['value'] as String)).toList();
			});
		}
	}

	Future<void> _prefillUser() async {
		final sp = await SharedPreferences.getInstance();
		final savedEmail = sp.getString('userEmail');
		if (savedEmail != null) _email.text = savedEmail;
	}

	Future<void> _submit() async {
		setState(() { _submitting = true; _error = null; });
		if (_title.text.trim().length < 3 || _description.text.trim().length < 5 || _email.text.trim().isEmpty) {
			setState(() { _submitting = false; _error = 'Please complete required fields'; });
			return;
		}
		final payload = <String, dynamic>{
			'title': _title.text.trim(),
			'description': _description.text.trim(),
			'requesterEmail': _email.text.trim(),
			if (_name.text.trim().isNotEmpty) 'requesterName': _name.text.trim(),
			if (_sla.text.trim().isNotEmpty) 'targetSlaHours': int.tryParse(_sla.text.trim()),
			'details': {
				'project': _project,
				'platform': _platform,
				'category': _category,
				'priority': _priority,
			},
		};
		final res = await http.post(
			Uri.parse('http://localhost:3000/public/requests'),
			headers: { 'Content-Type': 'application/json' },
			body: json.encode(payload),
		);
		if (!mounted) return;
		setState(() { _submitting = false; });
    if (res.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request created')));
      _title.clear(); _description.clear(); _sla.clear();
      Navigator.of(context).maybePop();
    } else {
			setState(() { _error = 'Failed (${res.statusCode})'; });
		}
	}

	@override
	void initState() {
		super.initState();
		_loadLookups();
		_prefillUser();
	}

	Widget _dropdown(String label, List<String> items, String? value, void Function(String?) onChanged) {
		return DropdownButtonFormField<String>(
			decoration: InputDecoration(labelText: label),
			value: value,
			items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
			onChanged: _submitting ? null : onChanged,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Create Request')),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Center(
					child: ConstrainedBox(
						constraints: const BoxConstraints(maxWidth: 720),
						child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
							TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title *')),
							const SizedBox(height: 12),
							TextField(controller: _description, maxLines: 4, decoration: const InputDecoration(labelText: 'Description *')),
							const SizedBox(height: 12),
							Row(children: [
								Expanded(child: TextField(controller: _email, decoration: const InputDecoration(labelText: 'Requester Email *'))),
								const SizedBox(width: 12),
								Expanded(child: TextField(controller: _name, decoration: const InputDecoration(labelText: 'Requester Name'))),
							]),
							const SizedBox(height: 12),
							Row(children: [
								Expanded(child: _dropdown('Project', _projects, _project, (v) => setState(() => _project = v))),
								const SizedBox(width: 12),
								Expanded(child: _dropdown('Platform', _platforms, _platform, (v) => setState(() => _platform = v))),
							]),
							const SizedBox(height: 12),
							Row(children: [
								Expanded(child: _dropdown('Category', _categories, _category, (v) => setState(() => _category = v))),
								const SizedBox(width: 12),
								Expanded(child: _dropdown('Priority', _priorities, _priority, (v) => setState(() => _priority = v))),
							]),
							const SizedBox(height: 12),
							TextField(controller: _sla, decoration: const InputDecoration(labelText: 'Target SLA Hours'), keyboardType: TextInputType.number),
							const SizedBox(height: 12),
							if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
							const SizedBox(height: 8),
							FilledButton(
								onPressed: _submitting ? null : _submit,
								child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Request'),
							),
						]),
					),
				),
			),
		);
	}
}


