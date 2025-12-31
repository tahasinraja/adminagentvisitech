import 'dart:convert';

import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:adminvisitorapp/screenpage/finger_pin_loginpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:visitorapp/visitrequestpage.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  //fetch userdata host
  List<Map<String, dynamic>>? userdata = [];

  Future<void> Fetchuserdata() async {
    final Response = await http.get(
      Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'),
    );
    if (Response.statusCode == 200) {
      final data = jsonDecode(Response.body);
      setState(() {
        userdata = List<Map<String, dynamic>>.from(data["stock"]);
      });
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Succefully data loaded')));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Fetchuserdata();
     _checkLogin();
  }

  final TextEditingController _adminPhoneController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  final String userid = 'Admin';
  final String adminpassword = 'Visitech1234@';
  
static const String loginKey = 'isLoggedIn';

  void _login() async {
    final Id = _adminPhoneController.text.trim();
    final password = _adminPasswordController.text.trim();

    if (Id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill all the blanks')));
      return;
    }
    if (Id == userid && password == adminpassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(loginKey, true);
      await prefs.setString('userid', Id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login successful')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AppVisitRequestPage(visitors: userdata!),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Credentials')));
    }
  }

  void _checkLogin() async {
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Pin_fingerloginPage(),
           // AppVisitRequestPage(visitors: userdata!),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 🔹 Background (Two Colors)
            Row(
              children: [
                Expanded(
                  child: Container(color: Color(0xff244c41)), // Left side color
                ),
                Expanded(
                  child: Container(
                    color: Color(0xffffffff),
                  ), // Right side color
                ),
              ],
            ),

            //
            //🔹 Foreground (White Rounded Container)
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff244c41),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(70),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', height: 130),
                    SizedBox(height: 20),
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Agent Login',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 25),
                            // Username field
                            TextField(
                              controller: _adminPhoneController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Admin/Agent ID',
                                prefixIcon: Icon(
                                  Icons.perm_identity,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Password field
                            TextField(
                              controller: _adminPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                labelText: 'Password',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _login,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xff244c41),
                                        Color(0xff244c41),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            Center(
                              child: Text(
                                "Only authorized admins can log in",

                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Container(
      //         width: double.infinity,
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             colors: [Color(0xff244c41), Color(0xff244c41)],
      //             begin: Alignment.topCenter,
      //             end: Alignment.bottomCenter,
      //           ),
      //         ),

      // child: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [

      //     Spacer(),
      //    ClipRRect(
      //       child: Container(
      //         height: 380,
      //       width:  double.infinity,
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),color: Colors.white

      //       ),
      //       )
      //    )
      //   ],
      // ),
      // child: Center(
      //   child: SingleChildScrollView(
      //     child: Padding(
      //       padding: const EdgeInsets.all(20),
      //       child: Card(
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(20),
      //         ),
      //         elevation: 8,
      //         shadowColor: Colors.black54,
      //         child: Padding(
      //           padding: const EdgeInsets.all(20),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               // Admin Icon
      //               ClipRRect(
      //       // borderRadius: BorderRadius.circular(35), // Circle shape
      //               child: Image.asset(
      //                 'assets/images/logo.png',
      //                // fit: BoxFit.cover,
      //                 width: 70,
      //                 height: 70,
      //               ),

      //                                      ),
      //               SizedBox(height: 15),
      //               Text(
      //                 'Agent Login',
      //                 style: TextStyle(
      //                   fontSize: 22,
      //                   fontWeight: FontWeight.bold,
      //                   color: Colors.black,
      //                 ),
      //               ),
      //               SizedBox(height: 25),
      //               // Username field
      //               TextField(
      //                 controller: _adminPhoneController,
      //                 decoration: InputDecoration(
      //                   filled: true,
      //                   fillColor: Colors.grey[100],
      //                   labelText: 'Admin/Agent ID',
      //                   prefixIcon: Icon(Icons.perm_identity, color: Colors.black),
      //                   border: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(15),
      //                     borderSide: BorderSide.none,
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(height: 15),
      //               // Password field
      //               TextField(
      //                 controller: _adminPasswordController,
      //                 obscureText: true,
      //                 decoration: InputDecoration(
      //                   filled: true,
      //                   fillColor: Colors.grey[100],
      //                   labelText: 'Password',
      //                   prefixIcon: Icon(Icons.lock, color: Colors.black),
      //                   border: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(15),
      //                     borderSide: BorderSide.none,
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(height: 25),
      //               // Login button
      //               SizedBox(
      //                 width: double.infinity,
      //                 height: 50,
      //                 child: ElevatedButton(
      //                   style: ElevatedButton.styleFrom(
      //                     padding: EdgeInsets.zero,
      //                     shape: RoundedRectangleBorder(
      //                       borderRadius: BorderRadius.circular(15),
      //                     ),
      //                   ),
      //                   onPressed: _login,
      //                   child: Ink(
      //                     decoration: BoxDecoration(
      //                       borderRadius: BorderRadius.circular(15),
      //                       gradient: LinearGradient(
      //                         colors:[const Color(0xff1cae81), Color(0xff77bd1f)],
      //                         begin: Alignment.centerLeft,
      //                         end: Alignment.centerRight,
      //                       ),
      //                     ),
      //                     child: Container(
      //                       alignment: Alignment.center,
      //                       child: Text(
      //                         'Login',
      //                         style: TextStyle(
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.bold,
      //                           color: Colors.white,
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(height: 10),

      //               Center(
      //                 child: Text(
      //                   "Only authorized admins can log in" ,

      //                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      //                 ),
      //               ),

      //             ],
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),

      // ),
      floatingActionButton: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 18),
          child: Text(
            '© Design & Development by @ TECHPROMIND',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
