import 'dart:convert';
import 'dart:async';
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
	String _search = '';
	bool _loading = false;
	List<dynamic> _rows = [];
	int _totalPages = 1;
	int? _sortColumnIndex;
	bool _sortAscending = false; // newest first by default
	final Set<String> _selectedIds = <String>{};
	Timer? _debounce;

	Color _statusColor(String s) {
		switch (s) {
			case 'CREATED':
				return Colors.blue.shade600;
			case 'ANALYSIS':
				return Colors.orange.shade700;
			case 'CONFIRM_DUE':
				return Colors.teal.shade700;
			case 'TESTING':
				return Colors.purple.shade700;
			case 'READY_DELIVERY':
				return Colors.indigo.shade700;
			case 'DELIVERED':
				return Colors.green.shade700;
			default:
				return Colors.grey.shade700;
		}
	}

	Future<void> _openDetails(String id) async {
		showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
		try {
			final res = await http.get(Uri.parse('http://localhost:3000/tickets/$id'));
			Navigator.of(context).pop();
			if (res.statusCode != 200) {
				ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load ticket')));
				return;
			}
			final t = json.decode(res.body) as Map<String, dynamic>;
			showDialog(
				context: context,
				builder: (_) {
					final stages = List<Map<String, dynamic>>.from(t['stages'] ?? const []);
					return AlertDialog(
						title: Text(t['title'] ?? 'Ticket Details'),
						content: SizedBox(
							width: 560,
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('Status: ${t['status']}', style: const TextStyle(fontWeight: FontWeight.w600)),
									const SizedBox(height: 8),
									Text('Requester: ${t['requesterEmail'] ?? ''}${t['requesterName'] != null ? ' (${t['requesterName']})' : ''}'),
									const SizedBox(height: 8),
									Text('Created: ${DateTime.parse(t['createdAt']).toLocal().toString().split('.').first}'),
									const Divider(height: 20),
									Text('Description', style: Theme.of(context).textTheme.titleSmall),
									const SizedBox(height: 4),
									Container(
										padding: const EdgeInsets.all(12),
										decoration: BoxDecoration(color: const Color(0xFFF7F7F9), borderRadius: BorderRadius.circular(8)),
										child: Text(t['description'] ?? ''),
									),
									const SizedBox(height: 12),
									Text('Stages', style: Theme.of(context).textTheme.titleSmall),
									const SizedBox(height: 6),
									SizedBox(
										height: 160,
										child: ListView.separated(
											itemBuilder: (_, i) {
												final s = stages[i];
												return Row(
													children: [
														Chip(label: Text(s['key'] ?? s['name'] ?? '')), const SizedBox(width: 8),
														Expanded(child: Text('From ${s['startedAt'] ?? ''}${s['completedAt'] != null ? ' to ${s['completedAt']}' : ''}')),
													],
												);
											},
											separatorBuilder: (_, __) => const Divider(height: 12),
											itemCount: stages.length,
										),
									),
								],
							),
						),
						actions: [
							TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
						],
					);
				},
			);
		} catch (_) {
			Navigator.of(context).pop();
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading ticket')));
		}
	}

	Future<void> _load() async {
		setState(() => _loading = true);
		final uri = Uri.parse('http://localhost:3000/tickets').replace(queryParameters: {
			'page': '$_page', 'pageSize': '$_pageSize', if (_status != null && _status!.isNotEmpty) 'status': _status!,
		});
		final res = await http.get(uri);
		final body = json.decode(res.body);
		List<dynamic> all = List<dynamic>.from(body['data'] ?? []);
		// client-side sorting (server sort can be added later)
		all.sort((a, b) {
			final ma = a as Map<String, dynamic>;
			final mb = b as Map<String, dynamic>;
			int cmp;
			if (_sortColumnIndex == 0) {
				cmp = (ma['title'] ?? '').toString().toLowerCase().compareTo((mb['title'] ?? '').toString().toLowerCase());
			} else if (_sortColumnIndex == 1) {
				cmp = (ma['status'] ?? '').toString().compareTo((mb['status'] ?? '').toString());
			} else {
				cmp = DateTime.parse(ma['createdAt']).compareTo(DateTime.parse(mb['createdAt']));
			}
			return _sortAscending ? cmp : -cmp;
		});
		setState(() {
			_rows = _search.isEmpty
				? all
				: all.where((t) {
					final m = t as Map<String, dynamic>;
					final hay = '${m['title'] ?? ''} ${m['requesterEmail'] ?? ''} ${m['status'] ?? ''}'.toLowerCase();
					return hay.contains(_search.toLowerCase());
				}).toList();
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
			Expanded(
				child: TextField(
					decoration: const InputDecoration(
						prefixIcon: Icon(Icons.search),
						hintText: 'Search title, email, status',
						filled: true,
						fillColor: Color(0xFFF4F6F8),
						border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide.none),
					),
					onChanged: (v) {
						setState(() => _search = v);
						_debounce?.cancel();
						_debounce = Timer(const Duration(milliseconds: 350), _load);
					},
				),
			),
			const SizedBox(width: 12),
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
			const SizedBox(width: 12),
			DropdownButton<int>(
				value: _pageSize,
				items: const [10, 20, 50].map((e) => DropdownMenuItem(value: e, child: Text('Page $e'))).toList(),
				onChanged: (v) { if (v!=null) { setState(() { _pageSize = v; _page = 1; }); _load(); } },
			),
			const Spacer(),
			IconButton(onPressed: _page > 1 ? () { setState(() => _page--); _load(); } : null, icon: const Icon(Icons.chevron_left)),
			Container(
				padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
				decoration: BoxDecoration(color: const Color(0xFFF4F6F8), borderRadius: BorderRadius.circular(8)),
				child: Text('$_page / $_totalPages'),
			),
			IconButton(onPressed: _page < _totalPages ? () { setState(() => _page++); _load(); } : null, icon: const Icon(Icons.chevron_right)),
		]);
	}

	@override
	Widget build(BuildContext context) {
		final table = DataTable(
			sortColumnIndex: _sortColumnIndex,
			sortAscending: _sortAscending,
			columnSpacing: 28,
			columns: [
				DataColumn(
					label: const Text('Title'),
					onSort: (i, asc) { setState(() { _sortColumnIndex = i; _sortAscending = asc; }); _load(); },
				),
				const DataColumn(label: Text('Status')),
				const DataColumn(label: Text('Requester')),
				DataColumn(
					label: const Text('Created At'),
					onSort: (i, asc) { setState(() { _sortColumnIndex = i; _sortAscending = asc; }); _load(); },
				),
				const DataColumn(label: Text('Actions')),
			],
			rows: _rows.asMap().entries.map<DataRow>((entry) {
				final idx = entry.key;
				final t = entry.value as Map<String, dynamic>;
				final id = (t['id'] ?? '') as String;
				return DataRow(
					color: MaterialStatePropertyAll(idx % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA)),
					selected: _selectedIds.contains(id),
					onSelectChanged: (v) {
						setState(() {
							if (v == true) { _selectedIds.add(id); } else { _selectedIds.remove(id); }
						});
					},
					cells: [
						DataCell(Text(t['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis)),
						DataCell(Chip(label: Text(t['status'] ?? ''), backgroundColor: _statusColor((t['status'] ?? '') as String).withOpacity(.12), labelStyle: TextStyle(color: _statusColor((t['status'] ?? '') as String)))),
						DataCell(Text(t['requesterEmail'] ?? '')),
						DataCell(Text(DateTime.parse(t['createdAt']).toLocal().toString().split('.').first)),
						DataCell(
							InkWell(
								onTap: () { _openDetails(id); },
								child: const Padding(
									padding: EdgeInsets.all(6),
									child: Icon(Icons.open_in_new, size: 20),
								),
							),
						),
					],
				);
			}).toList(),
		);

		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(children: [
				_filters(),
				const SizedBox(height: 12),
				Expanded(
					child: _loading
						? const Center(child: CircularProgressIndicator())
						: SingleChildScrollView(
							scrollDirection: Axis.horizontal,
							child: ConstrainedBox(
								constraints: const BoxConstraints(minWidth: 1200),
								child: Card(
									elevation: 0.5,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(10),
										side: BorderSide(color: Colors.grey.shade200),
									),
									child: table,
								),
							),
					),
				),
			]),
		);
	}
}


