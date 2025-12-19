import 'dart:convert';
import 'dart:io';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class AppVisitRequest extends StatefulWidget {
  const AppVisitRequest({super.key});

  @override
  State<AppVisitRequest> createState() => _AppVisitRequestState();
}

class _AppVisitRequestState extends State<AppVisitRequest> {
  logout Logout = logout();

  List<dynamic> visitors = [];
  Map<String, dynamic>? selectedVisitor;

  final TextEditingController guestNameController = TextEditingController();
  final TextEditingController guestMobileController = TextEditingController();
  final TextEditingController guestEmailController = TextEditingController();
  final TextEditingController guestAddressController = TextEditingController();
  final TextEditingController guestVichleController = TextEditingController();
  final TextEditingController guestPurposeController = TextEditingController();
  final TextEditingController otherController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  File? visitorPhoto;
  File? idProofPhoto;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchVisitors();
  }

  Future<void> fetchVisitors() async {
    try {
      final response = await http.get(Uri.parse("https://ancoinnovation.com/visitor/getVisitors.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          visitors = data; // API se list
        });
      }
    } catch (e) {
      debugPrint("Error fetching visitors: $e");
    }
  }

  Future<void> pickImage(bool isVisitorPhoto) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
    if (selectedVisitor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a Visitor first")),
      );
      return;
    }

    if (visitorPhoto == null || idProofPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select both photos")),
      );
      return;
    }

    setState(() => isLoading = true);

    const String apiUrl = "https://ancoinnovation.com/visitor/reg.php";

    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // Visitor details
      request.fields.addAll({
        "regid": selectedVisitor!["regid"],
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
        "comment": commentController.text,
      });

      // Photos
      request.files.add(await http.MultipartFile.fromPath("visitorphoto", visitorPhoto!.path));
      request.files.add(await http.MultipartFile.fromPath("idproofphoto", idProofPhoto!.path));

      debugPrint("👉 Request Fields: ${request.fields}");
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      debugPrint("👉 API Response: ${responseData.body}");

      if (responseData.statusCode == 200) {
        final resData = jsonDecode(responseData.body);
        if (resData["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Visit Request Submitted")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: ${resData["message"]}")),
          );
        }
      }
    } catch (e) {
      debugPrint("👉 Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Exception: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visitor Request"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => Logout.signout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown for Visitors
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: selectedVisitor,
              decoration: const InputDecoration(
                labelText: "Select Visitor",
                border: OutlineInputBorder(),
              ),
              items: visitors.map((v) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: v,
                  child: Text(v["name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedVisitor = value;
                });
              },
            ),

            const SizedBox(height: 20),

            if (selectedVisitor != null) ...[
              // Visitor Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 35, backgroundImage: NetworkImage(selectedVisitor!["image"])),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(selectedVisitor!["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text("RegID: ${selectedVisitor!["regid"]}"),
                            Text("Email: ${selectedVisitor!["email"]}"),
                            Text("Phone: ${selectedVisitor!["phone"]}"),
                            Text("Flat: ${selectedVisitor!["flat"]}, Room: ${selectedVisitor!["room"]}"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("👤 Guest Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              buildTextField("Guest Name", guestNameController),
              buildTextField("Guest Mobile", guestMobileController, type: TextInputType.phone),
              buildTextField("Guest Email", guestEmailController, type: TextInputType.emailAddress),
              buildTextField("Guest Address", guestAddressController),
              buildTextField("Guest Vehicle", guestVichleController),
              buildTextField("Visit Purpose", guestPurposeController),
              buildTextField("Other", otherController),
              buildTextField("Comment", commentController),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => pickImage(true),
                    icon: Icon(visitorPhoto != null ? Icons.check_circle : Icons.photo_camera),
                    label: const Text("Visitor Photo"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(false),
                    icon: Icon(idProofPhoto != null ? Icons.check_circle : Icons.badge),
                    label: const Text("ID Proof"),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                        onPressed: submitForm,
                        child: const Text("🚀 Submit Request", style: TextStyle(fontSize: 16)),
                      ),
                    ),
            ]
          ],
        ),
      ),
    );
  }
}
