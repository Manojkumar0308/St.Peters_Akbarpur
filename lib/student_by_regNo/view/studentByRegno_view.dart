// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/student_byRegNo_view_model.dart';

class StudentByRegNoScreen extends StatefulWidget {
  const StudentByRegNoScreen({super.key});

  @override
  State<StudentByRegNoScreen> createState() => _StudentByRegNoScreenState();
}

class _StudentByRegNoScreenState extends State<StudentByRegNoScreen> {
  TextEditingController regNoController = TextEditingController();
  bool isTap = false;

  CommonMethods commonMethods = CommonMethods();
  @override
  void initState() {
    super.initState();
    CommonMethods().initCall(context);
    final studentRegProvider =
        Provider.of<StudentBYRegViewModel>(context, listen: false);
    studentRegProvider.students = [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    final studentRegProvider = Provider.of<StudentBYRegViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Appcolor.themeColor,
        titleSpacing: 2,
        toolbarHeight: 70,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MenuScreen()));
                },
                icon: const Icon(Icons.arrow_back)),
            menuProvider.fileExists
                ? Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
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
                                    child: CupertinoActivityIndicator(
                                        color: Appcolor.themeColor),
                                  )
                                : Image.network(
                                    teacherPhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/user_profile.png',
                        fit: BoxFit.cover,
                      ),
                    )),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      'Name:$teacherName',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                  Text(
                    'Email: $teacherEmail',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Contact: $teacherContact',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
          ],
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                        controller: regNoController,
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
                      setState(() {
                        isTap = true;
                      });
                      String regNo = regNoController.text.toString();
                      if (regNo.isNotEmpty) {
                        await studentRegProvider
                            .getStudentsByFilter(regNoController.text);
                      }
                      regNoController.clear();
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
            studentRegProvider.isLoading
                ? Padding(
                    padding: const EdgeInsets.only(top: 50.0),
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
                : studentRegProvider.students.isEmpty
                    ? Center(
                        child: Text(
                          isTap ? 'No Record Found' : '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      )
                    : Flexible(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: studentRegProvider.students.length,
                          itemBuilder: (context, index) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        studentRegProvider.students[index]
                                                    ['photo'] !=
                                                null
                                            ? Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          Appcolor.themeColor,
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Image.network(
                                                    studentRegProvider
                                                        .students[index]
                                                            ['photo']
                                                        .toString(),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                          'assets/images/user_profile.png');
                                                    },
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child; // Image is fully loaded
                                                      } else {
                                                        return const Center(
                                                          child: CupertinoActivityIndicator(
                                                              color: Appcolor
                                                                  .themeColor),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Appcolor.themeColor,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(3.0),
                                                  child: Image.asset(
                                                    'assets/images/user_profile.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          'Name: ${studentRegProvider.students[index]['StuName'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                          thickness: 2,
                                        ),
                                        Text(
                                            'Father\'s Name: ${studentRegProvider.students[index]['FatherName'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                          thickness: 2,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                'Class: ${studentRegProvider.students[index]['ClassName'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                )),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('|'),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                'Section: ${studentRegProvider.students[index]['SectionName'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                            color: Appcolor.themeColor,
                                            thickness: 2),
                                        Text(
                                            'Adm.no: ${studentRegProvider.students[index]['RegNo'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                            color: Appcolor.themeColor,
                                            thickness: 2),
                                        Row(
                                          children: [
                                            Text(
                                                'Gender: ${studentRegProvider.students[index]['gender'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                )),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Text('|'),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                'Category: ${studentRegProvider.students[index]['Category'] ?? 'N/A'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                          thickness: 2,
                                        ),
                                        Text(
                                            'DOB: ${commonMethods.formatDate(studentRegProvider.students[index]['DOB'] ?? '')}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                          thickness: 2,
                                        ),
                                        Text(
                                            'Contact No: ${studentRegProvider.students[index]['ContactNo'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                          thickness: 2,
                                        ),
                                        Text(
                                            'Address: ${studentRegProvider.students[index]['Address'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                            color: Appcolor.themeColor,
                                            thickness: 2),
                                        Text(
                                            'Conveyance: ${studentRegProvider.students[index]['Conveyance'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        const Divider(
                                            color: Appcolor.themeColor,
                                            thickness: 2),
                                        Text(
                                            'Stop: ${studentRegProvider.students[index]['Stop'] ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
