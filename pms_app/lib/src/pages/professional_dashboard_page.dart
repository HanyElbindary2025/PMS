import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pms_app/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfessionalDashboardPage extends StatefulWidget {
  const ProfessionalDashboardPage({super.key});

  @override
  State<ProfessionalDashboardPage> createState() => _ProfessionalDashboardPageState();
}

class _ProfessionalDashboardPageState extends State<ProfessionalDashboardPage> {
  bool _loading = true;
  String _userRole = 'CREATOR';
  
  // KPI Metrics
  int _totalTickets = 0;
  int _openTickets = 0;
  int _closedTickets = 0;
  int _overdueTickets = 0;
  double _avgResolutionTime = 0.0;
  double _customerSatisfaction = 0.0;
  int _slaBreaches = 0;
  
  // Phase-wise counts
  Map<String, int> _phaseCounts = {};
  
  // Priority distribution
  Map<String, int> _priorityCounts = {};
  
  // Category distribution
  Map<String, int> _categoryCounts = {};
  
  // Recent tickets
  List<Map<String, dynamic>> _recentTickets = [];
  
  // SLA Performance
  Map<String, double> _slaPerformance = {};

  final Map<String, Map<String, dynamic>> _workflowPhases = {
    'SUBMITTED': {'name': 'Submitted', 'color': Color(0xFF9E9E9E), 'icon': '📝', 'sla': 2},
    'CATEGORIZED': {'name': 'Categorized', 'color': Color(0xFFFF9800), 'icon': '🏷️', 'sla': 4},
    'PRIORITIZED': {'name': 'Prioritized', 'color': Color(0xFFFF5722), 'icon': '⚡', 'sla': 8},
    'ANALYSIS': {'name': 'Analysis', 'color': Color(0xFFFFC107), 'icon': '🔍', 'sla': 24},
    'DESIGN': {'name': 'Design', 'color': Color(0xFF2196F3), 'icon': '🎨', 'sla': 48},
    'APPROVAL': {'name': 'Approval', 'color': Color(0xFF9C27B0), 'icon': '✅', 'sla': 24},
    'DEVELOPMENT': {'name': 'Development', 'color': Color(0xFF4CAF50), 'icon': '💻', 'sla': 168},
    'TESTING': {'name': 'Testing', 'color': Color(0xFFFF9800), 'icon': '🧪', 'sla': 24},
    'UAT': {'name': 'UAT', 'color': Color(0xFF795548), 'icon': '👥', 'sla': 48},
    'DEPLOYMENT': {'name': 'Deployment', 'color': Color(0xFF607D8B), 'icon': '🚀', 'sla': 4},
    'VERIFICATION': {'name': 'Verification', 'color': Color(0xFF3F51B5), 'icon': '🔍', 'sla': 8},
    'CLOSED': {'name': 'Closed', 'color': Color(0xFF4CAF50), 'icon': '✅', 'sla': 24},
    'ON_HOLD': {'name': 'On Hold', 'color': Color(0xFFFFC107), 'icon': '⏸️', 'sla': 0},
    'REJECTED': {'name': 'Rejected', 'color': Color(0xFFF44336), 'icon': '❌', 'sla': 24},
    'CANCELLED': {'name': 'Cancelled', 'color': Color(0xFF9E9E9E), 'icon': '🚫', 'sla': 4},
  };

