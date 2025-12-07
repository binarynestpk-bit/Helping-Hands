import 'package:flutter/material.dart';

void main() {
  runApp(ShaheedFamilyRequest());
}

class ShaheedFamilyRequest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Education Support ',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
            children: [
              TextSpan(
                text: 'Requests',
                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search field moved to the top
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by student name, institution, or degree...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Pushes the empty state to the center
            Image.asset(
              'assets/empty-folder.png', // Use the correct path for the empty folder image
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'No Requests Available Right Now',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(), // Keeps content centered
          ],
        ),
      ),
    );
  }
}
