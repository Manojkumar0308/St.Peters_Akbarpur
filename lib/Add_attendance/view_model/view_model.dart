import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import 'package:http/http.dart' as http;

import '../../utils/common_methods.dart';
import '../model/model.dart';

class AttendanceViewModel extends ChangeNotifier {
  //ChangeNotifier it's used in Flutter to manage state and notify widgets when data changes.
  bool isLoading = false;
  // boolean flag that indicates whether data is currently being loaded.
  bool snackbarShown = false;
  //A boolean flag to track whether a snackbar has been shown.
  List<GetStudentByFilter> students = [];

  //list of GetStudentByFilter objects representing student data filtering by class and section.
  String? resultAttendance;
  Future<void> getStudentByFilter(
      String className, String sectionName, BuildContext context) async {
    // fetch student data by applying filters such as class name and section name.
    isLoading = true;
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final schoolid = pref.getInt('schoolid');
    final sessionid = pref.getInt('sessionid');

    final url = Uri.parse('$baseurl${HostService().getStudentByFilterUrl}');
    print('add attendance get student url:$url');
    final body = {
      "RegNo": "",
      "stuname": "",
      "fathername": "",
      "classname": className,
      "sectionname": sectionName,
      "conveyance": "",
      "stopname": "",
      "dob": "",
      "schoolid": schoolid,
      "sessionid": sessionid
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Charset': 'utf-8',
          'Accept-Encoding': 'gzip'
        },
        body: jsonEncode(body),
      );
      print(body);
      if (response.statusCode == 200) {
        final decodedData = GZipCodec().decode(response.bodyBytes);
        final data = utf8.decode(decodedData);
        final result = jsonDecode(data);
        if (result == null) {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Student Records is Empty');
        }
        students.clear();

        for (var studentData in result) {
          students.add(GetStudentByFilter.fromJson(studentData));
        }

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      print('error throw $e');
      notifyListeners();
    }
  }

/* below method adding attendance records. It sends a JSON request to the server with information
 like registration number, attendance date, and attendance status. It also handles 
 the response and shows a snackbar with the result. */
  Future<void> addAttendance(String regNo, String attdate, String attendance,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final schoolid = pref.getInt('schoolid');
    final sessionid = pref.getInt('sessionid');
    final url = Uri.parse('$baseurl${HostService().addAttendanceUrl}');
    print('add attendance api url:$url');
    final List<Map<String, dynamic>> body = [
      {
        "schoolid": schoolid,
        "sessionid": sessionid,
        "userid": pref.getInt('userid'),
        "regno": regNo,
        "attdate": attdate,
        "attendance": attendance,
      },
    ];
    try {
      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Charset': 'utf-8',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Success: You can handle the response here
        if (!snackbarShown) {
          if (result['resultcode'] == 1) {
            // ignore: use_build_context_synchronously
            CommonMethods().showSnackBar(context, result['resultstring']);
          } else if (result['resultcode'] == 0) {
            // ignore: use_build_context_synchronously
            CommonMethods().showSnackBar(context, result['resultstring']);
          }

          snackbarShown = true;
          // Set the flag to true after showing the snackbar
        }
      } else {
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, 'Something went wrong');
      }
    } catch (e) {
      // Handle exceptions
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
  }
}
