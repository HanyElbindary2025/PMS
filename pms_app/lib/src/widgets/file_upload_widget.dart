import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  final String ticketId;
  final String? stageId;
  final List<String> allowedCategories;
  final Function(List<Map<String, dynamic>>)? onFilesUploaded;

  const FileUploadWidget({
    super.key,
    required this.ticketId,
    this.stageId,
    this.allowedCategories = const [],
    this.onFilesUploaded,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<Map<String, dynamic>> _uploadedFiles = [];
  bool _uploading = false;
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingFiles();
  }

  Future<void> _loadExistingFiles() async {
    try {
      final uri = Uri.parse('http://localhost:3000/attachments/ticket/${widget.ticketId}');
      if (widget.stageId != null) {
        uri.replace(queryParameters: {'stageId': widget.stageId!});
      }
      
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final files = List<Map<String, dynamic>>.from(json.decode(res.body));
        setState(() {
          _uploadedFiles = files;
        });
      }
    } catch (e) {
      print('Error loading files: $e');
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          'txt', 'csv', 'json', 'xml',
          'jpg', 'jpeg', 'png', 'gif', 'webp',
          'zip', 'rar'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        await _uploadFiles(result.files);
      }
    } catch (e) {
      _showError('Error picking files: $e');
    }
  }

  Future<void> _uploadFiles(List<PlatformFile> files) async {
    setState(() => _uploading = true);

    try {
      for (final file in files) {
        await _uploadSingleFile(file);
      }
      
      await _loadExistingFiles();
      
      if (widget.onFilesUploaded != null) {
        widget.onFilesUploaded!(_uploadedFiles);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${files.length} file(s) uploaded successfully')),
      );
    } catch (e) {
      _showError('Error uploading files: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _uploadSingleFile(PlatformFile file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/attachments/upload'),
    );

    request.fields['ticketId'] = widget.ticketId;
    if (widget.stageId != null) {
      request.fields['stageId'] = widget.stageId!;
    }
    if (_selectedCategory != null) {
      request.fields['category'] = _selectedCategory!;
    }
    if (_descriptionController.text.trim().isNotEmpty) {
      request.fields['description'] = _descriptionController.text.trim();
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
      ),
    );

    final response = await request.send();
    
    if (response.statusCode != 201) {
      throw Exception('Upload failed with status: ${response.statusCode}');
    }
  }

  Future<void> _downloadFile(String attachmentId, String fileName) async {
    try {
      final res = await http.get(
        Uri.parse('http://localhost:3000/attachments/download/$attachmentId'),
      );
      
      if (res.statusCode == 200) {
        // In a real app, you would save the file to device storage
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: $fileName')),
        );
      } else {
        _showError('Download failed');
      }
    } catch (e) {
      _showError('Error downloading file: $e');
    }
  }

  Future<void> _deleteFile(String attachmentId, String fileName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final res = await http.delete(
          Uri.parse('http://localhost:3000/attachments/$attachmentId'),
        );
        
        if (res.statusCode == 200) {
          await _loadExistingFiles();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted: $fileName')),
          );
        } else {
          _showError('Delete failed');
        }
      } catch (e) {
        _showError('Error deleting file: $e');
      }
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

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return '🖼️';
      case 'zip':
      case 'rar':
        return '📦';
      case 'txt':
        return '📄';
      case 'json':
      case 'xml':
        return '🔧';
      default:
        return '📎';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file),
                const SizedBox(width: 8),
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_uploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _pickAndUploadFiles,
                    icon: const Icon(Icons.add),
                    tooltip: 'Upload Files',
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Upload Options
            if (widget.allowedCategories.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Select Category')),
                  ...widget.allowedCategories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 12),
            ],
            
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a description for the files...',
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // File List
            if (_uploadedFiles.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No files uploaded yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _uploadedFiles.length,
                itemBuilder: (context, index) {
                  final file = _uploadedFiles[index];
                  final fileName = file['originalName'] ?? '';
                  final fileSize = file['fileSize'] ?? 0;
                  final category = file['category'] ?? '';
                  final description = file['description'] ?? '';
                  final uploadedAt = file['uploadedAt'] ?? '';
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Text(
                        _getFileIcon(fileName),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_formatFileSize(fileSize)}'),
                          if (category.isNotEmpty) Text('Category: $category'),
                          if (description.isNotEmpty) Text('Description: $description'),
                          if (uploadedAt.isNotEmpty) 
                            Text('Uploaded: ${DateTime.parse(uploadedAt).toLocal().toString().split('.')[0]}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => _downloadFile(file['id'], fileName),
                            icon: const Icon(Icons.download),
                            tooltip: 'Download',
                          ),
                          IconButton(
                            onPressed: () => _deleteFile(file['id'], fileName),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
