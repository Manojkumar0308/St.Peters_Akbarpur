// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:image/image.dart' as img;

import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';
import '../model/send_message_model.dart';

class SendMessageViewModel extends ChangeNotifier {
  //lists and properties are declared to store information
  //related to classes, sections, selected classes/sections, registration text controllers,
  //matching students, and class IDs.
  List<String> classes = [];
  List<String> classNames = [];
  List<String> sections = [];
  List<String> sectionNames = [];
  List<String> selectedClasses = [];
  List<String> selectedSections = [];
  List<TextEditingController> registrationTextControllers = [];
  Map<String, dynamic> sendToAllData = {};
  Map<String, dynamic> classWiseData = {};
  Map<String, dynamic> multiclassData = {};
  Map<String, dynamic> regWiseData = {};
  final List<Student> _matchingStudents = [];
  bool isSending = false;
  var result;
  int? classID;
//Getter methods for accessing the _matchingStudents list
// a list called regNumber are defined.
  List<Student> get matchingStudents => _matchingStudents;
  List<String> regNumber = [];
/*Boolean properties are declared to track different messaging options:
  _sendToAll, _multiClass, _classWise, and _registrationWise.  */
  bool _sendToAll = false;
  bool _multiClass = false;
  bool _classWise = false;
  bool _registrationWise = false;
  bool isImage = false;
//Create getters for the boolean properties.
  bool get sendToAll => _sendToAll;

  bool get multiClass => _multiClass;

  bool get classWise => _classWise;

  bool get registrationWise => _registrationWise;

  String? selectedClass;
  String? selectedSection;
  List<String> selectedClassNames = [];
  List<String> selectedSectionNames = [];
  String? fileType;
  String? base64Content;
  String? base64ContentPdf;
  File? selectedImage;
  bool isAttached = false;
  String? filename;
  //Create an instance of the HostService class.
  HostService hostService = HostService();
//method for file picking from gallery or from device storage using File picker package.
  Future<void> pickImageAndSetContent(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      //FilePicker library allows users to select multiple files,
      // .first is used here to work with the first (and possibly the only) selected file.
      PlatformFile file = result.files.first;

      if (file.extension == 'jpg' ||
          file.extension == 'png' ||
          file.extension == 'jpeg') {
        //checking picked file extension for image if it is one of them then set fileType to IMAGE.
        fileType = "IMAGE";
        try {
          final imageFile = File(file.path!);
          //compressing the picked image file.
          File? compressedImageFile = await compressImage(imageFile);
          /*Uint8List is a type representing an immutable list of 8-bit unsigned 
          integers,often used to store binary data, such as image bytes. */
          Uint8List? compressedImageBytes =
              compressedImageFile?.readAsBytesSync();
          //readAsBytesSync method reads the content of the
          //file synchronously and returns it as a Uint8List.

          if (compressedImageBytes != null) {
            // Convert the image to base64
            base64Content = base64.encode(
                compressedImageBytes); //to send image file to the server
            notifyListeners();
          }

          selectedImage = imageFile;
          notifyListeners();
        } catch (e) {
          print("Error compressing the image: $e");
        }
      } else if (file.extension == 'pdf') {
        fileType = "PDF";
        filename = file.name;
        if (file.bytes != null) {
          List<int> fileBytes =
              file.bytes!.toList(); // Convert Uint8List to List<int>
          String base64String =
              base64Encode(fileBytes); // Convert the file to base64 string
          base64ContentPdf = base64String; // Set the base64 content for PDF
          print('base64ContentPdf is --->');
          print(base64ContentPdf);
          base64Content = null;
          notifyListeners();
        } else {
          // Handle the case when file.bytes is null
        }
      } else {
        fileType = "MSG";
        base64Content = null;
      }

      notifyListeners();
    }
  }

  Future<File?> compressImage(File file) async {
    try {
      // getting the temporary directory path using getTemporaryDirectory() from the path_provider library.
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = "${tempDir.path}/temp.jpg";
      /* his method reads the bytes of the image file and decodes them into an Image object.
     (img.Image?). If the decoding is successful and the image is not null, the process continues.*/

      // Compress the image using the image package
      final img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        final img.Image resizedImage = img.copyResize(image, width: 800);

        File compressedImageFile = File(tempFilePath)
          ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 60));
        /* img.encodeJpg method is used to encode the resized image
         as a JPEG with a specified quality of 60.The resulting
         compressed image file is returned as a File object. */

        return compressedImageFile;
      }

      return null;
    } catch (e) {
      print("Error compressing the image: $e");
      return null;
    }
  }

