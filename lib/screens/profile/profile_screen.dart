import 'package:flutter/material.dart';
import 'profile_item.dart';
import '/widgets/custom_dialog.dart';
import '/themes/app_theme.dart';
import '/themes/elder_theme.dart';

class ProfileScreen extends StatefulWidget {
  final bool elderMode;

  const ProfileScreen({required this.elderMode});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _ageController = TextEditingController(text: '72');
  final _contactController = TextEditingController(text: '+1 234-567-8900');

  @override
  Widget build(BuildContext context) {
    final theme = widget.elderMode ? elderTheme : appTheme;
    
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(widget.elderMode ? 16 : 24),
        children: [
          _buildProfileHeader(theme),
          ProfileItem(
            icon: Icons.person,
            label: 'Name',
            value: _nameController.text,
            elderMode: widget.elderMode,
          ),
          ProfileItem(
            icon: Icons.cake,
            label: 'Age',
            value: _ageController.text,
            elderMode: widget.elderMode,
          ),
          ProfileItem(
            icon: Icons.phone,
            label: 'Emergency Contact',
            value: _contactController.text,
            elderMode: widget.elderMode,
          ),
          // Add more profile items
          _buildEditButton(theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: widget.elderMode ? 60 : 50,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(
              Icons.person,
              size: widget.elderMode ? 50 : 40,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            _nameController.text,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: widget.elderMode ? 28 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: Icon(Icons.edit, size: widget.elderMode ? 28 : 24),
        label: Text(
          'Edit Profile',
          style: TextStyle(fontSize: widget.elderMode ? 20 : 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: widget.elderMode ? 18 : 14,
            horizontal: 32,
          ),
        ),
        onPressed: () => _showEditDialog(context),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Edit Profile',
        elderMode: widget.elderMode,
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, 'Name'),
              _buildTextField(_ageController, 'Age', TextInputType.number),
              _buildTextField(_contactController, 'Emergency Contact', TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(widget.elderMode ? 16 : 12),
        ),
        keyboardType: keyboardType,
        style: TextStyle(fontSize: widget.elderMode ? 18 : 16),
        validator: (value) => value!.isEmpty ? 'Required field' : null,
      ),
    );
  }
}