// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icure_medical_device_dart_sdk/api/impl/user_api_impl.dart';
import 'package:icure_medical_device_dart_sdk/medtech_api.dart';
import 'animations/animations.dart';
import 'package:icure_dart_sdk/util/binary_utils.dart';

import 'constants/skin.dart';

Future<String> loadKey() async {
  return await rootBundle.loadString(
      'assets/782f1bcd-9f3f-408a-af1b-cd9f3f908a98-icc-priv.2048.key');
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.action}) : super(key: key);

  final void Function(BuildContext context, Future<MedTechApi> medTechApi) action;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _userNameController = TextEditingController();

  String _userName = '';
  String _password = '';

  Future<MedTechApi> medtechApi(String userName, String password) async {
    final MedTechApiBuilder builder = MedTechApiBuilder();
    builder.iCureBasePath = 'https://kraken.icure.dev';
    builder.userName = userName;
    builder.password = password;

    builder.addKeyPair("782f1bcd-9f3f-408a-af1b-cd9f3f908a98",
        (await loadKey()).toPrivateKey());

    return builder.build();
  }

  @override
  void initState() {
    medtechApi('abdemotst2', '27b90f6e-6847-44bf-b90f-6e6847b4bf1c')
        .then((api) async {
      var user = await UserApiImpl(api).getLoggedUser();
      setState(() {
        if (user?.login != null) {
          _userName = user!.login!;
          _userNameController.text = _userName;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          backgroundColor: Color(0xfffdfdfdf),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(25),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),

                      // Top Text
                      Container(
                        padding: EdgeInsets.only(left: 15),
                        width: width,
                        child: TopAnime(
                          1,
                          20,
                          curve: Curves.fastOutSlowIn,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome to iCure,",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w300,
                                  )),
                              Text(
                                "Type your email address and password to log in",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: height / 14,
                      ),

                      // TextFiled
                      Column(
                        children: [
                          Container(
                            width: width / 1.2,
                            height: height / 3.10,
                            //  color: Colors.red,
                            child: TopAnime(
                              1,
                              15,
                              curve: Curves.easeInExpo,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    onChanged: (text) {
                                      setState(() {
                                        log("Username set to ${text}");
                                        _userName = text;
                                      });
                                    },
                                    controller: _userNameController,
                                    // readOnly: true, // * Just for Debug
                                    cursorColor: Colors.black,
                                    style: TextStyle(color: Colors.black),
                                    showCursor: true,
                                    //cursorColor: mainColor,
                                    decoration: kTextFiledInputDecoration,
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  TextField(
                                      onChanged: (text) {
                                        setState(() {
                                          log("Password set to ${text}");
                                          _password = text;
                                        });
                                      },
                                      // readOnly: true, // * Just for Debug
                                      cursorColor: Colors.black,
                                      style: TextStyle(color: Colors.black),
                                      showCursor: true,
                                      //cursorColor: mainColor,
                                      decoration: kTextFiledInputDecoration
                                          .copyWith(labelText: "Password")),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                // Bottom
                TopAnime(
                  2,
                  42,
                  curve: Curves.fastOutSlowIn,
                  child: Container(
                    height: height / 6,
                    // color: Colors.red,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 30,
                          top: 15,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 43),
                          child: Container(
                              height: height / 9,
                              color: Colors.grey.withOpacity(0.4)),
                        ),
                        Positioned(
                          left: 280,
                          top: 10,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.indigo,
                                borderRadius: BorderRadius.circular(10)),
                            width: width / 4,
                            height: height / 12,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_forward,
                                size: 35,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.action(context, medtechApi(_userName, _password));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    ));
  }
}
