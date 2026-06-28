// lib/partners/partners_list_screen.dart (live data from API)
import 'package:flutter/material.dart';
import 'package:helpinghand/utils/responsive_helper.dart';
import 'package:helpinghand/services/api_service.dart';

class PartnersApp extends StatelessWidget {
  const PartnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Partners',
          style: TextStyle(
            fontSize: ResponsiveHelper.responsiveHeadingSize(context),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: const PartnersScreen(),
    );
  }
}

class PartnersScreen extends StatefulWidget {
  const PartnersScreen({super.key});

  @override
  State<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends State<PartnersScreen> {
  List<Map<String, dynamic>> _partners = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      // Public endpoint — returns active partners managed by the admin.
      final response = await ApiService.get('/partners');
      final List list = (response['data'] as List?) ?? [];
      final mapped = list.map<Map<String, dynamic>>((p) {
        final m = Map<String, dynamic>.from(p as Map);
        // Keep an 'image' alias for the detail screen.
        m['image'] = m['logo_url'];
        return m;
      }).toList();
      if (!mounted) return;
      setState(() {
        _partners = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load partners. Pull down to retry.';
        _isLoading = false;
      });
    }
  }

  ImageProvider? _logoImage(String? url) {
    if (url != null && url.startsWith('http')) return NetworkImage(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    int crossAxisCount = 3;
    if (screenWidth < 480) crossAxisCount = 2;
    if (screenWidth < 360) crossAxisCount = 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our trusted partners who collaborate with us to make a difference in the lives of those in need.',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchPartners,
              color: const Color(0xFF2A9D8F),
              child: _buildBody(crossAxisCount, isSmallScreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int crossAxisCount, bool isSmallScreen) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2A9D8F)));
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80),
          Icon(Icons.error_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
        ],
      );
    }
    if (_partners.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 80),
          Icon(Icons.handshake_outlined, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text('No partners to show yet.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      itemCount: _partners.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: isSmallScreen ? 0.9 : 0.75,
      ),
      itemBuilder: (context, index) {
        final partner = _partners[index];
        final logo = _logoImage(partner['logo_url']?.toString());
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: CircleAvatar(
                radius: isSmallScreen ? 40 : 45,
                backgroundColor: Colors.white,
                backgroundImage: logo,
                onBackgroundImageError: logo != null ? (e, s) {} : null,
                child: logo == null
                    ? Icon(Icons.business,
                        size: isSmallScreen ? 40 : 45,
                        color: const Color(0xFF2A9D8F).withOpacity(0.7))
                    : null,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Text(
                partner['name']?.toString() ?? '',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A9D8F),
                minimumSize: Size(isSmallScreen ? 80 : 90, isSmallScreen ? 30 : 35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/partners-detail', arguments: partner);
              },
              child: Text(
                'View Details',
                style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        );
      },
    );
  }
}
