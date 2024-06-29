import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../login/view/login_screen.dart';
import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../view_model/online_payment_viewmodel.dart';

class OnlinePaymentScreen extends StatefulWidget {
  const OnlinePaymentScreen({super.key});

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
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
  int? stuId;
  int? classId;
  double amount = 0.0;
  String addedInterval = '';
  int selectedIndex = -1;
  List<String> selectedUnpaidIntervals = [];
  List<String> setValues = [];
  String? stringList;
  String? newStringList;
  double cu_amt = 0.0;
  static MethodChannel channel = const MethodChannel("easebuzz");

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
                        setValues = [];
                        cu_amt = 0.0;
                        final pref = await SharedPreferences.getInstance();
                        //onTap particular student listtile first remove the previous stored data.
                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        pref.remove('classId');
                        pref.remove('sectionId');
                        pref.remove('StuId');
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
                        if (student.stuId != null) {
                          pref.setInt('StuId', student.stuId!);
                        } else {
                          pref.setInt('StuId', 0);
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
                        stuId = pref.getInt('StuId');
                        classId = pref.getInt('classId');

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        setState(() {
                          tap = true;
                          isLoading = true;
                        });
                        final onlinepaymentProviders =
                            // ignore: use_build_context_synchronously
                            Provider.of<OnlinePaymentViewModel>(context,
                                listen: false);
                        if (stuId != null && sessionId != null) {
                          // ignore: use_build_context_synchronously
                          onlinepaymentProviders.onlineFeeDetail(context,
                              attendanceRegNo.toString(), stuId!, sessionId!);
                          // ignore: use_build_context_synchronously
                          onlinepaymentProviders.getGateWayDetail(context);
                        }

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
    stuId = pref.getInt('StuId');
    print('student id is :$stuId');
    print('session id is :$sessionId');

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    final onlinepaymentProviders =
        // ignore: use_build_context_synchronously
        Provider.of<OnlinePaymentViewModel>(context, listen: false);
    if (stuId != null && sessionId != null) {
      addedInterval = '';
      // ignore: use_build_context_synchronously
      onlinepaymentProviders.onlineFeeDetail(
          context, attendanceRegNo.toString(), stuId!, sessionId!);
      // ignore: use_build_context_synchronously
      onlinepaymentProviders.getGateWayDetail(context);
    }
  }

  @override
  void initState() {
    preference();

    super.initState();
  }