/* Below method sets the fileType to "MSG" and clears the base64Content.
It then notifies listeners of this change. */
  void resetFileTypeAndContent() {
    fileType = "MSG";
    base64Content = null;
    notifyListeners();
  }

/*This method sets the selectedClass to the provided value and notifies
listeners of this change. It is likely used for selecting a class. */
  void setClass(String? value) {
    selectedClass = value;

    notifyListeners();
  }

/* Similar to setClass, this method sets the selectedSection to the provided value and
notifies listeners. It is likely used for selecting a section.*/
  void setSection(String? value) {
    selectedSection = value;
    notifyListeners();
  }

/* This method extracts registration numbers from a list of
TextEditingController objects and returns them as a list of strings.
It iterates through the controllers and retrieves the text from each one */
  List<String> extractRegistrationNumbers() {
    List<String> registrationNumbers = [];
    for (TextEditingController controller in registrationTextControllers) {
      registrationNumbers.add(controller.text);
    }

    return registrationNumbers;
  }

  List<dynamic> data = [];
  List<Map<String, dynamic>> classesData = [];

  /* This asynchronous method sends an HTTP POST request to a specified URL to fetch a list of classes.
  It includes headers and a request body with specific parameters.*/
  Future<void> fetchClasses() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final sessionId = pref.getInt('sessionid');
      final url = Uri.parse(baseurl.toString() + hostService.getClasses);
      print('class url is:$url');
      final headers = {"Content-Type": "application/json"};
      final body = {
        "schoolid": sessionId, //its a sessionId
        "software": "Notification",
        "message": "class",
        "msgtype": "MSG",
        "mnumbers": ["", ""],
        "token": "1d05be08-76d9-4a3d-8c55-2dec5546c445"
      };
      final response =
          await http.post(url, headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        classesData = data.map((item) {
          return {
            'classId': item['classid'],
            'className': item['classname'].toString(),
          };
        }).toList();

        notifyListeners();

        classNames = data.map((item) => item['classname'].toString()).toList();
        classes = classNames;

        fetchSections();
        notifyListeners();
      } else {
        print('Classes not available');
      }
    } catch (e) {
      print('$e'.toString());
    }
  }

/* This asynchronous method sends an HTTP POST request to a specified URL to fetch a list of sections.
  It includes headers and a request body with specific parameters.*/
  List<Map<String, dynamic>> sectionData = [];
  Future<void> fetchSections() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final sessionId = pref.getInt('sessionid');
      print(sessionId);
      final url = Uri.parse(baseurl.toString() + hostService.getSections);
      print('section url is: $url');
      final headers = {"Content-Type": "application/json"};
      final body = {
        "schoolid": sessionId, //its a sessionId
        "software": "Notification",
        "message": "class",
        "msgtype": "MSG",
        "mnumbers": ["", ""],
        "token": "1d05be08-76d9-4a3d-8c55-2dec5546c445"
      };
      final response =
          await http.post(url, headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        final List<dynamic> datasection = json.decode(response.body);

        sectionNames =
            datasection.map((item) => item['sectionname'].toString()).toList();
        sections = sectionNames;
        sectionData = datasection.map((item) {
          return {
            "sectionId": item['sectionid'],
            "sectionName": item['sectionname'].toString(),
          };
        }).toList();

        notifyListeners();
      } else {
        print("Sections not available");
      }
    } catch (e) {
      print('$e'.toString());
    }
  }

