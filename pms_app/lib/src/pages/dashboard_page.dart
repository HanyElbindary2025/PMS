import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pms_app/config/app_config.dart';

class DashboardPage extends StatefulWidget {
	const DashboardPage({super.key});

	@override
	State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
	int total = 0;
	int pending = 0;
	int analysis = 0;
	int rat = 0;
	int confirmDue = 0;
	int development = 0;
	int testing = 0;
	int sysImpl = 0;
	int delivered = 0;
	bool loading = true;

	Future<void> _load() async {
		setState(() => loading = true);
		Future<int> count([String? status]) async {
        final uri = Uri.parse('${AppConfig.baseUrl}/tickets').replace(queryParameters: {
				'page': '1', 'pageSize': '1', if (status != null) 'status': status,
			});
			final res = await http.get(uri);
			final body = json.decode(res.body);
			return (body['pagination']?['total'] ?? 0) as int;
		}
		total = await count();
		pending = await count('PENDING_REVIEW');
		analysis = await count('ANALYSIS');
		rat = await count('RAT_MEETING');
		confirmDue = await count('CONFIRM_DUE');
		development = await count('DEVELOPMENT');
		testing = await count('TESTING');
		sysImpl = await count('SYSTEM_IMPLEMENTATION');
		delivered = await count('DELIVERED');
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
					Wrap(spacing: 12, runSpacing: 12, children: [
						_card('Total', total, Colors.indigo),
						_card('Pending Review', pending, Colors.blueGrey),
						_card('Analysis', analysis, Colors.orange),
						_card('RAT Meeting', rat, Colors.teal),
						_card('Confirm Due', confirmDue, Colors.cyan),
						_card('Development', development, Colors.deepPurple),
						_card('Testing', testing, Colors.green),
						_card('System Impl.', sysImpl, Colors.brown),
						_card('Delivered', delivered, Colors.green.shade800),
					]),
				],
			),
		);
	}
}


