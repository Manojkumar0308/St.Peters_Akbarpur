import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../host_service/host_services.dart';
import 'package:http/http.dart' as http;

class StudentByClassViewModel extends ChangeNotifier {
  final HostService hostService = HostService();

  List<dynamic>? students;
  bool isLoading = false;
  // ignore: prefer_typing_uninitialized_variables
  var data;

  Future<void> getStudentsByFilter(String className, String section) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final schoolid = pref.getInt('schoolid');
      final sessionid = pref.getInt('sessionid');
      String url =
          '${baseurl.toString()}${HostService().getStudentByFilterUrl}';
      print('student by class:$url');
      isLoading = true;
      notifyListeners();
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
        'Accept-Encoding': 'gzip'
      };

      final body = jsonEncode({
        "RegNo": "",
        "stuname": "",
        "fathername": "",
        "classname": className.toString(),
        "sectionname": section,
        "conveyance": "",
        "stopname": "",
        "dob": "20230721000000",
        "schoolid": schoolid,
        "sessionid": sessionid
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = GZipCodec().decode(response.bodyBytes);
        data = utf8.decode(jsonData);
        students = jsonDecode(data);
      } else {
        // Handle the error scenario
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle the error scenario
      print('API call failed with error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
