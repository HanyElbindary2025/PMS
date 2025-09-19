import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TeamAssignmentWidget extends StatefulWidget {
  final String ticketId;
  final String? currentAssigneeId;
  final List<String>? currentTeamMembers;
  final VoidCallback? onAssignmentChanged;

  const TeamAssignmentWidget({
    super.key,
    required this.ticketId,
    this.currentAssigneeId,
    this.currentTeamMembers,
    this.onAssignmentChanged,
  });

  @override
  State<TeamAssignmentWidget> createState() => _TeamAssignmentWidgetState();
}

class _TeamAssignmentWidgetState extends State<TeamAssignmentWidget> {
  List<Map<String, dynamic>> _users = [];
  String? _selectedAssigneeId;
  List<String> _selectedTeamMembers = [];
  bool _loading = false;
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _selectedAssigneeId = widget.currentAssigneeId;
    _selectedTeamMembers = List.from(widget.currentTeamMembers ?? []);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersData = json.decode(response.body);
        setState(() {
          _users = usersData.cast<Map<String, dynamic>>();
          _loadingUsers = false;
        });
      } else {
        setState(() => _loadingUsers = false);
        _showError('Failed to load users');
      }
    } catch (e) {
      setState(() => _loadingUsers = false);
      _showError('Error loading users: $e');
    }
  }

  Future<void> _assignTicket() async {
    if (_selectedAssigneeId == null && _selectedTeamMembers.isEmpty) {
      _showError('Please select at least one assignee or team member');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/tickets/${widget.ticketId}/assign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'assignedToId': _selectedAssigneeId,
          'teamMembers': _selectedTeamMembers.isNotEmpty ? _selectedTeamMembers : null,
          'comment': 'Ticket assigned via team assignment widget',
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Ticket assigned successfully!');
        widget.onAssignmentChanged?.call();
        Navigator.of(context).pop();
      } else {
        final errorData = json.decode(response.body);
        _showError('Failed to assign ticket: ${errorData['error']}');
      }
    } catch (e) {
      _showError('Error assigning ticket: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildUserChip(Map<String, dynamic> user) {
    final isSelected = _selectedTeamMembers.contains(user['id']);
    final isAssignee = _selectedAssigneeId == user['id'];
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: _getRoleColor(user['role']),
            child: Text(
              user['name'][0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user['name'],
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                user['role'].replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      selected: isSelected || isAssignee,
      onSelected: (selected) {
        setState(() {
          if (isAssignee) {
            // If this user is the assignee, remove from assignee and add to team
            _selectedAssigneeId = null;
            _selectedTeamMembers.add(user['id']);
          } else if (isSelected) {
            // Remove from team members
            _selectedTeamMembers.remove(user['id']);
          } else {
            // Add to team members
            _selectedTeamMembers.add(user['id']);
          }
        });
      },
      selectedColor: _getRoleColor(user['role']).withOpacity(0.2),
      checkmarkColor: _getRoleColor(user['role']),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ADMIN': return Colors.red;
      case 'SERVICE_MANAGER': return Colors.purple;
      case 'SERVICE_DESK': return Colors.blue;
      case 'TECHNICAL_ANALYST': return Colors.orange;
      case 'DEVELOPER': return Colors.green;
      case 'QA_ENGINEER': return Colors.teal;
      case 'SOLUTION_ARCHITECT': return Colors.indigo;
      case 'DEVOPS_ENGINEER': return Colors.cyan;
      case 'OPERATIONS_ENGINEER': return Colors.brown;
      case 'MANAGER': return Colors.grey;
      case 'CREATOR': return Colors.pink;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group_add, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Assign Ticket to Team',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Primary Assignee Section
            Text(
              'Primary Assignee (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAssigneeId,
              decoration: const InputDecoration(
                labelText: 'Select Primary Assignee',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('No Primary Assignee'),
                ),
                ..._users.map((user) => DropdownMenuItem<String>(
                  value: user['id'],
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: _getRoleColor(user['role']),
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(user['name']),
                          Text(
                            user['role'].replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAssigneeId = value;
                  // Remove from team members if selected as primary assignee
                  if (value != null) {
                    _selectedTeamMembers.remove(value);
                  }
                });
              },
            ),
            
            const SizedBox(height: 24),
            
            // Team Members Section
            Text(
              'Team Members',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select additional team members who will work on this ticket:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            // Users Grid
            Expanded(
              child: _loadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _users.map((user) => _buildUserChip(user)).toList(),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected Summary
            if (_selectedAssigneeId != null || _selectedTeamMembers.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignment Summary:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_selectedAssigneeId != null) ...[
                      Text(
                        'Primary: ${_users.firstWhere((u) => u['id'] == _selectedAssigneeId)['name']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    if (_selectedTeamMembers.isNotEmpty) ...[
                      Text(
                        'Team: ${_selectedTeamMembers.map((id) => _users.firstWhere((u) => u['id'] == id)['name']).join(', ')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _assignTicket,
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Assign Ticket'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
