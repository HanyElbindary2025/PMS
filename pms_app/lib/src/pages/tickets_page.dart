import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pms_app/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _transitioning = false;
  String _role = 'CREATOR';
  String _userEmail = '';

	Future<void> _transition(String id, String to) async {
		Map<String, dynamic> body = { 'to': to };
		String? decision;
		String? comment;
		if (to == 'ANALYSIS' || to == 'REJECTED') {
			final ctl = TextEditingController();
			final ok = await showDialog<bool>(context: context, builder: (_) {
				return AlertDialog(
					title: Text(to == 'ANALYSIS' ? 'Approve & Move to Analysis' : 'Reject Request'),
					content: TextField(controller: ctl, maxLines: 3, decoration: const InputDecoration(labelText: 'Comment (optional)')),
					actions: [
						TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
						FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Continue')),
					],
				);
			});
			if (ok != true) return;
			decision = to == 'ANALYSIS' ? 'APPROVE' : 'REJECT';
			comment = ctl.text.trim().isEmpty ? null : ctl.text.trim();
		}
		if (to == 'CONFIRM_DUE') {
			final dueCtl = TextEditingController();
			final slaCtl = TextEditingController();
			final ok = await showDialog<bool>(context: context, builder: (_) {
				return AlertDialog(
					title: const Text('Confirm Due'),
					content: SizedBox(
						width: 420,
						child: Column(mainAxisSize: MainAxisSize.min, children: [
							TextField(controller: dueCtl, decoration: const InputDecoration(labelText: 'Due ISO (e.g. 2025-09-22T10:00:00Z)')),
							const SizedBox(height: 8),
							TextField(controller: slaCtl, decoration: const InputDecoration(labelText: 'SLA Hours'), keyboardType: TextInputType.number),
						]),
					),
					actions: [
						TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
						FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
					],
				);
			});
			if (ok != true) return;
			if (dueCtl.text.trim().isNotEmpty) body['dueAt'] = dueCtl.text.trim();
			if (slaCtl.text.trim().isNotEmpty) body['slaHours'] = int.tryParse(slaCtl.text.trim());
		}
		if (decision != null) body['decision'] = decision;
		if (comment != null) body['comment'] = comment;
		setState(() { _transitioning = true; });
    final res = await http.post(
      Uri.parse('${AppConfig.baseUrl}/tickets/$id/transition'),
			headers: { 'Content-Type': 'application/json' },
			body: json.encode(body),
		);
		if (!mounted) return;
		if (res.statusCode == 200) {
			Navigator.of(context).pop();
			await _load();
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
		} else {
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${res.statusCode}')));
		}
		if (mounted) setState(() { _transitioning = false; });
	}

  List<String> _nextStates(String status) {
		switch (status) {
      case 'PENDING_REVIEW': return ['ANALYSIS','REJECTED'];
			case 'ANALYSIS': return ['RAT_MEETING','CONFIRM_DUE'];
			case 'RAT_MEETING': return ['CONFIRM_DUE'];
			case 'CONFIRM_DUE': return ['DEVELOPMENT'];
			case 'DEVELOPMENT': return ['TESTING'];
			case 'TESTING': return ['SYSTEM_IMPLEMENTATION'];
			case 'SYSTEM_IMPLEMENTATION': return ['DELIVERED'];
      case 'REJECTED': return [];
			default: return [];
		}
	}

  Color _statusColor(String s) {
		switch (s) {
      case 'PENDING_REVIEW':
        return Colors.blueGrey.shade700;
			case 'ANALYSIS':
				return Colors.orange.shade700;
      case 'RAT_MEETING':
        return Colors.teal.shade700;
			case 'CONFIRM_DUE':
        return Colors.cyan.shade700;
      case 'DEVELOPMENT':
        return Colors.indigo.shade700;
			case 'TESTING':
				return Colors.purple.shade700;
      case 'SYSTEM_IMPLEMENTATION':
        return Colors.brown.shade700;
			case 'DELIVERED':
				return Colors.green.shade700;
			default:
				return Colors.grey.shade700;
		}
	}

  Future<void> _openDetails(String id) async {
		showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
		try {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets/$id'));
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
										height: 200,
										child: ListView.builder(
											itemCount: stages.length,
											itemBuilder: (_, i) {
												final s = stages[i];
												final bool isLast = i == stages.length - 1;
												final Color dot = _statusColor((s['key'] ?? s['name'] ?? '') as String);
												return Padding(
													padding: const EdgeInsets.symmetric(vertical: 6),
													child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
														SizedBox(
															width: 20,
															child: Column(children: [
																Container(width: 10, height: 10, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
																if (!isLast) Container(width: 2, height: 28, color: Colors.grey.shade300),
														])),
													const SizedBox(width: 8),
													Expanded(
														child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
															Text((s['key'] ?? s['name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.w600)),
															Text('From ${s['startedAt'] ?? ''}${s['completedAt'] != null ? ' to ${s['completedAt']}' : ''}', style: const TextStyle(color: Colors.black54)),
														]),
													),
												]),
												);
											},
										),
									),
                                  const SizedBox(height: 12),
                                  if (_role == 'ADMIN' && _nextStates((t['status'] ?? '') as String).isNotEmpty) ...[
										Text('Next actions', style: Theme.of(context).textTheme.titleSmall),
										const SizedBox(height: 6),
									Wrap(spacing: 8, runSpacing: 8, children: _nextStates((t['status'] ?? '') as String).map((ns) {
										return FilledButton.tonal(
											onPressed: _transitioning ? null : () { _transition((t['id'] as String), ns); },
											child: _transitioning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(ns.replaceAll('_', ' ')),
										);
										}).toList()),
									],
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
    final uri = Uri.parse('${AppConfig.baseUrl}/tickets').replace(queryParameters: {
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
    final mineOnly = (_role == 'CREATOR' && _userEmail.isNotEmpty)
      ? all.where((e) => (e as Map<String, dynamic>)['requesterEmail'] == _userEmail).toList()
      : all;

    setState(() {
      _rows = _search.isEmpty
        ? mineOnly
        : mineOnly.where((t) {
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
    SharedPreferences.getInstance().then((sp) {
      _role = sp.getString('userRole') ?? 'CREATOR';
      _userEmail = sp.getString('userEmail') ?? '';
      setState(() {});
      _load();
    });
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


