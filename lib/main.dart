// main.dart - UPDATED WITH MY FAMILY REQUESTS ROUTE
import 'package:flutter/material.dart';
import 'package:helpinghand/screens/splash_screen.dart';
import 'package:helpinghand/screens/signin_screen.dart';
import 'package:helpinghand/screens/signup_screen.dart';
import 'package:helpinghand/screens/forget_password_screen.dart';
import 'package:helpinghand/screens/verify_phone_screen.dart';
import 'package:helpinghand/screens/create_new_password_screen.dart';
import 'package:helpinghand/screens/profile_completion_screen.dart';
import 'package:helpinghand/screens/home_screen.dart';
import 'package:helpinghand/screens/notification_screen.dart';
import 'package:helpinghand/screens/islamic_donation_screen.dart';
import 'package:helpinghand/partners/partners_list_screen.dart';
import 'package:helpinghand/partners/partners_detail_screen.dart';
import 'package:helpinghand/shaheed/shaheed_family_screen.dart';
import 'package:helpinghand/shaheed/shaheed_family_form_screen.dart';
import 'package:helpinghand/shaheed/shaheed_request_screen.dart';
import 'package:helpinghand/shaheed/shaheed_detail_screen.dart';
import 'package:helpinghand/shaheed/shaheed_donation_confirm.dart';
import 'package:helpinghand/shaheed/my_family_requests.dart'; // NEW IMPORT
import 'package:helpinghand/education/education_donation.dart';
import 'package:helpinghand/education/education_form.dart';
import 'package:helpinghand/education/education_requestes.dart';
import 'package:helpinghand/education/education_requests_list.dart';
import 'package:helpinghand/education/education_donation_confirm.dart';
import 'package:helpinghand/education/education_request_detail.dart';
import 'package:helpinghand/education/my_education_requests.dart';
import 'package:helpinghand/blood/blood_donation.dart';
import 'package:helpinghand/blood/blood_form.dart';
import 'package:helpinghand/blood/blood_requests.dart';
import 'package:helpinghand/blood/blood_requests_list.dart';
import 'package:helpinghand/blood/blood_request_detail.dart';
import 'package:helpinghand/blood/my_blood_requests.dart';
import 'package:helpinghand/screens/view_profile_screen.dart';
import 'package:helpinghand/screens/edit_profile_screen.dart';
import 'package:helpinghand/screens/settings_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trusting Help',
      initialRoute: '/splash',
      routes: {
        // Auth flow
        '/splash': (context) => SplashScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/forget-password': (context) => ForgetPasswordScreen(),
        '/verify-phone': (context) => VerifyPhoneScreen(),
        '/create-new-password': (context) => CreateNewPasswordScreen(),
        '/profile-completion': (context) => ProfileCompletionScreen(),
        '/general-donation':(context) => IslamicDonationScreen(),

        // Main screens
        '/home': (context) => HomeScreen(),
        '/notifications': (context) => NotificationApp(),
        '/view-profile': (context) => ViewProfileScreen(),
        '/edit-profile': (context) {
          final userData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return EditProfileScreen(userData: userData);
        },
        '/settings': (context) => SettingsScreen(),

        // Partners
        '/partners': (context) => PartnersApp(),
        '/partners-detail': (context) => PartnerDetailsScreen(),

        // Shaheed/Family modules (UPDATED WITH BACKEND INTEGRATION)
        '/shaheed-family': (context) => ShuhadaFamilySupportApp(),
        '/shaheed-family-form': (context) => RequestShuhadaSupportScreen(),
        '/shaheed-requests': (context) => ShuhadaSupportRequests(),
        '/shaheed-detail': (context) => ShaheedFamilyDetail(),
        '/shaheed-donation-confirm': (context) => ConfirmDonationApp(),
        '/my-family-requests': (context) => MyFamilyRequests(), // NEW ROUTE

        // Education modules
        '/education-donation': (context) => EducationDonationApp(),
        '/education-form': (context) => RequestEducationSupport(),
        '/education-requests': (context) => EducationRequests(),
        '/education-requests-list': (context) => EducationRequestsList(),
        '/education-donation-confirm': (context) => EducationConfirmDonationApp(),
        '/education-request-detail': (context) => EducationRequestDetail(),
        '/my-education-requests': (context) => MyEducationRequests(),

        // Blood donation modules
        '/blood-donation': (context) => BloodDonationApp(),
        '/blood-form': (context) => BloodForm(),
        '/blood-requests': (context) => BloodRequests(),
        '/blood-requests-list': (context) => BloodRequestsList(),
        '/blood-request-detail': (context) => BloodRequestDetail(),
        '/my-blood-requests': (context) => MyBloodRequests(),

        // Family support routes (using same shaheed screens with backend)
        '/family-requests': (context) => ShuhadaSupportRequests(),
        '/family-detail': (context) => ShaheedFamilyDetail(),
        '/family-donation-confirm': (context) => ConfirmDonationApp(),
      },
    );
  }
}