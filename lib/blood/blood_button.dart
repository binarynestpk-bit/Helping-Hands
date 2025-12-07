import 'package:flutter/material.dart';
import 'package:helpinghand/blood/blood_donation.dart';
import 'package:helpinghand/blood/blood_form.dart';
import 'package:helpinghand/blood/blood_requests.dart';
import 'package:helpinghand/blood/blood_requests_list.dart';
import 'package:helpinghand/blood/blood_request_detail.dart';
import 'package:helpinghand/blood/my_blood_requests.dart';
void main() {
  runApp(BloodApp());
}

class BloodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Navigation',
      initialRoute: '/',
      routes: {

        '/blooddonation' : (context) => BloodDonationApp(),
        '/bloodform' : (context) => BloodForm(),
        '/bloodrequests' : (context) => BloodRequests(),
        '/bloodrequestslist' : (context) => BloodRequestsList(),
        '/bloodrequestdetail' : (context) => BloodRequestDetail(),
        '/my-blood-requests': (context) => MyBloodRequests(),

      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/blooddonation');
              },
              child: Text('Go to Blood Donation'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bloodform');
              },
              child: Text('Go to Blood Form'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bloodrequests');
              },
              child: Text('Go to Blood Requests'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bloodrequestslist');
              },
              child: Text('Go to Blood Requests List'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bloodrequestdetail');
              },
              child: Text('Go to Blood Request Detail'),
            ),

          ],
        ),
      ),
    );
  }
}



