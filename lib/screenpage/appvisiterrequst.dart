import 'dart:convert';
import 'dart:io';
import 'package:adminvisitorapp/demo.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';

import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

//auto encreament  vistor id
class AutoIncrement {
  static String getDateTimeId() {
    DateTime now = DateTime.now();

    // Format: YYYYMMDDHHMMSSmmm (year, month, day, hour, min, sec, millisecond)
    String newId =
        "${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}"
        "${_twoDigits(now.hour)}${_twoDigits(now.minute)}"
        "${_twoDigits(now.second)}${now.millisecond}";

    return newId;
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}

class AppVisitRequestPage extends StatefulWidget {

 

  final List<Map<String, dynamic>> visitors;

  const AppVisitRequestPage({super.key, required this.visitors});

  @override
  State<AppVisitRequestPage> createState() => _AppVisitRequestPageState();
}

class _AppVisitRequestPageState extends State<AppVisitRequestPage> {

String? selectedPurpose;

   List<dynamic> purposelist = [
    'Courier',
   'Meeting',
    'Personal',
    'Others'

  ];
  // function userdata

  List<Map<String, dynamic>> userdata = [];
  List<Map<String, dynamic>> filteredVisitors = [];

  // 🔥 Filter search (fix for && crash)
  void filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredVisitors = userdata;
      } else {
        filteredVisitors = userdata.where((visitor) {
          final name = visitor["name"]?.toString().toLowerCase() ?? "";
          final phone = visitor["phone"]?.toString().toLowerCase() ?? "";
          return name.contains(query.toLowerCase()) ||
              phone.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> Fetchuserdata() async {
    setState(() {
      isLoadingData = true;
      errorMessage = null;
    });

    try {
      final Response = await http.get(
        Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'),
      );

      if (Response.statusCode == 200) {
        final data = jsonDecode(Response.body);

        if (data["stock"] != null && data["stock"].isNotEmpty) {
          setState(() {
            userdata = List<Map<String, dynamic>>.from(data["stock"]);
            filteredVisitors = userdata;
            fcmcontroller.text = userdata[0]["fcm_token"] ?? "No fcm found";
          });
        } else {
          setState(() {
            errorMessage = "⚠️ No visitors found!";
          });
        }
      } else {
        setState(() {
          errorMessage = "❌ Server Error: ${Response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "⚠️ Network/Parsing Error: $e";
      });
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Fetchuserdata();
  }

  // Static visitor list

  logout Logout = logout();

  Map<String, dynamic>? selectedVisitor;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController guestNameController = TextEditingController();
  final TextEditingController guestMobileController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestAddressController = TextEditingController();
  final TextEditingController guestVichleController = TextEditingController();
  final TextEditingController guestPurposeController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController fcmcontroller = TextEditingController();

  File? visitorPhoto;
  File? idProofPhoto;
  bool isLoading = false;
  bool isLoadingData = false;
  String? errorMessage;

  Future<void> pickImage(bool isVisitorPhoto) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (isVisitorPhoto) {
          visitorPhoto = File(pickedFile.path);
        } else {
          idProofPhoto = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (selectedVisitor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a visitor")),
      );
      return;
    }

    setState(() => isLoading = true);

    const String apiUrl = "https://ancoinnovation.com/visitor/reg.php";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      String newId = AutoIncrement.getDateTimeId();

      request.fields.addAll({
        "name": selectedVisitor!["name"],
        "email": selectedVisitor!["email"],
        "phone": selectedVisitor!["phone"],
        "flat": selectedVisitor!["flat"],
        "room": selectedVisitor!["room"],
        "image": selectedVisitor!["image"],
        "guest_name": guestNameController.text,
        "guest_mobile": guestMobileController.text,
        "guest_email": guestEmailController.text,
        "guest_address": guestAddressController.text,
        "guest_vichle": guestVichleController.text,
        "guest_visit_parpase": guestPurposeController.text,
        "other": otherController.text,
        "regid": newId.toString(), // auto increment id
        "comment": commentController.text,
        'fcm_token': selectedVisitor!["fcm_token"],
      });

      print('user send data : ${request.fields}');
      // ✅ Photo sirf tabhi add hoga jab null na ho
      if (visitorPhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath("visitorphoto", visitorPhoto!.path),
        );
      }

      if (idProofPhoto != null) {
        request.files.add(
          await http.MultipartFile.fromPath("idproofphoto", idProofPhoto!.path),
        );
      }

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        final resData = jsonDecode(responseData.body);
        if (resData["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Visit Request Submitted")),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AppVisitRequestPage(visitors: userdata),
            ),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: ${resData["message"]}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ HTTP Error: ${responseData.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("⚠️ Exception: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool required = false,
    int? maxlenght,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLength: maxlenght,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          prefixIcon: Icon(Icons.edit, color: Colors.red),
          filled: true,
          fillColor: Color(0xffffffff),
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "$label is required";
                }
                return null;
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xff1cae81),
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 35),
            SizedBox(width: 10),
            Spacer(),
            Text(
              'VISITECH ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => Logout.signout(context),
            ),
          ],
        ),
      ),
      //    appBar: PreferredSize(

      //   preferredSize: Size.fromHeight(110),
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
      //    backgroundColor: Color(0xffa7e9cf),
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      //     ),
      //     flexibleSpace: Container(
      //           decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           colors: [Color(0xffa7e9cf), Color(0xffa7e9cf)],

      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //         ),
      //         borderRadius: BorderRadius.vertical(
      //           bottom: Radius.circular(30),
      //         ),
      //       ),
      //       child: Padding(
      //         padding: EdgeInsets.only(top: 40,),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceAround,
      //           children: [
      //             Image.asset(
      //                  'assets/images/logo.png',
      //                 // fit: BoxFit.cover,
      //                  width: 60,
      //                  height: 60,
      //                ),
      //             Padding(
      //               padding: EdgeInsets.all(6),
      //               child: Column(
      //                 mainAxisAlignment: MainAxisAlignment.center,
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: [
      //                   Text('Request ', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 24)),
      //                   Text('Security is here', style: TextStyle(color: Colors.white))
      //                 ],
      //               ),
      //             ),
      //           IconButton(onPressed: ()=>Logout.signout(context),
      //           icon: Icon(Icons.logout,size: 35,),color: Colors.black,)
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Fetchuserdata();
        },
        child: isLoadingData
            ? const Center(child: CircularProgressIndicator()) // loading UI
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ) // error UI
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 baaki tumhara form code yaha hi rahega

                      // 1️⃣ Search TextField
                      TextField(
                        onChanged: (query) {
                          setState(() {
                            if (query.isEmpty) {
                              filteredVisitors = widget.visitors;
                            } else {
                              filteredVisitors = widget.visitors.where((
                                visitor,
                              ) {
                                final name = visitor["name"]
                                    .toString()
                                    .toLowerCase();
                                final phone = visitor["phone"]
                                    .toString()
                                    .toLowerCase();
                                return name.contains(query.toLowerCase()) ||
                                    phone.contains(query.toLowerCase());
                              }).toList();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(width: 2, color: Colors.red),
                          ),
                          labelText: "Select Host",
                          iconColor: Color(0xff77bd1f),
                          fillColor: Colors.black,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xff77bd1f),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(
                        'Scroll down to view more suggetions list..',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // 2️⃣ Suggestion list below search
                      if (filteredVisitors.isNotEmpty)
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: ListView.builder(
                            itemCount: filteredVisitors.length,
                            itemBuilder: (context, index) {
                              final visitor = filteredVisitors[index];
                              final String status = visitor["status"]
                                  .toString(); // ✅ check status

                              //define icon colore
                              IconData icon;
                              Color iconcolore;

                              if (status == '0') {
                                icon = Icons.block;
                                iconcolore = Colors.red;
                              } else if (status == '2') {
                                icon = Icons.event_busy;
                                iconcolore = Colors.yellow;
                              } else {
                                icon = Icons.circle;
                                iconcolore = Colors.green;
                              }

                              return ListTile(
                                enabled: status == '1', // <-- disable tile

                                leading: Icon(
                                  icon,
                                  size: 18,
                                  color: iconcolore,
                                ),
                                title: Text(
                                  'Name: ${visitor["name"]?.toString() ?? "Unknown"}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                // subtitle: Text('Phone: ${visitor["phone"]?.toString() ?? "N/A"}'),
                                onTap: status == '1'
                                    ? // 🚫 1 can selected othe cannot select
                                      () {
                                        setState(() {
                                          selectedVisitor = visitor;
                                          filteredVisitors = widget.visitors;
                                        });
                                      }
                                    : null,
                              );
                            },
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Not Found",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // 3️⃣ Original Dropdown (unchanged)
                      //DropdownButtonFormField<Map<String, dynamic>>(
                      //  value: selectedVisitor != null && widget.visitors.contains(selectedVisitor)
                      //   ? selectedVisitor
                      //      : null,
                      //  isExpanded: true,
                      //  decoration: InputDecoration(
                      //    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      //    labelText: "Or select Host",
                      //    labelStyle: const TextStyle(color: Colors.deepPurple),
                      //  filled: true,
                      //  fillColor: Colors.deepPurple.shade50,
                      //  ),
                      //  items: widget.visitors.map((visitor) {
                      //  return DropdownMenuItem(
                      //   value: visitor,
                      //   child: Text(visitor["name"]?.toString() ?? "Unknown"),
                      //  );
                      //  }).toList(),
                      //  onChanged: (value) {
                      // setState(() {
                      // selectedVisitor = value;
                      // });
                      //},
                      //),
                      const SizedBox(height: 20),

                      if (selectedVisitor != null)
                        Card(
                          color: selectedVisitor!["status"].toString() == "0"
                              ? Colors.grey.shade200
                              : Colors.white,
                          elevation: 6,
                          shadowColor: Colors.deepPurple.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      selectedVisitor!["image"] != null &&
                                          selectedVisitor!["image"]
                                              .toString()
                                              .isNotEmpty
                                      ? NetworkImage(
                                          selectedVisitor!["image"].toString(),
                                        )
                                      : null,
                                  child:
                                      (selectedVisitor!["image"] == null ||
                                          selectedVisitor!["image"]
                                              .toString()
                                              .isEmpty)
                                      ? const Icon(Icons.person, size: 40)
                                      : null,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedVisitor!["name"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      //  Text(" ${selectedVisitor!["fcm_token"] ?? 'N/A'}"),
                                      Text(
                                        "🏠 ${selectedVisitor!["flat"] ?? ''}, Room: ${selectedVisitor!["room"] ?? ''}",
                                      ),

                                      if (selectedVisitor!["status"]
                                              .toString() ==
                                          "0")
                                        const Text(
                                          "❌ Inactive",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),
                      const Text(
                        "📝 Visitor's Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      buildTextField(
                        " ✍️ Name*",
                        guestNameController,
                        required: true,
                      ),

                      //                Text(
                      //   selectedVisitor?["fcm_token"] ?? "N/A",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey[800],
                      //   ),
                      // ),
                      buildTextField(
                        " 📱 Mobile*",
                        guestMobileController,
                        required: true,
                        type: TextInputType.phone,
                        maxlenght: 10,
                      ),
                      buildTextField(
                        " 📧Email",
                        guestEmailController,
                        type: TextInputType.emailAddress,
                      ),
                      buildTextField(
                        " 🏠Address*",
                        guestAddressController,
                        required: true,
                      ),
                      DropdownButtonFormField<String>(
  decoration: InputDecoration(
    labelText: "📝 Purpose*",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  value: selectedPurpose,
  items: purposelist.map((purpose) {
    return DropdownMenuItem<String>(
      value: purpose,
      child: Text(purpose),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedPurpose = value;
      guestPurposeController.text = value!; // submit ke liye
    });
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Please select purpose";
    }
    return null;
  },
),


                      // buildTextField(
                      //   " 📝Purpose*",
                      //   guestPurposeController,
                      //   required: true,
                      // ),

                      buildTextField(" 🚗Vehicle No.", guestVichleController),

                      buildTextField(" 🏷️Other", otherController),

                      buildTextField(" 💬Comment", commentController),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff1cae81), // Red
                                  Color(0xff1cae81), // Green
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // Keep transparent for gradient
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () => pickImage(true),
                              icon: Icon(
                                visitorPhoto != null
                                    ? Icons.check_circle
                                    : Icons.photo_camera,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Visitor Photo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff1cae81), // Red
                                  Color(0xff1cae81), // Green
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .transparent, // for gradient visibility
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () => pickImage(false),
                              icon: Icon(
                                idProofPhoto != null
                                    ? Icons.check_circle
                                    : Icons.badge,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "ID Proof",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff1cae81), // Red
                                      Color(0xff1cae81), // Green
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(18),
                                    backgroundColor: Colors
                                        .transparent, // transparent for gradient
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: submitForm,
                                  child: const Text(
                                    "🚀 Submit Request",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _customBottomNavBar(1),
      //  BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   currentIndex: 1,
      //     selectedItemColor: Colors.grey,
      //    unselectedItemColor: Colors.black,
      //    backgroundColor: Color(0xffffffff),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.swipe_up), label: 'Request'),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.watch_later_outlined), label: 'Alerts'),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.history), label: 'History'),
      //   ],
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.pushReplacement(
      //           context, MaterialPageRoute(builder: (context) => Homepage()));
      //     }
      //     if (index == 1) {
      //       Navigator.pushReplacement(context,
      //           MaterialPageRoute(builder: (context) =>AppVisitRequestPage(visitors: userdata) ));
      //     }
      //     if (index == 2) {
      //       Navigator.push(context,
      //           MaterialPageRoute(builder: (context) => alertsdashboard()));
      //     }
      //     if (index == 3) {
      //       Navigator.push(context,
      //           MaterialPageRoute(builder: (context) => historypage()));
      //     }
      //   },
      // ),
    );
  }

  Widget _customBottomNavBar(int currentIndex) {
    List<Map<String, dynamic>> navItems = [
      {"icon": Icons.home, "label": "Home"},
      {"icon": Icons.swipe_up, "label": "Request"},
      {"icon": Icons.notifications, "label": "Alerts"},
      {"icon": Icons.history, "label": "History"},
    ];

    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          bool isSelected = currentIndex == idx;

          return GestureDetector(
            onTap: () {
              if (idx == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Homepage()),
                );
              } else if (idx == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppVisitRequestPage(visitors: userdata),
                  ),
                );
              } else if (idx == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => alertsdashboard()),
                );
              } else if (idx == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => historypage()),
                );
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff1cae81), Color(0xff1cae81)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    )
                  : BoxDecoration(),
              child: Row(
                children: [
                  Icon(
                    item['icon'],
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  if (isSelected) ...[
                    SizedBox(width: 6),
                    Text(
                      item['label'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
