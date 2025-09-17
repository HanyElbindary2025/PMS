import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
	const DashboardPage({super.key});

	@override
	State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
	int total = 0;
	int created = 0;
	int analysis = 0;
	int testing = 0;
	bool loading = true;

	Future<void> _load() async {
		setState(() => loading = true);
		Future<int> count([String? status]) async {
			final uri = Uri.parse('http://localhost:3000/tickets').replace(queryParameters: {
				'page': '1', 'pageSize': '1', if (status != null) 'status': status,
			});
			final res = await http.get(uri);
			final body = json.decode(res.body);
			return (body['pagination']?['total'] ?? 0) as int;
		}
		total = await count();
		created = await count('CREATED');
		analysis = await count('ANALYSIS');
		testing = await count('TESTING');
		setState(() => loading = false);
	}

	@override
	void initState() {
		super.initState();
		_load();
	}

	Widget _card(String title, int value, Color color) {
		return Expanded(
			child: Card(
				color: color.withOpacity(.08),
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
							const SizedBox(height: 8),
							Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
						],
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		if (loading) return const Center(child: CircularProgressIndicator());
		return Padding(
			padding: const EdgeInsets.all(16),
			child: Column(
				children: [
					Row(children: [
						_card('Total', total, Colors.indigo),
						const SizedBox(width: 12),
						_card('Created', created, Colors.blue),
						const SizedBox(width: 12),
						_card('Analysis', analysis, Colors.orange),
						const SizedBox(width: 12),
						_card('Testing', testing, Colors.green),
					]),
				],
			),
		);
	}
}


