import 'package:flutter/material.dart';
import 'package:helpinghand/services/api_service.dart';
import 'package:helpinghand/services/auth_service.dart';
import 'package:helpinghand/widgets/guest_access.dart';

class ViewProfileScreen extends StatefulWidget {
  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/user/profile');

      if (response['success'] == true) {
        setState(() {
          _userData = response['data']['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AuthService.isGuest()) {
      return const GuestLockedScaffold(title: 'Profile');
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF2A9D8F),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/edit-profile',
                arguments: _userData,
              );
              if (result == true) {
                _loadUserProfile(); // Reload profile after edit
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2A9D8F),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  color: Color(0xFF2A9D8F),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Profile Header
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2A9D8F), Color(0xFF21867A)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: _userData?['profile_image_url'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _userData!['profile_image_url'],
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.person, size: 60, color: Color(0xFF2A9D8F)),
                                        ),
                                      )
                                    : Icon(Icons.person, size: 60, color: Color(0xFF2A9D8F)),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _userData?['full_name'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_userData?['status']),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (_userData?['status'] ?? 'N/A').toString().toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Profile Details
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoCard(
                                'Personal Information',
                                [
                                  _buildInfoRow(Icons.person, 'Full Name', _userData?['full_name']),
                                  _buildInfoRow(Icons.supervisor_account, 'Father Name', _userData?['father_name']),
                                  _buildInfoRow(Icons.credit_card, 'CNIC', _userData?['cnic']),
                                  _buildInfoRow(Icons.bloodtype, 'Blood Group', _userData?['blood_group']),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildInfoCard(
                                'Contact Information',
                                [
                                  _buildInfoRow(Icons.email, 'Email', _userData?['email']),
                                  _buildInfoRow(Icons.phone, 'Phone', _userData?['phone']),
                                  _buildInfoRow(Icons.location_city, 'City', _userData?['city']),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildInfoCard(
                                'Address',
                                [
                                  _buildInfoRow(Icons.home, 'Current Address', _userData?['current_address']),
                                  _buildInfoRow(Icons.location_on, 'Permanent Address', _userData?['permanent_address']),
                                ],
                              ),
                              SizedBox(height: 16),
                              _buildInfoCard(
                                'Account Information',
                                [
                                  _buildInfoRow(Icons.verified_user, 'Email Verified', _userData?['email_verified'] == true ? 'Yes' : 'No'),
                                  _buildInfoRow(Icons.phone_android, 'Phone Verified', _userData?['phone_verified'] == true ? 'Yes' : 'No'),
                                  _buildInfoRow(Icons.calendar_today, 'Joined', _formatDate(_userData?['created_at'])),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A9D8F),
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value?.toString() ?? 'Not provided',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'suspended':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
