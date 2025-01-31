// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../student_by_regNo/view_model/student_byRegNo_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/leave_screen_viewmodel.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  List<bool> isIndexVisibleList = [];
  bool avatarTap = false;
  Map<String, List<Map<String, dynamic>>> studentDataMap = {};
  TextEditingController reasonController = TextEditingController();

  String? initfDate;
  String? inittDate;
  bool txt1 = false;
  bool txt2 = false;
  bool submit = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Appcolor.themeColor),
    );
    initialApiCall();
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  void initialApiCall() async {
    final pref = await SharedPreferences.getInstance();
    final schoolId = pref.getInt('schoolid');
    final userType = pref.getString('userType').toString();

    final sessionId = pref.getInt('sessionid');

    final mobno = pref.getString('mobno');
    if (userType == 'Parent') {
      //method called for to fetch student information present in StudentProvider provider class.
      final studentProvider =
          // ignore: use_build_context_synchronously
          Provider.of<StudentProvider>(context, listen: false);

      // ignore: use_build_context_synchronously
      studentProvider.fetchStudentData(
          mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    }
    // ignore: use_build_context_synchronously
    final provider = Provider.of<LeaveViewModel>(context, listen: false);

    provider.fDate = DateFormat('yyyyMMdd000000').format(provider.fromDate);
    provider.tDate = DateFormat('yyyyMMdd000000').format(provider.toDate);
    provider.parentinitialtoDate =
        DateFormat('yyyyMMdd000000').format(provider.parentToDate);
    inittDate = provider.parentinitialtoDate;
    provider.parentintitialFromDate =
        DateFormat('yyyyMMdd000000').format(provider.parentFromDate);
    initfDate = provider.parentintitialFromDate;

    await provider.getLeaveList(
        provider.fDate.toString(), provider.tDate.toString());
    isIndexVisibleList =
        List.generate(provider.getLeavelist?.length ?? 0, (index) => false);

    print(isIndexVisibleList);
  }

  Future<void> fetchStudentData(String regno) async {
    final studentRegProvider =
        Provider.of<StudentBYRegViewModel>(context, listen: false);

    // Fetch student data for the given "regno"
    await studentRegProvider.getStudentsByFilter(regno);

    // Store the fetched data in the studentDataMap
    studentDataMap[regno] = List.from(studentRegProvider.students);

    // Call setState to trigger a rebuild of the widget
    setState(() {});
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
                      onTap: () async {
                        setState(() {
                          // set the bool value to true.
                          avatarTap = true;
                          //calling selectstudent method from studentProvider class.
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        // for exit the dialog box

                        // ignore: use_build_context_synchronously
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

  DateTime _selectedToDate = DateTime.now();
  DateTime _selectedFromDate = DateTime.now();

  void _showDateFromPicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        txt1 = true;
        _selectedFromDate = selectedDate;
      });
    }
  }

  void _resetFromDate() {
    setState(() {
      _selectedFromDate = DateTime.now();
    });
  }

  String formattedSelectedFromDate() {
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(_selectedFromDate);
  }

  String selectedFromDateApiFormat() {
    final formatter = DateFormat('yyyyMMdd000000');
    return formatter.format(_selectedFromDate);
  }

  void _showDateToPicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        txt2 = true;
        _selectedToDate = selectedDate;
      });
    }
  }

  void _resetToDate() {
    setState(() {
      _selectedToDate = DateTime.now();
    });
  }

  String formattedSelectedToDate() {
    final formatter = DateFormat('MMMM dd, yyyy');
    return formatter.format(_selectedToDate);
  }

  String selectedToDateApiFormat() {
    final formatter = DateFormat('yyyyMMdd000000');
    return formatter.format(_selectedToDate);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final menuProvider = Provider.of<MenuViewModel>(context);
    final leaveListProvider = Provider.of<LeaveViewModel>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final selectedStudentIndex = studentProvider.selectedIndex;
    final students = student?.stm ?? [];
    final selectedStudentName = students.isNotEmpty
        ? students[selectedStudentIndex].stuName ?? 'N/A'
        : 'N/A';
    final selectedStudentClass = students.isNotEmpty
        ? students[selectedStudentIndex].className ?? 'N/A'
        : 'N/A';
    final selectedStudentSection = students.isNotEmpty
        ? students[selectedStudentIndex].sectionName ?? ''
        : 'N/A';
    final selectedStudentRoll = students.isNotEmpty
        ? students[selectedStudentIndex].rollNo ?? 'N/A'
        : 'N/A';

    final selectedStudentRegNo = students.isNotEmpty
        ? students[selectedStudentIndex].regNo ?? 'N/A'
        : 'N/A';
    final selectedStudentPhoto =
        students.isNotEmpty ? students[selectedStudentIndex].photo : null;

    if (leaveListProvider.userType == "Admin" ||
        leaveListProvider.userType == "Principal") {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Appcolor.themeColor,
            title: const Text(
              'Leave Screen',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              // menuProvider.bytesImage != null
              //     ? Padding(
              //         padding: const EdgeInsets.only(right: 15.0),
              //         child: Image.memory(
              //           menuProvider.bytesImage!,
              //           width: 30,
              //           height: 30,
              //         ),
              //       )
              //     : const SizedBox.shrink(),
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
          body: leaveListProvider.isLoading
              ? Center(
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
                                color: Colors.white,
                                fontSize: size.width * 0.03),
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
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'From: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Container(
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: DateFormat.yMMMMd()
                                            .format(leaveListProvider.fromDate),
                                      ),
                                      onTap: () {
                                        // isVisible = false;
                                        leaveListProvider
                                            .selectFromDate(context);
                                      },
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                          hintText: DateFormat.yMMMMd().format(
                                              leaveListProvider.fromDate),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'To: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Container(
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: DateFormat.yMMMMd()
                                            .format(leaveListProvider.toDate),
                                      ),
                                      onTap: () {
                                        // isVisible = true;
                                        leaveListProvider.selectToDate(context);
                                      },
                                      readOnly: true,
                                      decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 5),
                                          hintText: DateFormat.yMMMMd()
                                              .format(leaveListProvider.toDate),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      leaveListProvider.getLeavelist != null
                          ? Expanded(
                              child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      leaveListProvider.getLeavelist?.length ??
                                          0,
                                  itemBuilder: (_, index) {
                                    final regno = leaveListProvider
                                        .getLeavelist![index].regnno
                                        .toString();
                                    DateTime fDate = DateTime.parse(
                                        leaveListProvider
                                            .getLeavelist![index].fdate
                                            .toString());
                                    final formatFromDate =
                                        DateFormat.yMMMMd().format(fDate);
                                    DateTime tDate = DateTime.parse(
                                        leaveListProvider
                                            .getLeavelist![index].tdate
                                            .toString());
                                    final formattoDate =
                                        DateFormat.yMMMMd().format(tDate);
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                if (leaveListProvider
                                                            .getLeavelist !=
                                                        null &&
                                                    leaveListProvider
                                                        .getLeavelist!
                                                        .isNotEmpty) {
                                                  setState(() {
                                                    isIndexVisibleList[index] =
                                                        !isIndexVisibleList[
                                                            index];
                                                  });
                                                  if (isIndexVisibleList[
                                                      index]) {
                                                    await fetchStudentData(
                                                        regno.toString());
                                                  }
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      15.0),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                              'From: $formatFromDate'),
                                                          Text(
                                                              'To: $formattoDate'),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                              'Reason :'),
                                                          Expanded(
                                                            child: Text(
                                                                ' ${leaveListProvider.getLeavelist![index].reason ?? 'N/A'}'),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text('RegNo :'),
                                                          Expanded(
                                                            child: Text(
                                                                ' ${leaveListProvider.getLeavelist![index].regnno ?? 'N/A'}'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            isIndexVisibleList.isNotEmpty &&
                                                    isIndexVisibleList[index] ==
                                                        true
                                                ? Container(
                                                    height: 130,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        // color: Appcolor.themeColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: ListView.builder(
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              studentDataMap[
                                                                          regno]
                                                                      ?.length ??
                                                                  0,
                                                          itemBuilder:
                                                              (context, i) {
                                                            final student =
                                                                studentDataMap[
                                                                    regno]![i];
                                                            return SizedBox(
                                                              height: 120,
                                                              width: double
                                                                  .infinity,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  student['photo'] !=
                                                                          null
                                                                      ? Container(
                                                                          height:
                                                                              100,
                                                                          width:
                                                                              100,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(color: Appcolor.themeColor, width: 2),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(3.0),
                                                                            child:
                                                                                Image.network(
                                                                              student['photo'].toString(),
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder: (context, error, stackTrace) {
                                                                                return Image.asset('assets/images/user_profile.png');
                                                                              },
                                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                                if (loadingProgress == null) {
                                                                                  return child; // Image is fully loaded
                                                                                } else {
                                                                                  return const Center(
                                                                                    child: CupertinoActivityIndicator(color: Appcolor.themeColor),
                                                                                  );
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          height:
                                                                              100,
                                                                          width:
                                                                              100,
                                                                          decoration: BoxDecoration(
                                                                              border: Border.all(color: Appcolor.themeColor, width: 2),
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(3.0),
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/images/user_profile.png',
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  const SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 100,
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Text(
                                                                              'Name:',
                                                                              style: TextStyle(fontSize: 12),
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                ' ${student['StuName'] ?? 'N/A'}',
                                                                                style: const TextStyle(fontSize: 12),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text('Class: ${student['ClassName'] ?? 'N/A'}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                )),
                                                                            const SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                            Text('|  Section: ${student['SectionName'] ?? 'N/A'}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 12,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Text(
                                                                            'Contact: ${student['ContactNo'] ?? 'N/A'}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 12,
                                                                            )),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Row(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            const Text('Father\'s Name: ',
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                )),
                                                                            Expanded(
                                                                              child: Text('${student['FatherName'] ?? 'N/A'}',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                  )),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    );
                                  }),
                            )
                          : const Text('No data available'),
                    ],
                  ),
                ));
    } else if (leaveListProvider.userType == "Parent") {
      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 70,
            titleSpacing: 20,
            backgroundColor: Appcolor.themeColor,
            title: InkWell(
                onTap: () {
                  _showStudentList(context, students);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showStudentList(context, students);
                        },
                        child: Container(
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
                                    errorBuilder: (context, error, stackTrace) {
                                      // Handle network image loading error here
                                      return Image.asset(
                                          'assets/images/user_profile.png'); // Replace with your error placeholder image
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return const Center(
                                          child: CupertinoActivityIndicator(
                                              color: Appcolor.themeColor),
                                        );
                                      }
                                    },
                                  ),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                  'assets/images/user_profile.png',
                                  fit: BoxFit.cover,
                                )),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: $selectedStudentName',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            Text(
                              'Class: $selectedStudentClass $selectedStudentSection',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            Text(
                              'Roll: $selectedStudentRoll',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
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
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'From: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            GestureDetector(
                              onTap: _showDateFromPicker,
                              child: Container(
                                width: size.width,
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  formattedSelectedFromDate(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'To: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            GestureDetector(
                              onTap: _showDateToPicker,
                              child: Container(
                                width: size.width,
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  formattedSelectedToDate(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  color: Appcolor.lightgrey,
                  child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: "Enter text here...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                      ),
                      contentPadding: EdgeInsets.only(
                          left: 15, right: 15.0, top: 15, bottom: 15),
                      border: InputBorder.none,
                    ),
                    controller: reasonController,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                    onTap: () async {
                      String selectedToDate = selectedToDateApiFormat();
                      String selectedFromDate = selectedFromDateApiFormat();
                      print('selectedToDate value is:$selectedToDate');
                      _resetToDate();
                      _resetFromDate();
                      studentProvider.resetSelectedStudentIndex();
                      setState(() {
                        submit = true;
                        txt1 = false;
                        txt2 = false;
                      });

                      if (reasonController.text.isNotEmpty) {
                        // ignore: unrelated_type_equality_checks
                        if (txt1 == true &&
                            leaveListProvider.picked != null &&
                            // ignore: unrelated_type_equality_checks
                            leaveListProvider.picked != initfDate) {
                          await leaveListProvider.addLeave(
                              selectedFromDate,
                              selectedToDate,
                              selectedStudentRegNo,
                              reasonController.text,
                              context);
                          // ignore: unrelated_type_equality_checks
                        } else if (txt2 == true) {
                          await leaveListProvider.addLeave(
                              selectedFromDate,
                              selectedToDate.toString(),
                              selectedStudentRegNo,
                              reasonController.text,
                              context);
                        } else if (txt1 == true && txt2 == true) {
                          await leaveListProvider.addLeave(
                              selectedFromDate,
                              selectedToDate.toString(),
                              selectedStudentRegNo,
                              reasonController.text,
                              context);
                        } else {
                          await leaveListProvider.addLeave(
                              selectedFromDate,
                              selectedToDate,
                              selectedStudentRegNo,
                              reasonController.text,
                              context);
                        }
                        reasonController.clear();
                      } else {
                        CommonMethods()
                            .showSnackBar(context, "Field can't be empty");
                      }
                    },
                    child: Container(
                        width: size.width * 0.25,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Appcolor.themeColor),
                        child: const Center(
                            child: Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )))),
              ],
            ),
          ));
    } else {
      return Container();
    }
  }
}
