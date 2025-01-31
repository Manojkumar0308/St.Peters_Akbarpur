import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/view/menu_screen.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../model/get_exam_model.dart';
import '../view_model/exam_result_viewmodel.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key});

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  TextEditingController controller = TextEditingController();
  Exam? selectedExam;
  int? examid;
  String? chosenExam;
  bool isTap = false;
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  bool isLoading = true;
  String? userType;
  String? attendanceStudentPhoto;
  String? attendanceStudentName;
  String? attendanceStudentClass;
  String? attendanceStudentRoll;
  String? attendanceRegNo;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;

  @override
  void initState() {
    super.initState();
    preference();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void preference() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType');

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');

    selectedName = pref.getString('attendanceStudentName');
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    selectedClass = pref.getString('attendanceStudentClass');
    selectedRoll = pref.getString('attendanceStudentRoll');

    attendanceRegNo = pref.getString('attendanceRegNo');

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    final examResultProvider =
        // ignore: use_build_context_synchronously
        Provider.of<ExamResultViewModel>(context, listen: false);
    examResultProvider.getExam();
    if (examResultProvider.selectedExamIndex <
        examResultProvider.exams.length) {
      final selectedExam =
          examResultProvider.exams[examResultProvider.selectedExamIndex];
      if (selectedExam != null) {
        examResultProvider.examResult(
            attendanceRegNo.toString(), selectedExam.examid);
      }
    }
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
                      splashColor: Appcolor.themeColor,
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
                        final pref = await SharedPreferences.getInstance();
                        //onTap particular student listtile first remove the previous stored data.
                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        pref.remove('classId');
                        pref.remove('sectionId');
                        /*after removing the following data by selecting student again following
                        details of a student is saving again in sharedPreferences */
                        pref.setString(
                            'attendanceRegNo', student.regNo.toString());
                        if (student.stuName != null) {
                          pref.setString('attendanceStudentName',
                              student.stuName.toString());
                        } else {
                          pref.setString('attendanceStudentName', 'N/A');
                        }

                        if (student.className != null) {
                          pref.setString('attendanceStudentClass',
                              student.className.toString());
                        } else {
                          pref.setString('attendanceStudentClass', 'N/A');
                        }

                        if (student.rollNo != null) {
                          pref.setString('attendanceStudentRoll',
                              student.rollNo.toString());
                        } else {
                          pref.setString('attendanceStudentRoll', 'N/A');
                        }

                        if (student.photo != null) {
                          pref.setString('attendanceStudentPhoto',
                              student.photo.toString());
                        }
                        // else {
                        //   pref.setString('attendanceStudentPhoto',
                        //       'https://source.unsplash.com/random/?city,night');
                        // }
                        pref.setInt('classId', student.classId!);
                        pref.setInt('sectionId', student.sectionId!);
                        selectedName = pref.getString('attendanceStudentName');
                        selectedPhoto =
                            pref.getString('attendanceStudentPhoto');
                        selectedClass =
                            pref.getString('attendanceStudentClass');
                        selectedRoll = pref.getString('attendanceStudentRoll');
                        attendanceRegNo = pref.getString('attendanceRegNo');
                        final examResultProvider =
                            // ignore: use_build_context_synchronously
                            Provider.of<ExamResultViewModel>(context,
                                listen: false);
                        examResultProvider.getExam();
                        if (examResultProvider.selectedExamIndex <
                            examResultProvider.exams.length) {
                          final selectedExam = examResultProvider
                              .exams[examResultProvider.selectedExamIndex];
                          if (selectedExam != null) {
                            examResultProvider.examResult(
                                attendanceRegNo.toString(),
                                selectedExam.examid);
                          }
                        }

                        // Notify the builder to rebuild the DataTable
                        setState(() {});

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        setState(() {
                          tap = true;
                          isLoading = true;
                        });

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final examResultProvider = Provider.of<ExamResultViewModel>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        titleSpacing: 2,
        backgroundColor: Appcolor.themeColor,
        title: InkWell(
          onTap: () {
            _showStudentList(context, students);
          },
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MenuScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back)),
                GestureDetector(
                  onTap: () {
                    _showStudentList(context, students);

                    setState(() {
                      tap = false;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: selectedPhoto == null
                        ? ClipOval(
                            child: Image.asset(
                              'assets/images/user_profile.png',
                              fit: BoxFit.cover,
                            ),
                          ) // Replace with your asset image path
                        : ClipOval(
                            child: Image.network(
                              selectedPhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle network image loading error here
                                return Image.asset(
                                    'assets/images/user_profile.png'); // Replace with your error placeholder image
                              },
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          selectedName != null
                              ? 'Name:$selectedName'
                              : 'Name:N/A',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                      Text(
                        selectedClass != null
                            ? 'Class:$selectedClass'
                            : 'Class:N/A',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      Text(
                        selectedRoll == null
                            ? 'Roll:N/A'
                            : 'Roll:$selectedRoll',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              ButtonTheme(
                layoutBehavior: ButtonBarLayoutBehavior.constrained,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                alignedDropdown: true,
                child: DropdownButtonFormField<Exam>(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Appcolor.themeColor, width: 2),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Appcolor.themeColor, width: 2),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  hint: const Text('Select exam'),
                  value: examResultProvider.exams.isNotEmpty
                      ? examResultProvider
                          .exams[examResultProvider.selectedExamIndex]
                      : null,
                  onChanged: (Exam? newIndex) async {
                    print('exam id is :${newIndex?.examid}');
                    if (newIndex != null) {
                      // Call the examResult method here with selected examid
                      await examResultProvider.examResult(
                          attendanceRegNo.toString(), newIndex.examid);

                      // Notify the builder to rebuild the DataTable
                      setState(() {});
                    }
                  },
                  items: examResultProvider.exams.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final Exam exam = entry.value;
                    return DropdownMenuItem<Exam>(
                      value: exam,
                      child: Text(exam.examname),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              examResultProvider.isLoading
                  ? Center(
                      child: Container(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Loading....',
                                style: TextStyle(color: Colors.white),
                              ),
                              LoadingAnimationWidget.twistingDots(
                                leftDotColor: const Color(0xFFFAFAFA),
                                rightDotColor: const Color(0xFFEA3799),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : examResultProvider.resultList.isEmpty
                      ? const Center(
                          child: Text(
                            'No Data Found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            width: size.width,
                            child: DataTable(
                              // columnSpacing: size.width * 0.10,
                              headingRowColor: MaterialStateColor.resolveWith(
                                (states) {
                                  return Colors.blueAccent;
                                },
                              ),
                              border: TableBorder.all(color: Colors.blueGrey),
                              columns: const [
                                DataColumn(label: Text('Subject')),
                                DataColumn(label: Text('MM')),
                                DataColumn(label: Text('Obt.Marks')),
                                // Add more DataColumn widgets as needed
                              ],
                              rows: examResultProvider.resultList.map((data) {
                                return DataRow(cells: [
                                  DataCell(
                                    Text(
                                      data['subject'] ?? 'N/A',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(
                                          data['Max.Marks']
                                                  .toStringAsFixed(0) ??
                                              'N/A',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Text(data['Obt.Marks'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  // Add more DataCell widgets as needed
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
