import 'package:flutter/material.dart';
import 'package:born2bewild/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, dynamic> _userProfile = {
    'First Name': 'John',
    'Last Name': 'Doe',
    'did':
        'did:algo:J4PCC5KTBIEREW7EVNU6I6FQMRQFM7B57G624ETVT2LXD3RRZFQEVK53HQ',
    // 'email': 'john.doe@example.com',
    // 'phone': '+1234567890',
    'location': 'Paris, France',
    'joinDate': '2024-11-01',
    'score': 75,
    'verificationStatus': 'Verified',
    'activeCredentials': 3,
  };

  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                _saveProfile();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildProfileDetails(),
            _buildStats(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              if (_isEditing)
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      // Implémenter la logique de changement de photo
                    },
                  ),
                ),
            ],
          ),
          /*
          const SizedBox(height: 16),
          _isEditing
              ? TextFormField(
                  initialValue: _userProfile['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                )
              : Text(
                  _userProfile['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                */
          const SizedBox(height: 8),
          Text(
            _userProfile['did'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            /*
            _buildDetailRow(
              'Email',
              _userProfile['email'],
              Icons.email,
              editable: true,
            ),
            _buildDetailRow(
              'Phone',
              _userProfile['phone'],
              Icons.phone,
              editable: true,
            ),
            */
            _buildDetailRow(
              'First Name',
              _userProfile['First Name'],
              Icons.person,
              editable: true,
            ),
            _buildDetailRow(
              'Last Name',
              _userProfile['Last Name'],
              Icons.person,
              editable: true,
            ),
            _buildDetailRow(
              'Location',
              _userProfile['location'],
              Icons.location_on,
              editable: true,
            ),
            _buildDetailRow(
              'Member Since',
              _userProfile['joinDate'],
              Icons.calendar_today,
              editable: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool editable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (_isEditing && editable)
                  TextFormField(
                    initialValue: value,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Score',
              '${_userProfile['score']}%',
              Icons.star,
            ),
            _buildStatItem(
              'Status',
              _userProfile['verificationStatus'],
              Icons.verified_user,
            ),
            _buildStatItem(
              'Credentials',
              _userProfile['activeCredentials'].toString(),
              Icons.badge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildActionTile(
            'Backup DID',
            'Secure your identity',
            Icons.backup,
            () => _showBackupOptions(),
          ),
          const Divider(),
          _buildActionTile(
            'Privacy Settings',
            'Manage your data sharing',
            Icons.privacy_tip,
            () => _showPrivacySettings(),
          ),
          const Divider(),
          _buildActionTile(
            'Recovery Options',
            'Set up account recovery',
            Icons.restore,
            () => _showRecoveryOptions(),
          ),
          const Divider(),
          _buildActionTile(
            'Logout',
            'Sign out from this device',
            Icons.logout,
            () => _confirmLogout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _saveProfile() {
    // Implémenter la sauvegarde du profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _showBackupOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('Export as QR Code'),
            ),
            ListTile(
              leading: Icon(Icons.file_download),
              title: Text('Download Backup File'),
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload),
              title: Text('Cloud Backup'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySettings() {
    // Implémenter les paramètres de confidentialité
  }

  void _showRecoveryOptions() {
    // Implémenter les options de récupération
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implémenter la logique de déconnexion
              Navigator.pop(context);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
