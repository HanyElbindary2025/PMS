import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketsPage extends StatefulWidget {
	const TicketsPage({super.key});

	@override
	State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
	int _page = 1;
	int _pageSize = 10;
	String? _status;
	bool _loading = false;
	List<dynamic> _rows = [];
	int _totalPages = 1;

	Future<void> _load() async {
		setState(() => _loading = true);
		final uri = Uri.parse('http://localhost:3000/tickets').replace(queryParameters: {
			'page': '$_page', 'pageSize': '$_pageSize', if (_status != null && _status!.isNotEmpty) 'status': _status!,
		});
		final res = await http.get(uri);
		final body = json.decode(res.body);
		setState(() {
			_rows = List<dynamic>.from(body['data'] ?? []);
			_totalPages = (body['pagination']?['totalPages'] ?? 1) as int;
			_loading = false;
		});
	}

	@override
	void initState() {
		super.initState();
		_load();
	}

	Widget _filters() {
		return Row(children: [
			DropdownButton<String?>(
				value: _status,
				hint: const Text('Status'),
				items: const [
					DropdownMenuItem(value: null, child: Text('All')),
					DropdownMenuItem(value: 'CREATED', child: Text('CREATED')),
					DropdownMenuItem(value: 'ANALYSIS', child: Text('ANALYSIS')),
					DropdownMenuItem(value: 'CONFIRM_DUE', child: Text('CONFIRM_DUE')),
					DropdownMenuItem(value: 'TESTING', child: Text('TESTING')),
					DropdownMenuItem(value: 'READY_DELIVERY', child: Text('READY_DELIVERY')),
					DropdownMenuItem(value: 'DELIVERED', child: Text('DELIVERED')),
				],
				onChanged: (v) { setState(() { _status = v; _page = 1; }); _load(); },
			),
			const Spacer(),
			IconButton(onPressed: _page > 1 ? () { setState(() => _page--); _load(); } : null, icon: const Icon(Icons.chevron_left)),
			Text('$_page / $_totalPages'),
			IconButton(onPressed: _page < _totalPages ? () { setState(() => _page++); _load(); } : null, icon: const Icon(Icons.chevron_right)),
		]);
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(
				children: [
					_filters(),
					const SizedBox(height: 12),
					Expanded(
						child: _loading ? const Center(child: CircularProgressIndicator()) : ListView.separated(
							itemBuilder: (c, i) {
								final t = _rows[i] as Map<String, dynamic>;
								return ListTile(
									title: Text(t['title'] ?? ''),
									subtitle: Text('${t['status']} • ${t['requesterEmail'] ?? ''}'),
									trailing: Text(DateTime.parse(t['createdAt']).toLocal().toString().split('.').first),
								);
							},
							separatorBuilder: (_, __) => const Divider(height: 1),
							itemCount: _rows.length,
						),
					),
				],
			),
		);
	}
}


