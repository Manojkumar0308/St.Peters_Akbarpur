import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../Exam_result/model/get_exam_model.dart';
import '../../../Exam_result/view_model/exam_result_viewmodel.dart';
import '../../../menu/view_model/menu_view_model.dart';
import '../../../student_by_regNo/view_model/student_byRegNo_view_model.dart';
import '../../../utils/appcolors.dart';
import '../../../utils/common_methods.dart';
import '../view_model/view_model.dart';

class GetStudentByFilterAdmin extends StatefulWidget {
  const GetStudentByFilterAdmin({super.key});

  @override
  State<GetStudentByFilterAdmin> createState() =>
      _GetStudentByFilterAdminState();
}

class _GetStudentByFilterAdminState extends State<GetStudentByFilterAdmin> {
  TextEditingController regNoTextController = TextEditingController();
  CarouselController carouselController = CarouselController();
  int currentIndex = 0;
  bool isTap = false;
  bool isDropTap = false;

  @override
  void initState() {
    super.initState();
    CommonMethods().initCall(context);
    final studentRegProvider =
        Provider.of<StudentBYRegViewModel>(context, listen: false);
    studentRegProvider.students = [];
    final studentFilterByAdmin =
        Provider.of<GetStudentByRegNoAdmin>(context, listen: false);
    studentFilterByAdmin.fetchStudentDetail(regNoTextController.text);
    final examResultProvider =
        Provider.of<ExamResultViewModel>(context, listen: false);
    examResultProvider.getExam();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuViewModel>(context);
    final studentFilterByAdmin = Provider.of<GetStudentByRegNoAdmin>(context);
    final size = MediaQuery.of(context).size;
    final examResultProvider = Provider.of<ExamResultViewModel>(context);
    final selectedExam =
        examResultProvider.selectedExamIndex < examResultProvider.exams.length
            ? examResultProvider.exams[examResultProvider.selectedExamIndex]
            : null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolor.themeColor,
        leadingWidth: 30,
        title: const Text(
          'Student by RegNo',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.blueGrey),
                        color: Colors.white70,
                      ),
                      child: TextField(
                        controller: regNoTextController,
                        decoration: const InputDecoration(
                          hintText: "Enter registration number...",
                          hintStyle: TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Appcolor.themeColor,
                    ),
                    onPressed: () async {
                      isTap = true;
                      String regNo = regNoTextController.text.toString();
                      if (regNo.isNotEmpty) {
                        await studentFilterByAdmin
                            .fetchStudentDetail(regNoTextController.text);
                        if (selectedExam?.examid != null) {
                          await examResultProvider.examResult(
                              regNoTextController.text, selectedExam!.examid);
                        }
                      }
                    },
                    child: const Text(
                      "Search",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            studentFilterByAdmin.isStudentDataLoading
                ? Container()
                : const SizedBox(
                    height: 10,
                  ),
            studentFilterByAdmin.isStudentDataLoading
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
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: ClipOval(
                              child: studentFilterByAdmin.student?.sp?.photo !=
                                      null
                                  ? Image.network(
                                      studentFilterByAdmin.student!.sp?.photo,
                                      fit: BoxFit.cover,
                                    )
                                  : ClipOval(
                                      child: Image.asset(
                                          'assets/images/user_profile.png',
                                          fit: BoxFit.cover),
                                    )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Name:',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Expanded(
                                      child: Text(
                                        studentFilterByAdmin
                                                .student?.sp?.stuName ??
                                            'N/A',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Class:${studentFilterByAdmin.student?.sp?.className ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      '|',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    studentFilterByAdmin
                                                .student?.sp?.sectionName !=
                                            null
                                        ? Text(
                                            'Section:${studentFilterByAdmin.student!.sp?.sectionName}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : const Text(
                                            'Section:N/A',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    studentFilterByAdmin.student?.sp?.rollNo !=
                                            null
                                        ? Text(
                                            'Roll:${studentFilterByAdmin.student!.sp?.rollNo}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : const Text(
                                            'Roll:N/A',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      '|',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    studentFilterByAdmin.student?.sp?.regNo !=
                                            null
                                        ? Text(
                                            'Adm.no:${studentFilterByAdmin.student!.sp?.regNo}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : const Text(
                                            'Adm.no:N/A',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ],
                                ),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                studentFilterByAdmin.student?.sp?.gender != null
                                    ? Text(
                                        'Gender:${studentFilterByAdmin.student?.sp?.gender}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold))
                                    : const Text('Gender:N/A',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: size.height * 0.12,
                    // width: size.width * 0.25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.red),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Admission Date',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                              studentFilterByAdmin
                                          .student?.sp?.firstadmissiondate !=
                                      null
                                  ? '${studentFilterByAdmin.student?.sp?.firstadmissiondate?.substring(0, 11)}'
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: size.height * 0.12,
                    // width: size.width * 0.25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Admission Class',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                              studentFilterByAdmin
                                          .student?.sp?.firstadmissionclass !=
                                      null
                                  ? '${studentFilterByAdmin.student?.sp?.firstadmissionclass}'
                                  : 'N/A',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Other Details:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey),
                children: [
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Father's Name:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.fatherName ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Father's Occupation
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Father's Occupation:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.foccupation ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Father's Qualification
                  if (studentFilterByAdmin.student?.sp?.fqualification != null)
                    TableRow(
                      children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Father's Qualification:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              studentFilterByAdmin
                                      .student?.sp?.fqualification ??
                                  'N/A',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // Mother's Name
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Mother's Name:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.mothername ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Mother's Occupation
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Mother's Occupation:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.moccupation ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Mother's Qualification
                  if (studentFilterByAdmin.student?.sp?.mqualification != null)
                    TableRow(
                      children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Mother's Qualification:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              studentFilterByAdmin
                                      .student?.sp?.mqualification ??
                                  'N/A',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Contact No
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Contact No:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.contactNo ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Alt Contact
                  if (studentFilterByAdmin.student?.sp?.altcontact != null &&
                      studentFilterByAdmin.student?.sp?.altcontact != "0")
                    TableRow(
                      children: [
                        const TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Alt Contact:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              studentFilterByAdmin.student?.sp?.altcontact ??
                                  'N/A',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // DOB
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "DOB:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.dob
                                    ?.substring(0, 11) ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Category
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Category:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.category ?? 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // House
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "House:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.house ?? 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Address

                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Address:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.address ?? 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Postal Address
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Postal Address:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.postaladdress ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Conveyance
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Conveyance:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.conveyance ??
                                'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  //Stop
                  TableRow(
                    children: [
                      const TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Stop:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            studentFilterByAdmin.student?.sp?.stop ?? 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
            //   child: Container(
            //     width: size.width,
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(10),
            //         color: Appcolor.lightgrey),
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           studentFilterByAdmin.student?.sp?.fatherName != null
            //               ? Text(
            //                   "Father's Name:${studentFilterByAdmin.student?.sp?.fatherName}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Father's Name:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.foccupation != null
            //               ? Text(
            //                   "Father's Occupation:${studentFilterByAdmin.student?.sp?.foccupation}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Father's Occupation: N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.fqualification != null
            //               ? Text(
            //                   "Father's Qaulification:${studentFilterByAdmin.student?.sp?.fqualification}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const SizedBox.shrink(),
            //           studentFilterByAdmin.student?.sp?.fqualification != null
            //               ? const Divider(
            //                   color: Colors.grey,
            //                 )
            //               : const SizedBox.shrink(),
            //           studentFilterByAdmin.student?.sp?.mothername != null
            //               ? Text(
            //                   "Mother's Name:${studentFilterByAdmin.student?.sp?.mothername}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Mother's Name:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.moccupation != null &&
            //                   studentFilterByAdmin.student?.sp?.moccupation !=
            //                       ""
            //               ? Text(
            //                   "Mother's Occupation:${studentFilterByAdmin.student?.sp?.moccupation}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Mother's Occupation: N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.mqualification != null
            //               ? Text(
            //                   "Mother's Qaulification:${studentFilterByAdmin.student?.sp?.mqualification}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const SizedBox.shrink(),
            //           studentFilterByAdmin.student?.sp?.contactNo != null
            //               ? Text(
            //                   "Contact No:${studentFilterByAdmin.student?.sp?.contactNo}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Contact No:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.altcontact != null &&
            //                   studentFilterByAdmin.student?.sp?.altcontact !=
            //                       "0"
            //               ? Text(
            //                   "Alt Contact:${studentFilterByAdmin.student?.sp?.altcontact}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const SizedBox.shrink(),
            //           studentFilterByAdmin.student?.sp?.altcontact != null &&
            //                   studentFilterByAdmin.student?.sp?.altcontact !=
            //                       "0"
            //               ? const Divider(
            //                   color: Colors.grey,
            //                 )
            //               : const SizedBox.shrink(),
            //           studentFilterByAdmin.student?.sp?.dob != null
            //               ? Text(
            //                   studentFilterByAdmin.student!.sp!.dob
            //                               .toString()
            //                               .length >=
            //                           11
            //                       ? "DOB: ${studentFilterByAdmin.student?.sp?.dob?.substring(0, 11)}"
            //                       : 'DOB:N/A',
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("DOB:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.category != null
            //               ? Text(
            //                   "Category:${studentFilterByAdmin.student?.sp?.category}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Category:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.house != null
            //               ? Text(
            //                   "House:${studentFilterByAdmin.student?.sp?.house}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("House:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.address != null
            //               ? Text(
            //                   "Address:${studentFilterByAdmin.student?.sp?.address}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Address:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.postaladdress != null
            //               ? Text(
            //                   "Postal Address:${studentFilterByAdmin.student?.sp?.postaladdress}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Postal Address:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.conveyance != null
            //               ? Text(
            //                   "Conveyance:${studentFilterByAdmin.student?.sp?.conveyance}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Conveyance:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //           studentFilterByAdmin.student?.sp?.stop != null
            //               ? Text(
            //                   "Stop:${studentFilterByAdmin.student?.sp?.stop}",
            //                   style: const TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold),
            //                 )
            //               : const Text("Stop:N/A",
            //                   style: TextStyle(
            //                       fontSize: 14, fontWeight: FontWeight.bold)),
            //           const Divider(
            //             color: Colors.grey,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Exam Result:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(height: 20),
            isTap
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ButtonTheme(
                      layoutBehavior: ButtonBarLayoutBehavior.constrained,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      alignedDropdown: true,
                      child: StatefulBuilder(builder: (context, setState) {
                        return DropdownButtonFormField<Exam>(
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
                                  regNoTextController.text, newIndex.examid);

                              // Notify the builder to rebuild the DataTable
                              setState(() {});
                            }
                          },
                          items: examResultProvider.exams
                              .asMap()
                              .entries
                              .map((entry) {
                            final int index = entry.key;
                            final Exam exam = entry.value;
                            return DropdownMenuItem<Exam>(
                              value: exam,
                              child: Text(exam.examname),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  )
                : const SizedBox.shrink(),
            isTap ? const SizedBox(height: 20) : const SizedBox.shrink(),
            isTap
                ? examResultProvider.isLoading
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
                    : examResultProvider.resultList.isEmpty
                        ? SizedBox(
                            height: size.height * 0.15,
                            child: const Center(
                              child: Text(
                                'No Data Found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
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
                                  ]);
                                }).toList(),
                              ),
                            ),
                          )
                : const SizedBox.shrink(),
            isTap || isDropTap
                ? const SizedBox(height: 20)
                : const SizedBox.shrink(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                'Student Fee Profile:',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            studentFilterByAdmin.student?.sfp != null &&
                    studentFilterByAdmin.student!.sfp!.isNotEmpty
                ? Column(
                    children: [
                      SizedBox(
                        height: size.width * 0.32,
                        width: size.width,
                        child: CarouselSlider(
                          carouselController: carouselController,
                          items: studentFilterByAdmin.student?.sfp?.map((item) {
                            final dt = CommonMethods()
                                .teachersHomeworkreportDate(item.dt.toString());

                            return Container(
                              // height: size.height * 0.04,
                              width: size.width * 0.75,
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: Appcolor.sliderGradient),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    dt.isNotEmpty ? "Date: $dt" : "Date:N/A",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "Interval: ${item.interval}",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    item.amount != null ||
                                            item.amount.toString().isNotEmpty
                                        ? "Amount: ${item.amount}"
                                        : "Amount: N/A",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          options: CarouselOptions(
                            aspectRatio: 16 /
                                9, // You can adjust this aspect ratio as needed
                            enlargeCenterPage: true,
                            viewportFraction: 0.8,

                            initialPage: 0,
                            enableInfiniteScroll:
                                false, // Set to true for infinite scrolling
                            autoPlay:
                                true, // Set to true for automatic slideshow
                            autoPlayInterval: const Duration(
                                seconds: 3), // Duration between slides
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            // Animation duration
                            onPageChanged: (index, reason) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex == index
                                  ? Colors.green // Active dot color
                                  : Colors.grey, // Inactive dot color
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 50,
                    child: Center(
                      child: Text('No student fee profile available'),
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                  height: size.height * 0.10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Due Fee',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      studentFilterByAdmin.student?.sduefee != null
                          ? Text(
                              '\u{20B9}${studentFilterByAdmin.student!.sduefee ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : const Text(
                              'N/A',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