  int selectedRowIndex = -1;
  bool selectedContainer = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    final onlinepaymentProviders =
        // ignore: use_build_context_synchronously
        Provider.of<OnlinePaymentViewModel>(context);
    return Scaffold(
        backgroundColor: Appcolor.lightgrey,
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
                      // setValues = [];
                      // cu_amt = 0.0;
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
                                  return ClipOval(
                                    child: Image.asset(
                                        'assets/images/user_profile.png'),
                                  ); // Replace with your error placeholder image
                                },
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
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
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: size.width * 0.03),
                            ),
                          ),
                          Text(
                            selectedClass != null
                                ? 'Class:$selectedClass'
                                : 'Class:N/A',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03),
                          ),
                          Text(
                            selectedRoll == null
                                ? 'Roll:N/A'
                                : 'Roll:$selectedRoll',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Center(
                  child: Text(
                'Prev Bal: \u20B9${onlinepaymentProviders.isLoading ? 0.0 : onlinepaymentProviders.data["prev_bal"]}',
                style: TextStyle(
                    fontSize: size.width * 0.03, fontWeight: FontWeight.bold),
              )),
              // menuProvider.bytesImage != null
              //     ? Image.memory(
              //         menuProvider.bytesImage!,
              //         height: size.height * 0.08,
              //         width: size.width * 0.08,
              //       )
              //     : const SizedBox.shrink(),
            ),
          ],
        ),
        bottomNavigationBar: InkWell(
          child: Container(
            height:
                setValues.isNotEmpty ? size.height * 0.08 : size.height * 0.07,
            color: setValues.isNotEmpty ? Appcolor.lightgrey : Colors.grey,
            child: setValues.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Container(
                            child: Row(
                              children: [
                                Text(
                                  setValues.isNotEmpty ? ' \u20B9' : '',
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  setValues.isNotEmpty ? '$cu_amt' : '',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            height: size.height,
                            width: 1.2,
                            color: Colors.grey,
                          ),
                        ),
                        // Image.asset(
                        //   'assets/images/star.png',
                        //   height: 18,
                        //   width: 18,
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Container(
                            child: const Text(
                                'Note: Platform charges will be applied *',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            height: size.height,
                            width: 1.2,
                            color: Colors.grey,
                          ),
                        ),

                        Flexible(
                          child: InkWell(
                            onTap: () async {
                              final pref =
                                  await SharedPreferences.getInstance();
                              if (onlinepaymentProviders
                                      .decodedResponse['resultcode'] ==
                                  0) {
                                Fluttertoast.showToast(
                                    msg: "Please Login Again",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 12.0);
                                pref.clear();

                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                );
                              } else {
                                if (setValues.isNotEmpty) {
                                  print('newstringList is $newStringList');
                                  // ignore: use_build_context_synchronously
                                  await onlinepaymentProviders.getTransactionId(
                                      context, stringList.toString(), cu_amt);
                                  // ignore: use_build_context_synchronously
                                  await onlinepaymentProviders.initiatePayment(
                                      cu_amt, selectedName.toString(), context);
                                  if (onlinepaymentProviders
                                              .detailedResponse["status"] ==
                                          "success" ||
                                      onlinepaymentProviders
                                              .detailedResponse["status"] ==
                                          "failure") {
                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      onlinepaymentProviders
                                          .getResponseOnlineTransaction(
                                              onlinepaymentProviders
                                                  .detailedResponse["status"]
                                                  .toString(),
                                              onlinepaymentProviders
                                                  .detailedResponse["txnid"]
                                                  .toString(),
                                              newStringList.toString(),
                                              onlinepaymentProviders
                                                  .detailedResponse["easepayid"]
                                                  .toString(),
                                              onlinepaymentProviders
                                                  .detailedResponse[
                                                      "bank_ref_num"]
                                                  .toString(),
                                              double.parse(onlinepaymentProviders
                                                  .detailedResponse["amount"]),
                                              onlinepaymentProviders
                                                  .detailedResponse["bankcode"]
                                                  .toString(),
                                              onlinepaymentProviders
                                                  .detailedResponse["status"]
                                                  .toString(),
                                              onlinepaymentProviders
                                                  .detailedResponse["hash"]);
                                    });
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please select month",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 12.0);
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Container(
                                height: size.height * 0.05,
                                width: size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: Appcolor.sliderGradient),
                                child: const Center(
                                  child: Text(
                                    'Pay',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Pay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: onlinepaymentProviders.isLoading
                ? SizedBox(
                    height: size.height,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
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
                      ],
                    ),
                  )
                : onlinepaymentProviders.responseData.isEmpty ||
                        onlinepaymentProviders.data == null ||
                        onlinepaymentProviders.data.isEmpty
                    ? SizedBox(
                        height: size.height,
                        child: const Center(
                          child: Text(
                            'No Data Found',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                onlinepaymentProviders.responseData.length,
                            itemBuilder: (_, index) {
                              final interval =
                                  onlinepaymentProviders.responseData[index];

                              // Check if the interval is paid
                              bool isPaid = interval['paid'];

                              // Check if the interval is selected
                              bool isSelected =
                                  setValues.contains(interval['interval']);

                              print(onlinepaymentProviders.responseData.length);
                              print(onlinepaymentProviders
                                  .selectedCardCheckboxes.length);
                              if (onlinepaymentProviders
                                      .selectedCardCheckboxes.isEmpty ||
                                  index >=
                                      onlinepaymentProviders
                                          .selectedCardCheckboxes.length) {
                                print(
                                    'selectedCardCheckboxes is empty or index is out of bounds');
                                return const SizedBox
                                    .shrink(); // or return an empty widget
                              }

                              print(
                                  'selectedCardCheckboxes[$index]: ${onlinepaymentProviders.selectedCardCheckboxes[index]}');
                              return onlinepaymentProviders.responseData[index]
                                          ['interval'] ==
                                      ""
                                  ? Container()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Card(
                                            margin: EdgeInsets.zero,
                                            elevation: 5,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Container(
                                              height: size.height * 0.16,
                                              width: size.width * 0.25,
                                              decoration: BoxDecoration(
                                                  gradient: onlinepaymentProviders
                                                                  .responseData[
                                                              index]['paid'] ==
                                                          true
                                                      ? Appcolor.sliderGradient
                                                      : Appcolor.redGradient,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.0,
                                                        vertical: 2.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Month',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: size.width *
                                                              0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      onlinepaymentProviders
                                                              .responseData[
                                                          index]['interval'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize:
                                                              size.width * 0.03,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                setValues = [];
                                                setState(() {
                                                  onlinepaymentProviders
                                                          .selectedCardCheckboxes[
                                                      index] = !onlinepaymentProviders
                                                          .selectedCardCheckboxes[
                                                      index];

                                                  if (onlinepaymentProviders
                                                          .selectedCardCheckboxes[
                                                      index]) {
                                                    cu_amt =
                                                        onlinepaymentProviders
                                                                .responseData[
                                                            index]['Cu_amount'];
                                                    // Add all unpaid intervals before the selected one
                                                    for (int i = 0;
                                                        i <= index;
                                                        i++) {
                                                      if (!onlinepaymentProviders
                                                              .responseData[i]
                                                          ['paid']) {
                                                        setValues.add(
                                                            onlinepaymentProviders
                                                                    .responseData[
                                                                i]['interval']);
                                                      }
                                                    }
                                                  } else {
                                                    setState(() {
                                                      for (int i = 0;
                                                          i <=
                                                              onlinepaymentProviders
                                                                  .responseData
                                                                  .length;
                                                          i++) {
                                                        if (i <
                                                                onlinepaymentProviders
                                                                    .selectedCardCheckboxes
                                                                    .length &&
                                                            !onlinepaymentProviders
                                                                    .responseData[
                                                                i]['paid']) {
                                                          onlinepaymentProviders
                                                                  .selectedCardCheckboxes[
                                                              i] = false;
                                                          setValues = [];
                                                        }
                                                        setValues = [];
                                                      }
                                                    });
                                                    // Remove all intervals above the selected one
                                                  }

                                                  // Remove duplicates
                                                  setValues = setValues
                                                      .toSet()
                                                      .toList();
                                                  print(setValues);

                                                  // Convert to a comma-separated string
                                                  stringList =
                                                      setValues.join(",");

                                                  print(
                                                      'stringList is $stringList');
                                                  newStringList =
                                                      "${stringList},";
                                                  print(
                                                      'newstringList is $newStringList');
                                                });
                                              },
                                              child: Card(
                                                margin: EdgeInsets.zero,
                                                elevation: 5,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: Container(
                                                  clipBehavior: Clip.none,
                                                  height: size.height * 0.16,
                                                  decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? Colors.amber
                                                          : Colors.white,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10),
                                                              topRight: Radius
                                                                  .circular(
                                                                      10))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Monthly Amount:',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .lightBlue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                                child: Text(
                                                                    ' \u20B9${onlinepaymentProviders.responseData[index]['amount']}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            size.width *
                                                                                0.028,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Image.asset(
                                                              'assets/images/money.png',
                                                              height: 30,
                                                              width: 30,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'Amount to be Paid:',
                                                          style: TextStyle(
                                                              fontSize:
                                                                  size.width *
                                                                      0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      gradient:
                                                                          Appcolor
                                                                              .pinkGradient,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child: Center(
                                                                    child: Text(
                                                                        ' \u20B9${onlinepaymentProviders.responseData[index]['Cu_amount']}',
                                                                        style: TextStyle(
                                                                            fontSize: size.width *
                                                                                0.028,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              Text('Status: ',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          size.width *
                                                                              0.03,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    gradient: onlinepaymentProviders.responseData[index]['paid'] ==
                                                                            true
                                                                        ? Appcolor
                                                                            .sliderGradient
                                                                        : Appcolor
                                                                            .redGradient,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          2.0),
                                                                  child: Text(
                                                                      onlinepaymentProviders.responseData[index]['paid'] ==
                                                                              true
                                                                          ? 'Paid'
                                                                          : 'Unpaid',
                                                                      style: TextStyle(
                                                                          fontSize: size.width *
                                                                              0.028,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
          ),
        ));
  }
}
