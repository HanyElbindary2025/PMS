import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/team_assignment_widget.dart';

class ProfessionalTicketsPage extends StatefulWidget {
  const ProfessionalTicketsPage({super.key});

  @override
  State<ProfessionalTicketsPage> createState() => _ProfessionalTicketsPageState();
}

class _ProfessionalTicketsPageState extends State<ProfessionalTicketsPage> {
  int _page = 1;
  int _pageSize = 10;
  String? _status;
  String? _priority;
  String? _category;
  String _search = '';
  bool _loading = false;
  List<dynamic> _rows = [];
  int _totalPages = 1;
  int? _sortColumnIndex;
  bool _sortAscending = false;
  final Set<String> _selectedIds = <String>{};
  Timer? _debounce;
  bool _transitioning = false;
  String _role = 'CREATOR';
  String _userEmail = '';

  // Professional workflow phases
  final Map<String, Map<String, dynamic>> _workflowPhases = {
    'SUBMITTED': {'name': 'Submitted', 'color': Color(0xFF9E9E9E), 'icon': '📝'},
    'CATEGORIZED': {'name': 'Categorized', 'color': Color(0xFFFF9800), 'icon': '🏷️'},
    'PRIORITIZED': {'name': 'Prioritized', 'color': Color(0xFFFF5722), 'icon': '⚡'},
    'ANALYSIS': {'name': 'Analysis', 'color': Color(0xFFFFC107), 'icon': '🔍'},
    'DESIGN': {'name': 'Design', 'color': Color(0xFF2196F3), 'icon': '🎨'},
    'APPROVAL': {'name': 'Approval', 'color': Color(0xFF9C27B0), 'icon': '✅'},
    'DEVELOPMENT': {'name': 'Development', 'color': Color(0xFF4CAF50), 'icon': '💻'},
    'TESTING': {'name': 'Testing', 'color': Color(0xFFFF9800), 'icon': '🧪'},
    'UAT': {'name': 'UAT', 'color': Color(0xFF795548), 'icon': '👥'},
    'DEPLOYMENT': {'name': 'Deployment', 'color': Color(0xFF607D8B), 'icon': '🚀'},
    'VERIFICATION': {'name': 'Verification', 'color': Color(0xFF3F51B5), 'icon': '🔍'},
    'CLOSED': {'name': 'Closed', 'color': Color(0xFF4CAF50), 'icon': '✅'},
    'ON_HOLD': {'name': 'On Hold', 'color': Color(0xFFFFC107), 'icon': '⏸️'},
    'REJECTED': {'name': 'Rejected', 'color': Color(0xFFF44336), 'icon': '❌'},
    'CANCELLED': {'name': 'Cancelled', 'color': Color(0xFF9E9E9E), 'icon': '🚫'},
  };

  final Map<String, Map<String, dynamic>> _priorities = {
    'CRITICAL': {'name': 'Critical', 'color': Color(0xFFF44336), 'hours': 2},
    'HIGH': {'name': 'High', 'color': Color(0xFFFF9800), 'hours': 8},
    'MEDIUM': {'name': 'Medium', 'color': Color(0xFFFFC107), 'hours': 24},
    'LOW': {'name': 'Low', 'color': Color(0xFF4CAF50), 'hours': 72},
  };

