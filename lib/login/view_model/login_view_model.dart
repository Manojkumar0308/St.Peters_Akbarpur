import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../bottomnavigation/bottomnavigation_screen.dart';
import '../../host_service/host_services.dart';
import '../../notification_services/notification_services.dart';
import '../../utils/common_methods.dart';

class LoginProvider extends ChangeNotifier {
  bool _passwordVisible = false;
  String? baseurl;
  String? schoolname;
  final HostService hostService = HostService();
  var responseData;
  bool isLoading = false;
  static NotificationServices notificationServices = NotificationServices();
  /* a getter method that returns the value of the _passwordVisible variable.
   Getters are used to access the value of private class variables 
   from outside the class.*/

  bool get passwordVisible => _passwordVisible;
//method to show hide password characters.
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<void> schoolDetailApi(String schoolname) async {
    final pref = await SharedPreferences.getInstance();
    final url = Uri.parse(hostService.schoolNameApiUrl + schoolname);
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        pref.setInt("schoolid", jsonData['schoolid']);
        pref.setString('schoolname', jsonData['schoolname']);

        pref.setString('schoolwebsite', jsonData['schoolwebsite']);
        pref.setString('apiurl', jsonData['apiurl']);
        pref.setString('Validity', jsonData['Validity']);
        pref.setInt("smsbalance", jsonData['smsbalance']);

        final schoolwebsite = pref.getString('schoolwebsite');

        baseurl = pref.getString('apiurl');

        // Process the jsonData here
        print(jsonData);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception is : $e');
    }
  }

  Future<void> login(String mobno, String passwd, String userType,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    schoolname = pref.getString('schoolname').toString();
    print(schoolname);
    try {
      isLoading = true;
      final Map<String, dynamic> requestBody = {
        "NameOfUser": "",
        "mobno": mobno,
        "password": passwd,
        "imei": "",
        "email": "",
        "otp": "",
        "schoolusername": hostService.schoolname,
        "usertype": userType
      };
      print(requestBody);
      final pref = await SharedPreferences.getInstance();

      final url = Uri.parse(baseurl.toString() + hostService.loginApiUrl);
      print('Manoj:$url');
      final response = await http.post(
        url,
        /*  header indicates the type of data being sent in the request body.
        'application/json' signifies that the request body will contain JSON-encoded data.*/
        headers: {'Content-Type': 'application/json'},
        //  function is used to convert the requestBody map into a JSON-formatted string.
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        // Handle successful response

        /*
        It is used to parse a JSON-formatted string and convert 
        it into a Dart object or data structure. */
        responseData = jsonDecode(response.body);
        print(responseData);

        // ignore: duplicate_ignore
        if (responseData['resultcode'] == 0) {
          notificationServices.requestNotificationPermission();
          pref.setString('userToken', responseData['token'].toString());

          // pref.setInt('schoolid', responseData['schoolid']);
          pref.setInt('sessionid', responseData['sessionid']);
          pref.setInt('userid', responseData['userid']);

          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const BottomNavigationScreen()),
              (Route<dynamic> route) => false);

          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Login Successfully');

          NotificationServices().getDeviceToken();

          // ignore: use_build_context_synchronously
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, responseData['resultstring']);
        }
      } else {
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, 'Something went wrong');
        // Handle error response
        if (kDebugMode) {
          print('POST request failed with status code: ${response.statusCode}');
        }
      }
      isLoading = false;
    } catch (e) {
      isLoading = false;
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
  }
}
