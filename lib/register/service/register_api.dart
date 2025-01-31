import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../forgot_password/service/forgot_password_api.dart';
import '../../host_service/host_services.dart';
import '../../login/view/login_screen.dart';
import '../../utils/common_methods.dart';
import '../view/register_verify_screen.dart';

class RegisterApi {
  final HostService hostService = HostService();
  final String apiUrl = '/api/User/Register';
  final String otpUrl = '/api/User/Verify';

  Future<void> userRegister(String userName, String mobno,String passwd, String email,
      String schoolUsername, String userType, BuildContext context) async {
    ForgotPasswordService().schoolDetailApi('peters');
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    try {
      final Map<String, dynamic> requestBody = {
        "NameOfUser": userName,
        "mobno": mobno,
        "password": passwd,
        "imei": "",
        "email": email,
        "otp": "",
        "schoolusername": schoolUsername,
        "usertype": userType
      };

      print(requestBody);
      final String url = '$baseurl${hostService.userRegisterUrl}';
      print(url);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Handle successful response

        if (kDebugMode) {
          print(response.body);
        }

        final responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData == "0") {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Otp sent');
          // ignore: use_build_context_synchronously
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RegVerifyScreen()));
        } else if (responseData == "2") {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, responseData);
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, 'login');
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, responseData);
        }
      } else {
        // Handle error response
        if (kDebugMode) {
          print('POST request failed with status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Handle network or other exceptions
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
  }

  Future<void> otpVerification(
      String userName,
      String mobno,
      String passwd,
      String email,
      String otp,
      String schoolUsername,
      String userType,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    try {
      final Map<String, dynamic> requestBody = {
        "NameOfUser": userName,
        "mobno": mobno,
        "password": passwd,
        "imei": "",
        "email": email,
        "otp": otp,
        "schoolusername": schoolUsername,
        "usertype": userType
      };

      final response = await http.post(
        Uri.parse('$baseurl$otpUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Handle successful response

        print(response.body);

        final responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData == "0") {
          // ignore: use_build_context_synchronously

          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Registration successful');
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false);
          // Get.to(const LoginScreen());
        } else if (responseData == "1") {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Error occurred');
        } else if (responseData == "2") {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Already present');
        } else if (responseData == "3") {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Invalid otp');
        }
      } else {
        // Handle error response
        print('POST request failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or other exceptions
      print('Error occurred while making the POST request: $e');
    }
  }
}