  final Map<String, String> _categories = {
    'INCIDENT': 'Incident',
    'REQUEST': 'Request',
    'CHANGE': 'Change',
    'PROBLEM': 'Problem',
  };

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndEmail();
    _load();
  }

  Future<void> _loadUserRoleAndEmail() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _role = sp.getString('userRole') ?? 'CREATOR';
      _userEmail = sp.getString('userEmail') ?? '';
    });
  }

  Future<void> _transition(String id, String to) async {
    Map<String, dynamic> body = {'to': to};
    String? decision;
    String? comment;

    // Show appropriate dialog based on action
    if (to == 'ANALYSIS') {
      // Special handling for ANALYSIS - show priority confirmation
      final result = await _showPriorityConfirmationDialog();
      if (result == null) return;
      comment = result['comment'];
      // Update ticket with priority and category
      body['priority'] = result['priority'];
      body['category'] = result['category'];
    } else if (to == 'REJECTED' || to == 'CANCELLED') {
      final result = await _showRejectionDialog(to);
      if (result == null) return;
      decision = 'REJECT';
      comment = result['comment'];
    } else if (to == 'ON_HOLD') {
      final result = await _showHoldDialog();
      if (result == null) return;
      comment = result['reason'];
      body['holdReason'] = result['reason'];
      if (result['expectedDate'] != null) {
        body['expectedResolutionDate'] = result['expectedDate'].toUtc().toIso8601String();
      }
    } else if (to == 'APPROVAL') {
      final result = await _showApprovalDialog(to);
      if (result == null) return;
      decision = result['decision'];
      comment = result['comment'];
    } else if (to == 'DEPLOYMENT' || to == 'VERIFICATION') {
      final dueDate = await _showDatePicker('Set deployment date');
      if (dueDate == null) return;
      body['dueAt'] = dueDate.toUtc().toIso8601String();
    } else {
      // For other transitions, ask for optional comment
      final result = await _showCommentDialog(to);
      if (result == null) return;
      comment = result['comment'];
    }

    if (decision != null) body['decision'] = decision;
    if (comment != null && comment.isNotEmpty) body['comment'] = comment;
    body['userRole'] = _role; // Add user role for permission checking

    setState(() => _transitioning = true);

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/tickets/$id/transition'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        Navigator.of(context).pop();
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Ticket moved to ${to.replaceAll('_', ' ')}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed: ${errorData['error'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _transitioning = false);
    }
  }

  // Dialog for priority confirmation when accepting requirements
  Future<Map<String, dynamic>?> _showPriorityConfirmationDialog() async {
    String selectedPriority = 'MEDIUM';
    String selectedCategory = 'REQUEST';
    final commentController = TextEditingController();
    
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Accept & Confirm Priority'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please confirm the priority and category for this request:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            
            // Priority Selection
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'LOW', child: Text('Low')),
                DropdownMenuItem(value: 'MEDIUM', child: Text('Medium')),
                DropdownMenuItem(value: 'HIGH', child: Text('High')),
                DropdownMenuItem(value: 'CRITICAL', child: Text('Critical')),
              ],
              onChanged: (value) => selectedPriority = value!,
            ),
            
            const SizedBox(height: 16),
            
            // Category Selection
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'INCIDENT', child: Text('Incident')),
                DropdownMenuItem(value: 'REQUEST', child: Text('Request')),
                DropdownMenuItem(value: 'CHANGE', child: Text('Change')),
                DropdownMenuItem(value: 'PROBLEM', child: Text('Problem')),
              ],
              onChanged: (value) => selectedCategory = value!,
            ),
            
            const SizedBox(height: 16),
            
            // Comment
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Acceptance Comment (Optional)',
                hintText: 'Add any notes about the acceptance...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop({
                'priority': selectedPriority,
                'category': selectedCategory,
                'comment': commentController.text.trim(),
              });
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Accept & Start Analysis'),
          ),
        ],
      ),
    );
  }

  // Dialog for rejection/cancellation
  Future<Map<String, String>?> _showRejectionDialog(String action) async {
    final commentController = TextEditingController();
    
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(action == 'REJECTED' ? 'Reject Request' : 'Cancel Request'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action == 'REJECTED' 
                ? 'Please provide a reason for rejecting this request:'
                : 'Please provide a reason for cancelling this request:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                hintText: 'Explain why this request is being rejected/cancelled...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.of(context).pop({
                  'comment': commentController.text.trim(),
                });
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(action == 'REJECTED' ? 'Reject' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  // Dialog for comments on transitions
  Future<Map<String, String>?> _showCommentDialog(String action) async {
    final commentController = TextEditingController();
    
    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.comment, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Add Comment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moving to: ${action.replaceAll('_', ' ')}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add an optional comment for this transition:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Add notes about this transition...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop({
              'comment': commentController.text.trim(),
            }),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Enhanced date picker
  Future<DateTime?> _showDatePicker(String title) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: title,
    );
  }

  Future<Map<String, String>?> _showApprovalDialog(String action) async {
    final commentController = TextEditingController();
    String? decision;

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'ANALYSIS' ? 'Approve & Move to Analysis' : 
                    action == 'REJECTED' ? 'Reject Request' : 'Approve Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Decision'),
              items: [
                DropdownMenuItem(value: 'APPROVE', child: Text('Approve')),
                DropdownMenuItem(value: 'REJECT', child: Text('Reject')),
              ],
              onChanged: (value) => decision = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Comment',
                hintText: 'Add your comments here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (decision != null) {
                Navigator.of(context).pop({
                  'decision': decision!,
                  'comment': commentController.text.trim(),
                });
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _showDateTimePicker() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate == null) return null;

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<Map<String, dynamic>?> _showHoldDialog() async {
    final reasonController = TextEditingController();
    DateTime? expectedDate;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.pause_circle, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('Put Request On Hold'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide a reason for putting this request on hold:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Hold Reason (required)',
                  hintText: 'Why is this request being put on hold?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Expected Resolution Date (optional):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text('Expected Resolution Date'),
                subtitle: Text(expectedDate != null 
                  ? DateFormat('yyyy-MM-dd').format(expectedDate!)
                  : 'Select date (optional)'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => expectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop({
                    'reason': reasonController.text.trim(),
                    'expectedDate': expectedDate,
                  });
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Put On Hold'),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getNextStates(String status) {
    // Allow actions based on role
    if (_role != 'ADMIN' && _role != 'SERVICE_MANAGER' && _role != 'SERVICE_DESK') return [];
    
    // Professional workflow transitions with clear actions
    switch (status) {
      case 'SUBMITTED': 
        return ['ANALYSIS', 'REJECTED']; // Skip CATEGORIZED and PRIORITIZED
      case 'CATEGORIZED': 
        return ['PRIORITIZED']; // Automatic transition
      case 'PRIORITIZED': 
        return ['ANALYSIS']; // Automatic transition
      case 'ANALYSIS': 
        return ['DESIGN', 'ON_HOLD', 'REJECTED'];
      case 'DESIGN': 
        return ['APPROVAL', 'ON_HOLD', 'REJECTED'];
      case 'APPROVAL': 
        return ['DEVELOPMENT', 'ON_HOLD', 'REJECTED'];
      case 'DEVELOPMENT': 
        return ['TESTING', 'ON_HOLD', 'CANCELLED'];
      case 'TESTING': 
        return ['UAT', 'DEVELOPMENT', 'ON_HOLD'];
      case 'UAT': 
        return ['DEPLOYMENT', 'TESTING', 'ON_HOLD'];
      case 'DEPLOYMENT': 
        return ['VERIFICATION', 'ON_HOLD'];
      case 'VERIFICATION': 
        return ['CLOSED', 'DEPLOYMENT', 'ON_HOLD'];
      case 'ON_HOLD': 
        return ['ANALYSIS', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'CANCELLED'];
      default: 
        return [];
    }
  }

  // Get action buttons with proper labels and icons based on role and status
  List<Map<String, dynamic>> _getActionButtons(String status) {
    // Role-based access control
    final rolePermissions = {
      'ADMIN': ['SUBMITTED', 'ANALYSIS', 'DESIGN', 'APPROVAL', 'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'VERIFICATION', 'CLOSED', 'ON_HOLD', 'REJECTED', 'CANCELLED'],
      'SERVICE_MANAGER': ['ANALYSIS', 'DESIGN', 'APPROVAL', 'DEVELOPMENT', 'TESTING', 'UAT', 'DEPLOYMENT', 'VERIFICATION', 'ON_HOLD'],
      'TECHNICAL_ANALYST': ['ANALYSIS', 'DESIGN', 'ON_HOLD'],
      'SOLUTION_ARCHITECT': ['DESIGN', 'APPROVAL', 'ON_HOLD'],
      'DEVELOPER': ['DEVELOPMENT', 'TESTING', 'ON_HOLD'],
      'QA_ENGINEER': ['TESTING', 'UAT', 'ON_HOLD'],
      'DEVOPS_ENGINEER': ['DEPLOYMENT', 'VERIFICATION', 'ON_HOLD'],
      'CREATOR': ['SUBMITTED', 'UAT', 'VERIFICATION'], // Requester can only approve UAT and final verification
    };
    
    final userPermissions = rolePermissions[_role] ?? [];
    if (!userPermissions.contains(status)) return [];
    
    switch (status) {
      case 'SUBMITTED':
        return [
          {'action': 'ANALYSIS', 'label': 'Accept & Start Analysis', 'icon': Icons.check_circle, 'color': Colors.green},
          {'action': 'REJECTED', 'label': 'Reject Request', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'ANALYSIS':
        return [
          {'action': 'CONFIRM_DUE', 'label': 'Confirm Due Date', 'icon': Icons.schedule, 'color': Colors.blue},
          {'action': 'MEETING_REQUESTED', 'label': 'Request Meeting', 'icon': Icons.meeting_room, 'color': Colors.orange},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.amber},
          {'action': 'REJECTED', 'label': 'Reject', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'CONFIRM_DUE':
        return [
          {'action': 'DESIGN', 'label': 'Move to Design', 'icon': Icons.design_services, 'color': Colors.purple},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.amber},
          {'action': 'REJECTED', 'label': 'Reject', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'MEETING_REQUESTED':
        return [
          {'action': 'CONFIRM_DUE', 'label': 'Confirm After Meeting', 'icon': Icons.check_circle, 'color': Colors.green},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.amber},
          {'action': 'REJECTED', 'label': 'Reject', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'DESIGN':
        return [
          {'action': 'APPROVAL', 'label': 'Send for Approval', 'icon': Icons.approval, 'color': Colors.indigo},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
          {'action': 'REJECTED', 'label': 'Reject', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'APPROVAL':
        return [
          {'action': 'DEVELOPMENT', 'label': 'Approve & Start Development', 'icon': Icons.code, 'color': Colors.green},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
          {'action': 'REJECTED', 'label': 'Reject', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'DEVELOPMENT':
        return [
          {'action': 'TESTING', 'label': 'Move to Testing', 'icon': Icons.bug_report, 'color': Colors.teal},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
          {'action': 'CANCELLED', 'label': 'Cancel', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      case 'TESTING':
        return [
          {'action': 'UAT', 'label': 'Move to UAT', 'icon': Icons.verified_user, 'color': Colors.cyan},
          {'action': 'DEVELOPMENT', 'label': 'Back to Development', 'icon': Icons.arrow_back, 'color': Colors.blue},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
        ];
      case 'UAT':
        return [
          {'action': 'DEPLOYMENT', 'label': 'Deploy', 'icon': Icons.rocket_launch, 'color': Colors.deepOrange},
          {'action': 'TESTING', 'label': 'Back to Testing', 'icon': Icons.arrow_back, 'color': Colors.teal},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
        ];
      case 'DEPLOYMENT':
        return [
          {'action': 'VERIFICATION', 'label': 'Verify Deployment', 'icon': Icons.verified, 'color': Colors.green},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
        ];
      case 'VERIFICATION':
        return [
          {'action': 'CLOSED', 'label': 'Close Ticket', 'icon': Icons.check_circle_outline, 'color': Colors.green},
          {'action': 'DEPLOYMENT', 'label': 'Back to Deployment', 'icon': Icons.arrow_back, 'color': Colors.deepOrange},
          {'action': 'ON_HOLD', 'label': 'Put on Hold', 'icon': Icons.pause_circle, 'color': Colors.orange},
        ];
      case 'ON_HOLD':
        return [
          {'action': 'ANALYSIS', 'label': 'Resume Analysis', 'icon': Icons.play_arrow, 'color': Colors.blue},
          {'action': 'DESIGN', 'label': 'Resume Design', 'icon': Icons.play_arrow, 'color': Colors.purple},
          {'action': 'DEVELOPMENT', 'label': 'Resume Development', 'icon': Icons.play_arrow, 'color': Colors.green},
          {'action': 'TESTING', 'label': 'Resume Testing', 'icon': Icons.play_arrow, 'color': Colors.teal},
          {'action': 'UAT', 'label': 'Resume UAT', 'icon': Icons.play_arrow, 'color': Colors.cyan},
          {'action': 'DEPLOYMENT', 'label': 'Resume Deployment', 'icon': Icons.play_arrow, 'color': Colors.deepOrange},
          {'action': 'CANCELLED', 'label': 'Cancel', 'icon': Icons.cancel, 'color': Colors.red},
        ];
      default:
        return [];
    }
  }

  Future<void> _openDetails(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final res = await http.get(Uri.parse('http://localhost:3000/tickets/$id'));
      Navigator.of(context).pop();

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ticket')),
        );
        return;
      }

      final ticket = json.decode(res.body) as Map<String, dynamic>;
      _showTicketDetails(ticket);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ticket: $e')),
      );
    }
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    final stages = List<Map<String, dynamic>>.from(ticket['stages'] ?? []);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket['title'] ?? 'Ticket Details',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ticket #${ticket['ticketNumber'] ?? 'N/A'}',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.blue.shade600),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Ticket Info Cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Status',
                      ticket['status'],
                      Icons.flag,
                      _getStatusColor(ticket['status']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Priority',
                      ticket['priority'] ?? 'Not Set',
                      Icons.priority_high,
                      _getPriorityColor(ticket['priority']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Category',
                      ticket['category'] ?? 'Not Set',
                      Icons.category,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Created',
                      DateFormat('MMM dd, yyyy').format(DateTime.parse(ticket['createdAt']).toLocal()),
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Project Title',
                      ticket['projectTitle'] ?? 'Not Set',
                      Icons.work,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Service',
                      ticket['service'] ?? 'Not Set',
                      Icons.build,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Business Value',
                      ticket['businessValue'] ?? 'Not Set',
                      Icons.trending_up,
                      Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'SLA Hours',
                      ticket['totalSlaHours']?.toString() ?? 'Not Set',
                      Icons.timer,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Requester Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.person, color: Colors.blue.shade600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requester',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            ticket['requesterEmail'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (ticket['requesterName'] != null)
                            Text(
                              ticket['requesterName'],
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Assignment Information
              if (ticket['assignedTo'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Assigned To', ticket['assignedTo']['name'], Colors.blue),
                _buildInfoRow('Assignee Role', ticket['assignedTo']['role']?.replaceAll('_', ' '), null),
                _buildInfoRow('Assignee Email', ticket['assignedTo']['email'], null),
              ],
              
              if (ticket['teamMembers'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Team Members', '${json.decode(ticket['teamMembers'] as String).length} members', Colors.green),
              ],
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Description
              Text('Description', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(ticket['description'] ?? ''),
              ),
              
              const SizedBox(height: 16),
              
              // Enhanced Workflow Timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timeline, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Workflow Timeline',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200, // Fixed height for timeline
                      child: ListView.builder(
                        itemCount: stages.length,
                        itemBuilder: (context, index) {
                          final stage = stages[index];
                          final isLast = index == stages.length - 1;
                          final isCompleted = stage['completedAt'] != null;
                          final phaseInfo = _workflowPhases[stage['key']] ?? {'name': stage['name'], 'color': Colors.grey, 'icon': '📋'};
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline indicator
                                Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? phaseInfo['color'] : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isCompleted ? phaseInfo['color'] : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        boxShadow: isCompleted ? [
                                          BoxShadow(
                                            color: (phaseInfo['color'] as Color).withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                      child: Center(
                                        child: isCompleted 
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 20,
                                            )
                                          : Text(
                                              phaseInfo['icon'],
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        margin: const EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Timeline content
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCompleted ? phaseInfo['color'].withOpacity(0.3) : Colors.grey.shade200,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Phase name and status
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                phaseInfo['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isCompleted ? phaseInfo['color'] : Colors.grey.shade700,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isCompleted ? Colors.green.shade100 : Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isCompleted ? 'Completed' : 'In Progress',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isCompleted ? Colors.green.shade700 : Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        
                                        // Timeline details
                                        _buildTimelineDetail(
                                          Icons.schedule,
                                          'Started',
                                          DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.parse(stage['startedAt']).toLocal()),
                                        ),
                                        
                                        if (stage['completedAt'] != null)
                                          _buildTimelineDetail(
                                            Icons.check_circle,
                                            'Completed',
                                            DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.parse(stage['completedAt']).toLocal()),
                                          ),
                                        
                                        if (stage['decision'] != null)
                                          _buildTimelineDetail(
                                            Icons.gavel,
                                            'Decision',
                                            stage['decision'],
                                          ),
                                        
                                        if (stage['comment'] != null && stage['comment'].toString().isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.blue.shade200),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(Icons.comment, size: 16, color: Colors.blue.shade600),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    stage['comment'],
                                                    style: TextStyle(
                                                      color: Colors.blue.shade800,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              if (_getActionButtons((ticket['status'] ?? '') as String).isNotEmpty || _canAssignTeam()) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.settings, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('Available Actions', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Team Assignment Button
                    if (_canAssignTeam())
                      FilledButton.icon(
                        onPressed: _transitioning ? null : () => _showTeamAssignmentDialog(ticket),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          foregroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: Icon(Icons.group_add, size: 18),
                        label: Text('Assign Team'),
                      ),
                    // Workflow Action Buttons
                    ..._getActionButtons((ticket['status'] ?? '') as String).map((action) {
                      return FilledButton.icon(
                        onPressed: _transitioning ? null : () => _transition((ticket['id'] as String), action['action']),
                        style: FilledButton.styleFrom(
                          backgroundColor: (action['color'] as Color).withOpacity(0.1),
                          foregroundColor: action['color'] as Color,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: _transitioning 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(action['icon'] as IconData, size: 18),
                        label: Text(action['label'] as String),
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: $_role • Status: ${ticket['status']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Check if current user can assign teams
  bool _canAssignTeam() {
    return _role == 'ADMIN' || _role == 'SERVICE_MANAGER' || _role == 'SERVICE_DESK';
  }

  // Show team assignment dialog
  void _showTeamAssignmentDialog(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => TeamAssignmentWidget(
        ticketId: ticket['id'] as String,
        currentAssigneeId: ticket['assignedToId'] as String?,
        currentTeamMembers: ticket['teamMembers'] != null 
          ? List<String>.from(json.decode(ticket['teamMembers'] as String))
          : null,
        onAssignmentChanged: () {
          _load(); // Reload tickets to show updated assignment
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          if (color != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value ?? '',
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            )
          else
            Text(value ?? ''),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    return _workflowPhases[status]?['color'] ?? Colors.grey;
  }

  Color _getPriorityColor(String? priority) {
    return _priorities[priority]?['color'] ?? Colors.grey;
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    
    final Map<String, String> queryParams = {
      'page': '$_page',
      'pageSize': '$_pageSize',
    };
    
    if (_status != null && _status!.isNotEmpty) {
      queryParams['status'] = _status!;
    }
    
    if (_priority != null && _priority!.isNotEmpty) {
      queryParams['priority'] = _priority!;
    }
    
    if (_category != null && _category!.isNotEmpty) {
      queryParams['category'] = _category!;
    }
    
    if (_role == 'CREATOR' && _userEmail.isNotEmpty) {
      queryParams['requesterEmail'] = _userEmail;
    }

    final uri = Uri.parse('http://localhost:3000/tickets').replace(queryParameters: queryParams);
    final res = await http.get(uri);
    final body = json.decode(res.body);
    
    List<dynamic> all = List<dynamic>.from(body['data'] ?? []);
    
    // Client-side sorting
    all.sort((a, b) {
      final ma = a as Map<String, dynamic>;
      final mb = b as Map<String, dynamic>;
      int cmp;
      
      if (_sortColumnIndex == 0) {
        cmp = (ma['title'] ?? '').toString().toLowerCase().compareTo((mb['title'] ?? '').toString().toLowerCase());
      } else if (_sortColumnIndex == 1) {
        cmp = (ma['status'] ?? '').toString().compareTo((mb['status'] ?? '').toString());
      } else if (_sortColumnIndex == 2) {
        cmp = (ma['priority'] ?? '').toString().compareTo((mb['priority'] ?? '').toString());
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
              final hay = '${m['title'] ?? ''} ${m['requesterEmail'] ?? ''} ${m['status'] ?? ''} ${m['priority'] ?? ''}'.toLowerCase();
              return hay.contains(_search.toLowerCase());
            }).toList();
      _totalPages = (body['pagination']?['totalPages'] ?? 1) as int;
      _loading = false;
    });
  }

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search title, email, status, priority...',
                      filled: true,
                      fillColor: Color(0xFFF4F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
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
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Statuses')),
                    ..._workflowPhases.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Text(e.value['icon']),
                          const SizedBox(width: 8),
                          Text(e.value['name']),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _status = v;
                      _page = 1;
                    });
                    _load();
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _priority,
                  hint: const Text('Priority'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Priorities')),
                    ..._priorities.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: e.value['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.value['name']),
                        ],
                      ),
                    )),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _priority = v;
                      _page = 1;
                    });
                    _load();
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _category,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ..._categories.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    )),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _category = v;
                      _page = 1;
                    });
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                DropdownButton<int>(
                  value: _pageSize,
                  items: const [10, 20, 50, 100].map((e) => DropdownMenuItem(
                    value: e,
                    child: Text('$e per page'),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        _pageSize = v;
                        _page = 1;
                      });
                      _load();
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: _page > 1 ? () {
                    setState(() => _page--);
                    _load();
                  } : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$_page / $_totalPages'),
                ),
                IconButton(
                  onPressed: _page < _totalPages ? () {
                    setState(() => _page++);
                    _load();
                  } : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 1400),
                      child: Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: DataTable(
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columnSpacing: 28,
                          columns: [
                            const DataColumn(label: Text('Ticket #')),
                            DataColumn(
                              label: const Text('Title'),
                              onSort: (i, asc) {
                                setState(() {
                                  _sortColumnIndex = i;
                                  _sortAscending = asc;
                                });
                                _load();
                              },
                            ),
                            DataColumn(
                              label: const Text('Status'),
                              onSort: (i, asc) {
                                setState(() {
                                  _sortColumnIndex = i;
                                  _sortAscending = asc;
                                });
                                _load();
                              },
                            ),
                            DataColumn(
                              label: const Text('Priority'),
                              onSort: (i, asc) {
                                setState(() {
                                  _sortColumnIndex = i;
                                  _sortAscending = asc;
                                });
                                _load();
                              },
                            ),
                            const DataColumn(label: Text('Category')),
                            const DataColumn(label: Text('Requester')),
                            DataColumn(
                              label: const Text('Created At'),
                              onSort: (i, asc) {
                                setState(() {
                                  _sortColumnIndex = i;
                                  _sortAscending = asc;
                                });
                                _load();
                              },
                            ),
                            const DataColumn(label: Text('Actions')),
                          ],
                          rows: _rows.asMap().entries.map<DataRow>((entry) {
                            final idx = entry.key;
                            final ticket = entry.value as Map<String, dynamic>;
                            final id = (ticket['id'] ?? '') as String;
                            final status = (ticket['status'] ?? '') as String;
                            final priority = (ticket['priority'] ?? '') as String;
                            
                            return DataRow(
                              color: MaterialStatePropertyAll(
                                idx % 2 == 0 ? Colors.white : const Color(0xFFFAFAFA),
                              ),
                              selected: _selectedIds.contains(id),
                              onSelectChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedIds.add(id);
                                  } else {
                                    _selectedIds.remove(id);
                                  }
                                });
                              },
                              cells: [
                                DataCell(
                                  Text(
                                    ticket['ticketNumber'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ticket['title'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(
                                  _buildStatusChip(status),
                                ),
                                DataCell(
                                  _buildPriorityChip(priority),
                                ),
                                DataCell(
                                  Text(_categories[ticket['category']] ?? ticket['category'] ?? ''),
                                ),
                                DataCell(
                                  Text(ticket['requesterEmail'] ?? ''),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat('yyyy-MM-dd HH:mm').format(
                                      DateTime.parse(ticket['createdAt']).toLocal(),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  InkWell(
                                    onTap: () => _openDetails(id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.open_in_new, size: 20),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final phaseInfo = _workflowPhases[status] ?? {'name': status, 'color': Colors.grey, 'icon': '📋'};
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(phaseInfo['icon']),
          const SizedBox(width: 4),
          Text(phaseInfo['name']),
        ],
      ),
      backgroundColor: (phaseInfo['color'] as Color).withOpacity(0.12),
      labelStyle: TextStyle(color: phaseInfo['color'] as Color),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final priorityInfo = _priorities[priority] ?? {'name': priority, 'color': Colors.grey};
    return Chip(
      label: Text(priorityInfo['name']),
      backgroundColor: (priorityInfo['color'] as Color).withOpacity(0.12),
      labelStyle: TextStyle(color: priorityInfo['color'] as Color),
    );
  }

  Widget _buildTimelineDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