  final Map<String, Map<String, dynamic>> _priorities = {
    'CRITICAL': {'name': 'Critical', 'color': Color(0xFFF44336), 'hours': 2},
    'HIGH': {'name': 'High', 'color': Color(0xFFFF9800), 'hours': 8},
    'MEDIUM': {'name': 'Medium', 'color': Color(0xFFFFC107), 'hours': 24},
    'LOW': {'name': 'Low', 'color': Color(0xFF4CAF50), 'hours': 72},
  };

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadDashboardData();
  }

  Future<void> _loadUserRole() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _userRole = sp.getString('userRole') ?? 'CREATOR';
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    
    try {
      await Future.wait([
        _loadKPIMetrics(),
        _loadPhaseCounts(),
        _loadPriorityCounts(),
        _loadCategoryCounts(),
        _loadRecentTickets(),
        _loadSLAPerformance(),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadKPIMetrics() async {
    // Load total tickets
    final totalRes = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=1'));
    if (totalRes.statusCode == 200) {
      final totalBody = json.decode(totalRes.body);
      _totalTickets = totalBody['pagination']?['total'] ?? 0;
    }

    // Load closed tickets
    final closedRes = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=1&status=CLOSED'));
    if (closedRes.statusCode == 200) {
      final closedBody = json.decode(closedRes.body);
      _closedTickets = closedBody['pagination']?['total'] ?? 0;
    }

    // Calculate open tickets
    _openTickets = _totalTickets - _closedTickets;

    // Mock data for demonstration (in real app, these would come from analytics)
    _overdueTickets = (_totalTickets * 0.05).round();
    _avgResolutionTime = 18.5; // hours
    _customerSatisfaction = 4.2; // out of 5
    _slaBreaches = (_totalTickets * 0.02).round();
  }

  Future<void> _loadPhaseCounts() async {
    _phaseCounts.clear();
    
    for (final phase in _workflowPhases.keys) {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=1&status=$phase'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        _phaseCounts[phase] = body['pagination']?['total'] ?? 0;
      }
    }
  }

  Future<void> _loadPriorityCounts() async {
    _priorityCounts.clear();
    
    for (final priority in _priorities.keys) {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=1&priority=$priority'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        _priorityCounts[priority] = body['pagination']?['total'] ?? 0;
      }
    }
  }

  Future<void> _loadCategoryCounts() async {
    _categoryCounts.clear();
    
    final categories = ['INCIDENT', 'REQUEST', 'CHANGE', 'PROBLEM'];
    for (final category in categories) {
      final res = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=1&category=$category'));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        _categoryCounts[category] = body['pagination']?['total'] ?? 0;
      }
    }
  }

  Future<void> _loadRecentTickets() async {
    final res = await http.get(Uri.parse('${AppConfig.baseUrl}/tickets?page=1&pageSize=5'));
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      _recentTickets = List<Map<String, dynamic>>.from(body['data'] ?? []);
    }
  }

  Future<void> _loadSLAPerformance() async {
    // Mock SLA performance data (in real app, this would be calculated from actual data)
    _slaPerformance = {
      'CRITICAL': 95.5,
      'HIGH': 92.3,
      'MEDIUM': 88.7,
      'LOW': 85.2,
    };
  }

  Widget _buildKPICard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseCard(String phase, int count) {
    final phaseInfo = _workflowPhases[phase] ?? {'name': phase, 'color': Colors.grey, 'icon': '📋'};
    final slaHours = phaseInfo['sla'] as int;
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  phaseInfo['icon'],
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phaseInfo['name'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: phaseInfo['color'],
              ),
            ),
            if (slaHours > 0)
              Text(
                '${slaHours}h SLA',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Priority Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._priorities.entries.map((entry) {
              final priority = entry.key;
              final info = entry.value;
              final count = _priorityCounts[priority] ?? 0;
              final percentage = _totalTickets > 0 ? (count / _totalTickets * 100) : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: info['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(info['name']),
                    ),
                    Text('$count'),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
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

  Widget _buildSLAChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SLA Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._slaPerformance.entries.map((entry) {
              final priority = entry.key;
              final performance = entry.value;
              final info = _priorities[priority] ?? {'name': priority, 'color': Colors.grey};
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: info['color'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(info['name']),
                    ),
                    Text(
                      '${performance.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: performance >= 90 ? Colors.green : 
                               performance >= 80 ? Colors.orange : Colors.red,
                        fontWeight: FontWeight.bold,
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

  Widget _buildRecentTickets() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Tickets',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_recentTickets.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No recent tickets'),
                ),
              )
            else
              ..._recentTickets.map((ticket) {
                final status = ticket['status'] ?? '';
                final phaseInfo = _workflowPhases[status] ?? {'name': status, 'color': Colors.grey, 'icon': '📋'};
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(phaseInfo['icon']),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${ticket['requesterEmail']} • ${DateFormat('MMM dd').format(DateTime.parse(ticket['createdAt']).toLocal())}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (phaseInfo['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          phaseInfo['name'],
                          style: TextStyle(
                            fontSize: 10,
                            color: phaseInfo['color'],
                            fontWeight: FontWeight.w500,
                          ),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Professional ITSM Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Dashboard',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Cards
          const Text(
            'Key Performance Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildKPICard(
                'Total Tickets',
                '$_totalTickets',
                'All time',
                Colors.blue,
                Icons.assignment,
              ),
              _buildKPICard(
                'Open Tickets',
                '$_openTickets',
                'In progress',
                Colors.orange,
                Icons.pending_actions,
              ),
              _buildKPICard(
                'Closed Tickets',
                '$_closedTickets',
                'Completed',
                Colors.green,
                Icons.check_circle,
              ),
              _buildKPICard(
                'Overdue Tickets',
                '$_overdueTickets',
                'SLA breached',
                Colors.red,
                Icons.warning,
              ),
              _buildKPICard(
                'Avg Resolution',
                '${_avgResolutionTime}h',
                'Time to close',
                Colors.purple,
                Icons.timer,
              ),
              _buildKPICard(
                'Satisfaction',
                '${_customerSatisfaction}/5',
                'Customer rating',
                Colors.teal,
                Icons.star,
              ),
              _buildKPICard(
                'SLA Breaches',
                '$_slaBreaches',
                'This month',
                Colors.red,
                Icons.error,
              ),
              _buildKPICard(
                'SLA Performance',
                '${((_totalTickets - _slaBreaches) / _totalTickets * 100).toStringAsFixed(1)}%',
                'Overall',
                Colors.green,
                Icons.trending_up,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Workflow Phases
          const Text(
            'Workflow Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
            children: _workflowPhases.entries.map((entry) {
              return _buildPhaseCard(entry.key, _phaseCounts[entry.key] ?? 0);
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Charts and Analytics
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPriorityChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSLAChart(),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent Tickets
          _buildRecentTickets(),
        ],
      ),
    );
  }
}
