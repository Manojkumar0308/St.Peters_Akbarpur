import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../service/forgot_password_api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // instances are created to control the input fields of different TextFields.
  TextEditingController mobilenoController = TextEditingController();

  bool tap = false;
  int mobnumberlength = 0;
  //method to count the length of input for mobilenoController of TextField.
  onChanged(String value) {
    setState(() {
      mobnumberlength = value.length;
    });
  }

//when this screen launched first initState is called.
  @override
  void initState() {
    super.initState();
    // Set the status bar color to white
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //Scaffold App is a material app widget having pre defined structure with appbar and body property.
    return Scaffold(
      // SingleChildScrollView is widget to make screen scrollable
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.12,
              ),
              const Text(
                "Reset Password",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const Text(
                "Change your password here",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Center(
                child: SizedBox(
                    height: size.height * 0.35,
                    child: Image.asset('assets/images/forgot_password.png')),
              ),
              Container(
                height: size.height * 0.05,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  cursorColor: Colors.black,
                  onChanged: onChanged,
                  cursorWidth: 1,
                  style: const TextStyle(fontSize: 14),
                  controller: mobilenoController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your 10 digit mobile no',
                    hintStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                height: size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Appcolor.themeColor, Appcolor.themeColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: TextButton(
                  onPressed: () async {
                    final pref = await SharedPreferences.getInstance();
                    pref.setString('otpMobNo', mobilenoController.text);
                    tap = true;
                    ForgotPasswordService().schoolDetailApi('peters');

                    if (mobnumberlength == 10 || mobnumberlength == 12) {
                      // ignore: use_build_context_synchronously
                      ForgotPasswordService()
                          .forgotPasswd(mobilenoController.text, context);
                    } else {
                      // ignore: use_build_context_synchronously
                      CommonMethods().showSnackBar(
                          context, 'Please enter valid mobile number');
                    }
                  },
                  child: const Text(
                    'Send Otp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
