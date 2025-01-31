// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/view_model/menu_view_model.dart';
import '../../utils/appcolors.dart';
import '../view_model/send_message_view_model.dart';
import 'package:intl/intl.dart';

class SendMessageScreen extends StatefulWidget {
  // final List<PlatformFile>? files;
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  TextEditingController messageController = TextEditingController();
  bool isCamera = false;
  File? imageCamera;
  String? base64ImageCamera;
  String? fileType;
  String? mobno;
  String? className;
  String? sectionName;
  String? singleSelectedClassName;
  String? singleSelectedSectionName;
  List<String> registrationNumbers = [];
  List<TextEditingController> registrationTextControllers = [];
  TextEditingController sendToAllController = TextEditingController();
  TextEditingController multiClassController = TextEditingController();
  TextEditingController classWiseController = TextEditingController();
  TextEditingController regWiseController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  List<CameraDescription> camera = [];
  late CameraController _controller;
  late Future<void>? _initializeControllerFuture;
  bool _isRearCameraSelected = true;
  XFile? picture;
  bool cameraCliked = false;

  Future initCamera(CameraDescription cameraDescription) async {
// create a CameraController
    _controller = CameraController(cameraDescription, ResolutionPreset.high);
// Next, initialize the controller. This returns a Future.
    try {
      await _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  void initState() {
    super.initState();

    // Check if camera is not null and not empty
    initCall();
    // Check if camera is not null and not empty
    if (camera.isNotEmpty) {
      // Initialize _controller before calling initCamera

      // Initialize the camera
      initCamera(camera[0]);
    } else {
      print('Error: Camera list is empty or not initialized.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? userType;

  void initCall() async {
    camera = await availableCameras();
    _controller = CameraController(camera[0], ResolutionPreset.high);
    await _controller.initialize();

    final pref = await SharedPreferences.getInstance();
    userType = pref.getString('userType').toString();
    mobno = pref.getString('mobno');
    print(mobno);

    //method called for to fetch teacher information present in MenuViewModel provider class.

    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    menuProvider.fetchTeacherInfo(mobno.toString());
    if (menuProvider.teacherInfo?.photo != null) {
      menuProvider
          .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SendMessageViewModel>(context);
    final showingDate = DateFormat.yMMMEd().format(DateTime.now());
    DateTime currentDate = DateTime.now();
    String editableDate = currentDate.toString().split('.').first;
    final formattedDate = editableDate.replaceAll(RegExp(r'[- :.]'), '');
    final size = MediaQuery.of(context).size;
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Appcolor.themeColor,
        toolbarHeight: 70,
        titleSpacing: 2,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            userType == "Teacher" || userType == "Admin"
                ? menuProvider.fileExists
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                        ))
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
      body: isCamera
          ? Stack(
              children: [
                if (_controller != null && _controller.value.isInitialized)
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: CameraPreview(_controller),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: size.width,
                      height: MediaQuery.of(context).size.height * 0.15,
                      decoration: const BoxDecoration(
                          // borderRadius:
                          //     BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 30,
                              icon: Icon(
                                  _isRearCameraSelected
                                      ? CupertinoIcons.switch_camera
                                      : CupertinoIcons.switch_camera_solid,
                                  color: Colors.white),
                              onPressed: () {
                                setState(() => _isRearCameraSelected =
                                    !_isRearCameraSelected);
                                initCamera(
                                    camera[_isRearCameraSelected ? 0 : 1]);
                              },
                            )),
                            Expanded(
                                child: IconButton(
                              onPressed: takePicture,
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon:
                                  const Icon(Icons.circle, color: Colors.white),
                            )),
                            const Spacer(),
                          ]),
                    )),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Today\'s Date- ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  showingDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Please select the option for sending notifications -',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Checkbox(
                                      value: provider.sendToAll,
                                      onChanged: (value) {
                                        provider.setSendToAll(value ?? false);
                                        setState(() {
                                          provider.resetFileTypeAndContent();
                                        });
                                      }),
                                ),
                                const Text(
                                  "Select All",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Expanded(
                                  child: Checkbox(
                                    value: provider.multiClass,
                                    onChanged: (value) {
                                      provider.setMultiClass(value ?? false);
                                      setState(() {
                                        provider.resetFileTypeAndContent();
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  "Multi Class",
                                  style: TextStyle(fontSize: 12),
                                ),
                                Expanded(
                                  child: Checkbox(
                                    value: provider.classWise,
                                    onChanged: (value) {
                                      provider.setClassWise(value ?? false);
                                      setState(() {
                                        provider.resetFileTypeAndContent();
                                      });
                                    },
                                  ),
                                ),
                                const Text(
                                  "Class Wise",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: provider.registrationWise,
                                  onChanged: (value) {
                                    provider
                                        .setRegistrationWise(value ?? false);
                                    setState(() {
                                      provider.resetFileTypeAndContent();
                                    });
                                  },
                                ),
                                const Text(
                                  "Registration Wise",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            if (provider.sendToAll ||
                                provider.multiClass ||
                                provider.classWise ||
                                provider.registrationWise)
                              const SizedBox(height: 10),
                            if (provider.multiClass)
                              Flexible(
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: provider.classes.length,
                                  itemBuilder: (context, index) {
                                    final className = provider.classes[index];
                                    return Column(
                                      children: [
                                        CheckboxListTile(
                                          title: Text(
                                            className,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          value: provider.classWise
                                              ? singleSelectedClassName ==
                                                  className
                                              : provider.selectedClassNames
                                                  .contains(className),
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                provider.classWise
                                                    ? singleSelectedClassName =
                                                        className
                                                    : provider
                                                        .selectedClassNames
                                                        .add(className);
                                              } else {
                                                provider.classWise
                                                    ? singleSelectedClassName =
                                                        null
                                                    : provider
                                                        .selectedClassNames
                                                        .remove(className);
                                              }
                                            });
                                          },
                                          dense: true,
                                        ),
                                        const Divider(
                                          color: Appcolor.themeColor,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            if (provider.classWise)
                              Column(
                                children: [
                                  // Dropdown for selecting Class
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Select Class',
                                      labelStyle: const TextStyle(
                                          color: Appcolor.themeColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Appcolor.themeColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Appcolor.themeColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    value: provider.classWise
                                        ? singleSelectedClassName
                                        : null,
                                    items: provider.classes
                                        .map((className) =>
                                            DropdownMenuItem<String>(
                                              value: className,
                                              child: Text(className,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != null) {
                                          provider.classWise
                                              ? singleSelectedClassName = value
                                              : provider.selectedClassNames
                                                  .add(value);
                                        } else {
                                          provider.classWise
                                              ? singleSelectedClassName = null
                                              : provider.selectedClassNames
                                                  .remove(value);
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Dropdown for selecting Section

                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Select Section',
                                      labelStyle: const TextStyle(
                                          color: Appcolor.themeColor),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Appcolor.themeColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Appcolor.themeColor),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    value: singleSelectedSectionName,
                                    items: provider.sections
                                        .map((sectionName) =>
                                            DropdownMenuItem<String>(
                                              value: sectionName,
                                              child: Text(sectionName,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12)),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        singleSelectedSectionName = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            if (provider.classWise ||
                                provider.registrationWise ||
                                provider.multiClass)
                              const SizedBox(height: 30),
                            if (provider.registrationWise)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 10),
                                  Text(
                                    'Please enter the registration number',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 10),
                            if (provider.registrationWise)
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border:
                                            Border.all(color: Colors.blueGrey),
                                        color: Colors.white70,
                                      ),
                                      child: TextField(
                                        controller: regNoController,
                                        decoration: const InputDecoration(
                                          hintText:
                                              "Enter registration number...",
                                          hintStyle: TextStyle(fontSize: 12),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                    ),
                                    onPressed: () async {
                                      String regNo =
                                          regNoController.text.toString();
                                      if (regNo.isNotEmpty) {
                                        await provider.getStudentRegWise(
                                            regNo, context);
                                      }
                                      regNoController.clear();
                                    },
                                    child: const Text(
                                      "Add",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            if (provider.registrationWise)
                              Flexible(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: provider.matchingStudents.length,
                                    itemBuilder: (_, index) {
                                      String studentName =
                                          provider.matchingStudents[index].name;
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              tileColor: Appcolor.themeColor,
                                              dense: true,
                                              visualDensity:
                                                  const VisualDensity(
                                                      vertical: -3),
                                              title: Text(
                                                studentName,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                provider.removeMatchingStudent(
                                                    index);
                                                print(provider.regNumber);
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 30,
                                              )),
                                        ],
                                      );
                                    }),
                              ),
                            if (provider.registrationWise)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount:
                                        registrationTextControllers.length,
                                    itemBuilder: (context, index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Container(
                                              width: size.width * 0.7,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.white70,
                                              ),
                                              child: TextField(
                                                controller:
                                                    registrationTextControllers[
                                                        index],
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      "Enter registration number",
                                                  hintStyle:
                                                      TextStyle(fontSize: 12),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 15),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ), // Add the closing parenthesis here
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
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      provider.isSending
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Loading....',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : provider.selectedImage != null
                              ? Center(
                                  child: Image.file(
                                    provider.selectedImage!,
                                    height: 300,
                                    width: 300,
                                  ),
                                )
                              : picture != null
                                  ? Image.file(File(picture!.path))
                                  : provider.filename != null
                                      ? DottedBorder(
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(20),
                                          dashPattern: const [10, 10],
                                          color: Colors.grey,
                                          strokeWidth: 2,
                                          child: Container(
                                              width: 300,
                                              height: 300,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.picture_as_pdf,
                                                    size: 80,
                                                    color: Colors.red,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      provider.filename
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.blueGrey),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        )
                                      : Container(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Visibility(
        visible: provider.sendToAll ||
            provider.multiClass ||
            provider.classWise ||
            provider.registrationWise,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: size.height * 0.08,
            width: size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white70,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Appcolor.themeColor,
                    cursorWidth: 1,
                    controller: provider.sendToAll
                        ? sendToAllController
                        : provider.multiClass
                            ? multiClassController
                            : provider.classWise
                                ? classWiseController
                                : provider.registrationWise
                                    ? regWiseController
                                    : null,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: "Enter text here...",
                        hintStyle: const TextStyle(
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.only(
                            left: 15, right: 15.0, top: 15, bottom: 15),
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: GestureDetector(
                            onTap: () async {
                              setState(() {
                                isCamera = false;
                                cameraCliked = false;
                                provider.selectedImage = null;
                                imageCamera = null;
                              });
                              await provider.pickImageAndSetContent(context);
                            },
                            child: const Icon(
                              Icons.attach_file,
                              color: Appcolor.themeColor,
                            ),
                          ),
                        ),
                        prefixIcon: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isCamera = true;
                              provider.selectedImage = null;
                            });
                            try {
                              // final picker = ImagePicker();
                              // final pickedFileCamera = await picker.pickImage(
                              //     source: ImageSource.camera);

                              // if (pickedFileCamera != null) {
                              //   fileType = "IMAGE";

                              //   // provider.setSelectedImage(File(pickedFile.path));
                              //   File? compressedImageFile = await provider
                              //       .compressImage(File(pickedFileCamera.path));
                              //   if (compressedImageFile != null) {
                              //     Uint8List? compressedImageBytes =
                              //         compressedImageFile.readAsBytesSync();
                              //     // Convert the image to base64
                              //     base64ImageCamera =
                              //         base64Encode(compressedImageBytes);
                              //   }

                              //   final cameraImage = File(pickedFileCamera.path);
                              //   setState(() {
                              //     imageCamera = cameraImage;
                              //   });
                              //   Navigator.pop(this.context);
                              // }
                            } catch (e) {
                              print("Error picking image: $e");
                            }
                          },
                          child: const Icon(
                            Icons.camera_alt,
                            size: 30,
                            color: Appcolor.themeColor,
                          ),
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final pref = await SharedPreferences.getInstance();
                    // String msgType = "MSG"; // Default value
                    // String? content = ""; // Default value

                    if (provider.sendToAll) {
                      provider.sendNotificationToAll(
                          cameraCliked
                              ? fileType.toString()
                              : provider.fileType.toString(),
                          provider.fileType == "IMAGE"
                              ? provider.base64Content.toString()
                              : fileType == "IMAGE"
                                  ? base64ImageCamera.toString()
                                  : provider.fileType == 'PDF'
                                      ? provider.base64ContentPdf.toString()
                                      : sendToAllController.text,
                          formattedDate.toString(),
                          pref.getInt('userid') ?? 0,
                          pref.getInt('schoolid') ?? 0,
                          pref.getString('userToken').toString(),
                          pref.getInt('sessionid')!.toInt(),
                          context);
                    } else if (provider.multiClass) {
                      print(
                          'Selected Class Names: ${provider.selectedClassNames}');

                      provider.multipleClassApi(
                          cameraCliked
                              ? fileType.toString()
                              : provider.fileType.toString(),
                          provider.fileType == "IMAGE"
                              ? provider.base64Content.toString()
                              : fileType == "IMAGE"
                                  ? base64ImageCamera.toString()
                                  : provider.fileType == 'PDF'
                                      ? provider.base64ContentPdf.toString()
                                      : multiClassController.text,
                          formattedDate.toString(),
                          pref.getInt('userid') ?? 0,
                          pref.getInt('schoolid') ?? 0,
                          pref.getString('userToken').toString(),
                          provider.selectedClassNames,
                          pref.getInt('sessionid')!.toInt(),
                          context);
                    } else if (provider.classWise) {
                      provider.classWiseApi(
                          cameraCliked
                              ? fileType.toString()
                              : provider.fileType.toString(),
                          provider.fileType == "IMAGE"
                              ? provider.base64Content.toString()
                              : fileType == "IMAGE"
                                  ? base64ImageCamera.toString()
                                  : provider.fileType == 'PDF'
                                      ? provider.base64ContentPdf.toString()
                                      : classWiseController.text,
                          formattedDate.toString(),
                          pref.getInt('userid') ?? 0,
                          pref.getInt('schoolid') ?? 0,
                          pref.getString('userToken').toString(),
                          singleSelectedClassName.toString(),
                          singleSelectedSectionName.toString(),
                          pref.getInt('sessionid')!.toInt(),
                          context);
                    } else {
                      registrationNumbers =
                          provider.extractRegistrationNumbers();

                      for (TextEditingController controller
                          in registrationTextControllers) {
                        registrationNumbers.add(controller.text);
                        print(
                            'registration numbers are : $registrationNumbers');
                      }

                      provider.registrationNoWiseApi(
                          cameraCliked
                              ? fileType.toString()
                              : provider.fileType.toString(),
                          provider.fileType == "IMAGE"
                              ? provider.base64Content.toString()
                              : fileType == "IMAGE"
                                  ? base64ImageCamera.toString()
                                  : provider.fileType == 'PDF'
                                      ? provider.base64ContentPdf.toString()
                                      : regWiseController.text,
                          formattedDate.toString(),
                          pref.getInt('userid') ?? 0,
                          pref.getInt('schoolid') ?? 0,
                          pref.getString('userToken').toString(),
                          provider.regNumber,
                          pref.getInt('sessionid')!.toInt(),
                          context);
                    }
                    sendToAllController.clear();
                    multiClassController.clear();
                    classWiseController.clear();
                    if (provider.regWiseData['resultcode'] == 0 ||
                        provider.sendToAllData['resultcode'] == 0 ||
                        provider.classWiseData['resultcode'] == 0 ||
                        provider.multiclassData['resultcode'] == 0) {
                      provider.resetFileTypeAndContent();
                      resetFileTypeAndContent();
                      setState(() {
                        provider.selectedImage = null;
                        picture = null;
                        provider.filename = null;
                      });
                    }

                    // Reset checkboxes to initial state
                    provider.setSendToAll(false);
                    provider.setMultiClass(false);
                    provider.setClassWise(false);
                    provider.setRegistrationWise(false);

                    regWiseController.clear();
                    provider.matchingStudents.clear();

                    singleSelectedClassName = null;
                    singleSelectedSectionName = null;
                  },
                  child: Container(
                    // height: size.height*0.05,
                    width: size.width * 0.10,
                    decoration:
                        const BoxDecoration(gradient: Appcolor.blueGradient),
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future takePicture() async {
    final provider = Provider.of<SendMessageViewModel>(context, listen: false);
    if (!_controller.value.isInitialized) {
      return null;
    }
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      await _controller.setFlashMode(FlashMode.off);
      picture = await _controller.takePicture();

      if (!mounted) return;
      if (picture != null) {
        File cameraFile = File(picture!.path);

        File? compressedImageFile =
            await provider.compressImage(File(cameraFile.path));
        if (compressedImageFile != null) {
          Uint8List? compressedImageBytes =
              compressedImageFile.readAsBytesSync();
          // Convert the image to base64
          base64ImageCamera = base64Encode(compressedImageBytes);
        }
      }
      setState(() {
        isCamera = false;
        cameraCliked = true;
        fileType = "IMAGE";
      });
      // File cameraFile = File(picture.path);
    } catch (e) {
      print(e);
    }
  }

  void resetFileTypeAndContent() {
    setState(() {
      fileType = 'MSG';
      base64ImageCamera = null;
    });
  }
}
