import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SLAConfigurationPage extends StatefulWidget {
  const SLAConfigurationPage({super.key});

  @override
  State<SLAConfigurationPage> createState() => _SLAConfigurationPageState();
}

class _SLAConfigurationPageState extends State<SLAConfigurationPage> {
  bool _loading = true;
  bool _saving = false;
  
  // SLA Configuration
  final Map<String, int> _slaHours = {
    'SUBMITTED': 2,
    'ANALYSIS': 24,
    'CONFIRM_DUE': 0, // Set by user
    'DESIGN': 48,
    'DEVELOPMENT': 168, // 1 week
    'TESTING': 24,
    'CUSTOMER_APPROVAL': 48,
    'DEPLOYMENT': 24,
    'VERIFICATION': 8,
    'CLOSED': 24,
  };

  // Priority-based SLA
  final Map<String, int> _prioritySLA = {
    'CRITICAL': 2,
    'HIGH': 8,
    'MEDIUM': 24,
    'LOW': 72,
  };

  // Phase colors
  final Map<String, Color> _phaseColors = {
    'SUBMITTED': Colors.grey,
    'ANALYSIS': Colors.amber,
    'CONFIRM_DUE': Colors.blue,
    'DESIGN': Colors.blue,
    'DEVELOPMENT': Colors.green,
    'TESTING': Colors.orange,
    'CUSTOMER_APPROVAL': Colors.brown,
    'DEPLOYMENT': Colors.blueGrey,
    'VERIFICATION': Colors.indigo,
    'CLOSED': Colors.green,
  };

  @override
  void initState() {
    super.initState();
    _loadSLAConfiguration();
  }

  Future<void> _loadSLAConfiguration() async {
    setState(() => _loading = true);
    
    try {
      // In a real app, you would load this from the backend
      // For now, we'll use the default values
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      _showErrorSnackBar('Failed to load SLA configuration: $e');
    }
  }

  Future<void> _saveSLAConfiguration() async {
    setState(() => _saving = true);
    
    try {
      // In a real app, you would save this to the backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate saving
      
      _showSuccessSnackBar('SLA configuration saved successfully!');
      setState(() => _saving = false);
    } catch (e) {
      setState(() => _saving = false);
      _showErrorSnackBar('Failed to save SLA configuration: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSLAHoursCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Phase SLA Hours',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Set SLA hours for each workflow phase:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._slaHours.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _phaseColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getPhaseDisplayName(entry.key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: entry.value.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onChanged: (value) {
                          final hours = int.tryParse(value);
                          if (hours != null && hours >= 0) {
                            setState(() {
                              _slaHours[entry.key] = hours;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySLACard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.priority_high, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Priority-Based SLA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Set SLA hours based on ticket priority:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._prioritySLA.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getPriorityColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: entry.value.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hours',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onChanged: (value) {
                          final hours = int.tryParse(value);
                          if (hours != null && hours >= 0) {
                            setState(() {
                              _prioritySLA[entry.key] = hours;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSLAOverviewCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'SLA Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Current SLA Configuration Summary:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Workflow SLA:'),
                      Text(
                        '${_slaHours.values.where((h) => h > 0).fold(0, (a, b) => a + b)} hours',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Critical Priority SLA:'),
                      Text(
                        '${_prioritySLA['CRITICAL']} hours',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Low Priority SLA:'),
                      Text(
                        '${_prioritySLA['LOW']} hours',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseDisplayName(String phase) {
    switch (phase) {
      case 'SUBMITTED': return 'Submitted';
      case 'ANALYSIS': return 'Analysis';
      case 'CONFIRM_DUE': return 'Confirm Due Date';
      case 'DESIGN': return 'Design';
      case 'DEVELOPMENT': return 'Development';
      case 'TESTING': return 'Testing';
      case 'CUSTOMER_APPROVAL': return 'Customer Approval';
      case 'DEPLOYMENT': return 'Deployment';
      case 'VERIFICATION': return 'Verification';
      case 'CLOSED': return 'Closed';
      default: return phase;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.orange;
      case 'MEDIUM': return Colors.yellow;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SLA Configuration'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saving ? null : _saveSLAConfiguration,
            icon: _saving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
            tooltip: 'Save Configuration',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.blue.shade600, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SLA Configuration',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure Service Level Agreement settings for your workflow phases and priorities.',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // SLA Overview
            _buildSLAOverviewCard(),
            
            const SizedBox(height: 16),
            
            // Phase SLA Hours
            _buildSLAHoursCard(),
            
            const SizedBox(height: 16),
            
            // Priority SLA
            _buildPrioritySLACard(),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _saveSLAConfiguration,
                icon: _saving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save SLA Configuration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