/* This method is used to set the notification mode to "Send to All."
It sets the _sendToAll property to the provided value and ensures that
other notification modes (_multiClass, _classWise, and _registrationWise) are set to false.
After making these changes, it notifies listeners of the state change.*/
  void setSendToAll(bool value) {
    _sendToAll = value;
    _multiClass = false;
    _classWise = false;
    _registrationWise = false;
    notifyListeners();
  }

/*
 This method is used to set the notification mode to "Multi-Class."
 It sets the _multiClass property to the provided value and ensures
 that other notification modes are turned off.
 If value is true, it calls the fetchClasses() method (presumably to fetch a list of classes).
 If value is false, it clears the selected classes and sections.
 After making these changes, it notifies listeners of the state change.
*/
  void setMultiClass(bool value) {
    _multiClass = value;
    _sendToAll = false;
    _classWise = false;
    _registrationWise = false;
    if (value) {
      fetchClasses();
    } else {
      selectedClasses.clear();
      selectedSections.clear();
    }
    notifyListeners();
  }

/*Similar to setMultiClass, this method sets the notification mode to "Class-Wise."
It sets the _classWise property accordingly and manages other modes and selected classes/sections.
 It also calls fetchClasses() when value is true. Finally, it notifies listeners.*/
  void setClassWise(bool value) {
    _classWise = value;
    _sendToAll = false;
    _multiClass = false;
    _registrationWise = false;
    if (value) {
      fetchClasses();
    } else {
      selectedClasses.clear();
      selectedSections.clear();
    }
    notifyListeners();
  }

