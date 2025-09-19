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
	// Basic Information Controllers
	final _title = TextEditingController();
	final _email = TextEditingController();
	final _name = TextEditingController();
	final _requester = TextEditingController();
	
	// Request Details Controllers
	final _description = TextEditingController();
	final _painPoint = TextEditingController();
	final _businessValue = TextEditingController();
	final _issueDescription = TextEditingController();
	
	// Assignment & Dates Controllers
	final _flSe = TextEditingController();
	final _gscSe = TextEditingController();
	final _startDate = TextEditingController();
	final _dueDate = TextEditingController();
	final _gscRrNumber = TextEditingController();
	final _sla = TextEditingController();
	
	// Additional Information Controllers
	final _notes = TextEditingController();
	final _risks = TextEditingController();
	final _flHandler = TextEditingController();
	final _gscHandler = TextEditingController();
	final _taskName = TextEditingController();
	final _percentComplete = TextEditingController();

	bool _submitting = false;
	String? _error;

	// Lookups
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
				_projects = list.where((r) => r['type'] == 'PROJECT').map((e) => (e['value'] as String)).toList();
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
				'requester': _requester.text.trim().isNotEmpty ? _requester.text.trim() : null,
				'painPoint': _painPoint.text.trim().isNotEmpty ? _painPoint.text.trim() : null,
				'businessValue': _businessValue.text.trim().isNotEmpty ? _businessValue.text.trim() : null,
				'issueDescription': _issueDescription.text.trim().isNotEmpty ? _issueDescription.text.trim() : null,
				'flSe': _flSe.text.trim().isNotEmpty ? _flSe.text.trim() : null,
				'gscSe': _gscSe.text.trim().isNotEmpty ? _gscSe.text.trim() : null,
				'startDate': _startDate.text.trim().isNotEmpty ? _startDate.text.trim() : null,
				'dueDate': _dueDate.text.trim().isNotEmpty ? _dueDate.text.trim() : null,
				'gscRrNumber': _gscRrNumber.text.trim().isNotEmpty ? _gscRrNumber.text.trim() : null,
				'notes': _notes.text.trim().isNotEmpty ? _notes.text.trim() : null,
				'risks': _risks.text.trim().isNotEmpty ? _risks.text.trim() : null,
				'flHandler': _flHandler.text.trim().isNotEmpty ? _flHandler.text.trim() : null,
				'gscHandler': _gscHandler.text.trim().isNotEmpty ? _gscHandler.text.trim() : null,
				'taskName': _taskName.text.trim().isNotEmpty ? _taskName.text.trim() : null,
				'percentComplete': _percentComplete.text.trim().isNotEmpty ? int.tryParse(_percentComplete.text.trim()) : null,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request created successfully!')));
      _clearAllFields();
      Navigator.of(context).maybePop();
    } else {
			setState(() { _error = 'Failed (${res.statusCode})'; });
		}
	}

	void _clearAllFields() {
		_title.clear();
		_email.clear();
		_name.clear();
		_requester.clear();
		_description.clear();
		_painPoint.clear();
		_businessValue.clear();
		_issueDescription.clear();
		_flSe.clear();
		_gscSe.clear();
		_startDate.clear();
		_dueDate.clear();
		_gscRrNumber.clear();
		_sla.clear();
		_notes.clear();
		_risks.clear();
		_flHandler.clear();
		_gscHandler.clear();
		_taskName.clear();
		_percentComplete.clear();
		setState(() {
			_project = null;
			_platform = null;
			_category = null;
			_priority = null;
		});
	}

	@override
	void initState() {
		super.initState();
		_loadLookups();
		_prefillUser();
	}

	Widget _dropdown(String label, List<String> items, String? value, void Function(String?) onChanged, {bool required = false}) {
		return DropdownButtonFormField<String>(
			decoration: InputDecoration(
				labelText: required ? '$label *' : label,
				border: const OutlineInputBorder(),
			),
			value: value,
			items: [DropdownMenuItem<String>(value: null, child: Text('Select $label'))]
				..addAll(items.map((e) => DropdownMenuItem(value: e, child: Text(e)))),
			onChanged: _submitting ? null : onChanged,
		);
	}

	Widget _textField(TextEditingController controller, String label, {bool required = false, int maxLines = 1, TextInputType? keyboardType}) {
		return TextField(
			controller: controller,
			decoration: InputDecoration(
				labelText: required ? '$label *' : label,
				border: const OutlineInputBorder(),
			),
			maxLines: maxLines,
			keyboardType: keyboardType,
			enabled: !_submitting,
		);
	}

	Widget _section(String title, List<Widget> children) {
		return Card(
			margin: const EdgeInsets.only(bottom: 16),
			child: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue)),
						const SizedBox(height: 16),
						...children,
					],
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('PDS Request Form'),
				backgroundColor: Colors.blue.shade50,
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Center(
					child: ConstrainedBox(
						constraints: const BoxConstraints(maxWidth: 1000),
						child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
							// Basic Information Section
							_section('Basic Information', [
								Row(children: [
									Expanded(child: _textField(_title, 'Title', required: true)),
									const SizedBox(width: 12),
									Expanded(child: _dropdown('Project', _projects, _project, (v) => setState(() => _project = v), required: true)),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _dropdown('Platform', _platforms, _platform, (v) => setState(() => _platform = v), required: true)),
									const SizedBox(width: 12),
									Expanded(child: _dropdown('Category', _categories, _category, (v) => setState(() => _category = v), required: true)),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _dropdown('Priority', _priorities, _priority, (v) => setState(() => _priority = v), required: true)),
									const SizedBox(width: 12),
									Expanded(child: _textField(_email, 'Requester Email', required: true, keyboardType: TextInputType.emailAddress)),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _textField(_name, 'Requester Name')),
									const SizedBox(width: 12),
									Expanded(child: _textField(_requester, 'Manager/Head Requester')),
								]),
							]),

							// Request Details Section
							_section('Request Details', [
								_textField(_description, 'Description', required: true, maxLines: 4),
								const SizedBox(height: 12),
								// Dynamic fields based on category
								if (_category == 'Requirement' || _category == 'Change') ...[
									_textField(_painPoint, 'Pain Point', maxLines: 3),
									const SizedBox(height: 12),
									_textField(_businessValue, 'Business Value', maxLines: 3),
									const SizedBox(height: 12),
								],
								if (_category == 'Issue') ...[
									_textField(_issueDescription, 'Issue Description', maxLines: 3),
									const SizedBox(height: 12),
								],
							]),

							// Assignment & Dates Section
							_section('Assignment & Dates', [
								Row(children: [
									Expanded(child: _textField(_flSe, 'FL SE')),
									const SizedBox(width: 12),
									Expanded(child: _textField(_gscSe, 'GSC SE')),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _textField(_startDate, 'Start Date', keyboardType: TextInputType.datetime)),
									const SizedBox(width: 12),
									Expanded(child: _textField(_dueDate, 'Due Date', keyboardType: TextInputType.datetime)),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _textField(_gscRrNumber, 'GSC RR Number')),
									const SizedBox(width: 12),
									Expanded(child: _textField(_sla, 'Target SLA Hours', keyboardType: TextInputType.number)),
								]),
							]),

							// Additional Information Section
							_section('Additional Information', [
								Row(children: [
									Expanded(child: _textField(_notes, 'Notes', maxLines: 3)),
									const SizedBox(width: 12),
									Expanded(child: _textField(_risks, 'Risks')),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _textField(_flHandler, 'FL Handler')),
									const SizedBox(width: 12),
									Expanded(child: _textField(_gscHandler, 'GSC Handler')),
								]),
								const SizedBox(height: 12),
								Row(children: [
									Expanded(child: _textField(_taskName, 'Task Name')),
									const SizedBox(width: 12),
									Expanded(child: _textField(_percentComplete, '% Complete', keyboardType: TextInputType.number)),
								]),
							]),

							// Error and Submit
							if (_error != null) ...[
								Container(
									padding: const EdgeInsets.all(12),
									decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
									child: Text(_error!, style: const TextStyle(color: Colors.red)),
								),
								const SizedBox(height: 12),
							],
							FilledButton(
								onPressed: _submitting ? null : _submit,
								style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
								child: _submitting 
									? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
									: const Text('Submit Request', style: TextStyle(fontSize: 16)),
							),
						]),
					),
				),
			),
		);
	}
}


