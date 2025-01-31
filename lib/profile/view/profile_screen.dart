import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../utils/appcolors.dart';
import '../model/profile_model.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  String? selectedStudentPhotoUrl;
  bool tap = false;
  final String defaultPhoto =
      'https://www.flaticon.com/free-icon/profile_3135715';

  @override
  void initState() {
    super.initState();

    preference();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  String userType = '';
  void preference() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');

    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');
    userType = pref.getString('userType').toString();

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
  }

  void _showStudentList(BuildContext context, List<Stm> students) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Student',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (BuildContext context, int index) {
                final student = students[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 0),
                      dense: true,
                      leading: student.photo != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  NetworkImage(student.photo.toString()),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  AssetImage('assets/images/user_profile.png'),
                            ),
                      title: Text(
                        student.stuName ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      onTap: () {
                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void requiredData() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    final teacherContact = teacherInfo?.contactno ?? 'N/A';

    final student = userType == "Parent" ? studentProvider.profile : null;
    final selectedStudentIndex = studentProvider.selectedIndex;
    final students = student?.stm ?? [];
    final selectedStudentName = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].stuName ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentClass = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].className ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentRoll = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].rollNo ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentSection = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].sectionName ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentFather = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].fatherName ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentDob = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].dob != null
                ? students[selectedStudentIndex].dob!.length >= 11
                    ? students[selectedStudentIndex].dob!.substring(0, 11)
                    : students[selectedStudentIndex].dob!
                : 'N/A'
            : 'N/A'
        : null;

    final selectedStudentGender = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].gender ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentCategory = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].category ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentContact = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].contactNo ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentRegNo = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].regNo ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentConveyance = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].conveyance ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentAddress = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].address ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentPhoto = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].photo
            : null
        : null;

    final selectedStudentStop = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].stop ?? 'N/A'
            : 'N/A'
        : null;

    return studentProvider.isLoading || menuProvider.isLoading
        ? SizedBox(
            height: size.height,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Loading....',
                        style: TextStyle(
                            color: Colors.white, fontSize: size.width * 0.03),
                      ),
                      LoadingAnimationWidget.twistingDots(
                        leftDotColor: const Color(0xFFFAFAFA),
                        rightDotColor: const Color(0xFFEA3799),
                        size: size.width * 0.05,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 70,
              titleSpacing: 20,
              backgroundColor: Appcolor.themeColor,
              title: InkWell(
                onTap: () {
                  if (userType != "Teacher") {
                    _showStudentList(context, students);
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (userType != "Teacher") {
                            _showStudentList(context, students);
                          }
                        },
                        child: userType == "Teacher" || userType == "Admin"
                            ? menuProvider.fileExists
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Appcolor.lightgrey),
                                    child: teacherPhoto == null
                                        ? ClipOval(
                                            child: Image.asset(
                                              'assets/images/user_profile.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ) // Replace with your asset image path
                                        : ClipOval(
                                            child: menuProvider.isLoading
                                                ? const Center(
                                                    child:
                                                        CupertinoActivityIndicator(
                                                            color: Appcolor
                                                                .themeColor),
                                                  )
                                                : Image.network(
                                                    teacherPhoto,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      // Handle network image loading error here
                                                      return Image.asset(
                                                          'assets/images/user_profile.png'); // Replace with your error placeholder image
                                                    },
                                                  ),
                                          ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Appcolor.lightgrey),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/user_profile.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ))
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Appcolor.lightgrey),
                                child: selectedStudentPhoto != null
                                    ? ClipOval(
                                        child: Image.network(
                                          selectedStudentPhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            // Handle network image loading error here
                                            return Image.asset(
                                                'assets/images/user_profile.png'); // Replace with your error placeholder image
                                          },
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.asset(
                                          'assets/images/user_profile.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                userType == "Parent"
                                    ? 'Name: $selectedStudentName'
                                    : 'Name: $teacherName',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ),
                            Text(
                              userType == "Parent"
                                  ? 'Class: $selectedStudentClass'
                                  : 'Email:$teacherEmail',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            userType == "Parent"
                                ? Text(
                                    'Roll no: $selectedStudentRoll',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  )
                                : Text(
                                    'Contact: $teacherContact',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                            userType == "Parent"
                                ? Text(
                                    'Section: $selectedStudentSection',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Image.asset(
                    'assets/images/logo_bg.png',
                    height: size.height * 0.07,
                    width: size.width * 0.07,
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
                child: students.isNotEmpty
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          if (userType == "Parent")
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Student Personal details',
                                        style: TextStyle(
                                          color: Appcolor.themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        'Name: $selectedStudentName',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Class: $selectedStudentClass',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 18.0),
                                            child: Text(
                                              'Section: $selectedStudentSection',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Roll: $selectedStudentRoll',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Adm.no: $selectedStudentRegNo',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DOB: $selectedStudentDob',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      Text(
                                        'Father Name: $selectedStudentFather',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Contact: $selectedStudentContact',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Category: $selectedStudentCategory',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Gender: $selectedStudentGender',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'Address: $selectedStudentAddress',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      Text(
                                        selectedStudentConveyance!.isNotEmpty
                                            ? 'Conveyance: $selectedStudentConveyance'
                                            : 'Conveyance: N/A',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      const Divider(
                                        color: Appcolor.themeColor,
                                        thickness: 2,
                                      ),
                                      Text(
                                        selectedStudentStop != null
                                            ? 'Stop: $selectedStudentStop'
                                            : 'Stop: N/A',
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )
                    : userType == "Parent"
                        ? const Center(
                            child: Text('No student data available.'),
                          )
                        : const SizedBox.shrink()),
          );
  }
}