/*This method sets the notification mode to "Registration-Wise."
It updates the _registrationWise property and turns off other modes.
 After setting the mode, it notifies listeners.*/
  void setRegistrationWise(bool value) {
    _registrationWise = value;
    _sendToAll = false;
    _multiClass = false;
    _classWise = false;
    notifyListeners();
  }

  //Send to all Api
  Future<void> sendNotificationToAll(
      String msgType,
      String content,
      String currentDate,
      int userId,
      int schoolId,
      String token,
      int sessionId,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    String url = baseurl.toString() + hostService.sendtoAll;
    print('send to all notify url:$url');
    final Map<String, dynamic> requestBody = {
      "msgtype": msgType,
      "content": content,
      "mdate": currentDate,
      "userid": userId,
      "schoolid": schoolId,
      "token": token,
      "sessionid": sessionId,
      "softwarename": ""
    };
    print('select all body is :$requestBody');

    try {
      isSending = true;
      notifyListeners();
      final response = await http.post(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody));
      print(response.statusCode);

      if (response.statusCode == 200) {
        sendToAllData = jsonDecode(response.body);
        print('select all result $data');
        print('select all result ${data.runtimeType}');
        if (sendToAllData['resultcode'] == 0) {
          isSending = false;
          CommonMethods()
              .showSnackBar(context, 'Notification sent successfully');
          isImage = true;

          notifyListeners();
        } else if (sendToAllData['resultcode'] == 3) {
          CommonMethods().showSnackBar(context, 'Please Login Again');
          isImage = true;
          isSending = false;
          notifyListeners();
        } else {
          CommonMethods().showSnackBar(context, 'Something Went Wrong');
          isImage = true;
          isSending = false;
          notifyListeners();
        }

        notifyListeners();
      } else {
        // Handle API error

        print('Error message: ${response.body}');
        isImage = true;
        isSending = false;
        notifyListeners();
      }
    } catch (e) {
      // Handle any exceptions that occurred during the API call
      print('Error during API call: $e');
      isImage = true;
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> multipleClassApi(
      String msgType,
      String content,
      String currentDate,
      int userid,
      int schoolid,
      String token,
      List<String> className,
      int sessionId,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse(baseurl.toString() + hostService.multipleClass);
    print('multiple class notify url:$url');
    final Map<String, dynamic> body = {
      "msgtype": msgType,
      "content": content,
      "mdate": currentDate,
      "userid": userid,
      "schoolid": schoolid,
      "token": token,
      "classname": className,
      "sessionid": sessionId,
      "softwarename": ""
    };
    print('multiclasswise api $body');
    try {
      isSending = true;
      notifyListeners();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        multiclassData = json.decode(response.body);

        if (multiclassData['resultcode'] == 0) {
          CommonMethods()
              .showSnackBar(context, 'Notification sent successfully');

          selectedClassNames = [];
          isImage = true;
          isAttached = true;
          isSending = false;
          notifyListeners();
        } else if (multiclassData['resultcode'] == 3) {
          CommonMethods().showSnackBar(context, 'Please Login Again');
          selectedClassNames = [];
          isImage = true;
          isSending = false;
          notifyListeners();
        } else {
          CommonMethods().showSnackBar(context, 'Something Went Wrong');
          selectedClassNames = [];
          isImage = true;
          isSending = false;
          notifyListeners();
        }
      } else {
        // Handle errors here
        print("API call failed with status code: ${response.statusCode}");
        isImage = true;
        isSending = false;
        notifyListeners();
      }
    } catch (error) {
      // Handle network errors or exceptions here
      print("Error occurred: $error");
      isImage = true;
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> classWiseApi(
      String msgType,
      String content,
      String currentDate,
      int userid,
      int schoolid,
      String token,
      String className,
      String sectionName,
      int sessionId,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse(baseurl.toString() + hostService.classWise);
    print('class wise notify url:$url');
    final Map<String, dynamic> body = {
      "msgtype": msgType,
      "content": content,
      "mdate": currentDate,
      "userid": userid,
      "schoolid": schoolid,
      "token": token,
      "classname": className,
      "sectionname": sectionName,
      "sessionid": sessionId,
      "softwarename": ""
    };
    print('classwise api $body');
    try {
      isSending = true;
      notifyListeners();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        classWiseData = json.decode(response.body);
        print('classwise data is $classWiseData');
        if (classWiseData['resultCode'] == 0) {
          CommonMethods()
              .showSnackBar(context, 'Notification sent successfully');
          isImage = true;
          isSending = false;
          notifyListeners();
        } else if (classWiseData['resultcode'] == 3) {
          CommonMethods().showSnackBar(context, 'Please Login Again');
          isImage = true;
          isSending = false;
          notifyListeners();
        } else {
          CommonMethods().showSnackBar(context, 'Something Went Wrong');
          isImage = true;
          isSending = false;
          notifyListeners();
        }
      } else {
        // Handle errors here
        print("API call failed with status code: ${response.statusCode}");

        isImage = true;
        isSending = false;
        notifyListeners();
      }
    } catch (error) {
      // Handle network errors or exceptions here
      print("Error occurred: $error");
      isImage = true;
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> registrationNoWiseApi(
      String msgType,
      String content,
      String currentDate,
      int userid,
      int schoolid,
      String token,
      List<String> regNo,
      int sessionId,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse(baseurl.toString() + hostService.regnWise);
    print('reg wise notify url:$url');
    final Map<String, dynamic> body = {
      "msgtype": msgType,
      "content": content,
      "mdate": currentDate,
      "userid": userid,
      "schoolid": schoolid,
      "token": token,
      "regnos": regNo,
      "sessionid": sessionId,
      "softwarename": ""
    };
    print(body);

    try {
      isSending = true;
      notifyListeners();
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        // Decode the response body
        regWiseData = json.decode(response.body);
        print(regWiseData.runtimeType);
        if (regWiseData['resultcode'] == 0) {
          CommonMethods()
              .showSnackBar(context, 'Notification sent successfully');
          regNumber = [];
          isImage = true;
          isSending = false;
          notifyListeners();
        } else if (regWiseData['resultcode'] == 3) {
          CommonMethods().showSnackBar(context, 'Please Login Again');
          regNumber = [];
          isImage = true;
          isSending = false;
          notifyListeners();
        } else {
          CommonMethods().showSnackBar(context, 'Something Went Wrong');
          regNumber = [];
          isImage = true;
          isSending = false;
          notifyListeners();
        }
      } else {
        // Handle errors here
        print("API call failed with status code: ${response.statusCode}");
        isImage = true;
        isSending = false;
        notifyListeners();
      }
    } catch (error) {
      // Handle network errors or exceptions here
      print("Error occurred: $error");
      isImage = true;
      notifyListeners();
    }
  }

  void addMatchingStudent(String name) {
    _matchingStudents.add(Student(name));

    notifyListeners();
  }

  void removeMatchingStudent(int index) {
    _matchingStudents.removeAt(index);
    regNumber.removeAt(index);

    notifyListeners();
  }

  // ignore: prefer_typing_uninitialized_variables
  var studentData;
  Future<void> getStudentRegWise(String regNo, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final schoolId = pref.getInt('schoolid') ?? 0;
    final sessionId = pref.getInt('sessionid') ?? 0;
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse(baseurl.toString() + hostService.getStudentByRegNo);
    final Map<String, dynamic> body = {
      "stm": {
        "StuId": null,
        "SchoolId": schoolId,
        "RegNo": regNo,
        "RollNo": "",
        "StuName": "",
        "gender": "",
        "FatherName": "",
        "DOB": "",
        "Category": "",
        "Address": "",
        "ContactNo": "",
        "ClassId": null,
        "ClassName": "",
        "SectionId": null,
        "SectionName": "",
        "SessionId": sessionId,
        "IsActive": true,
        "conveyance": "",
        "Stop": ""
      }
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

      if (response.statusCode == 200) {
        // Decode the response body
        final decodedData = GZipCodec().decode(response.bodyBytes);
        final data = utf8.decode(decodedData);
        final result = jsonDecode(data);

        if (result.containsKey("stm")) {
          // Assuming the response contains a student object under the key "stm"
          studentData = result["stm"];
          print(studentData);
          String studentName = studentData["StuName"];

          if (regNumber.contains(regNo)) {
            // If the number already exists in the list, show a message
            CommonMethods()
                .showSnackBar(context, 'Number $regNo is already entered');
          } else {
            // Add the number to the list
            regNumber.add(regNo);
            print(regNumber);

            // Continue with your existing code
            addMatchingStudent(studentName);
            notifyListeners();
          }
        } else {
          CommonMethods().showSnackBar(context, 'No match found');
        }
        notifyListeners();
      } else {
        // Handle errors here
        print("API call failed with status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle network errors or exceptions here
      print("Error occurred: $error");
    }
  }

  Future<void> teacherSmsPermission() async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final tid = pref.getInt("teacherId");
    print(tid);
    final url = Uri.parse('$baseurl${HostService().teacherPermissionUrl}');
    print(url);
    final body =
        jsonEncode({"tid": tid, "tname": "", "permission_name": "sms"});
    print(body);
    final headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8',
    };
    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        result = jsonDecode(response.body);
        print(result);
      } else {
        Container(
          child: Center(child: Text('Error:${response.statusCode}')),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<XFile?> compressImageCamera(XFile file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = "${tempDir.path}/temp.jpg";

      final Uint8List bytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image != null) {
        final img.Image resizedImage = img.copyResize(image, width: 800);

        final compressedImageBytes = img.encodeJpg(resizedImage, quality: 60);
        final compressedImageFile =
            XFile.fromData(compressedImageBytes, path: tempFilePath);

        return compressedImageFile;
      }

      return null;
    } catch (e) {
      print("Error compressing the image: $e");
      return null;
    }
  }
}
