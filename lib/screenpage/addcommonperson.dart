import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class addcommonpersonpage extends StatefulWidget {
  const addcommonpersonpage({super.key});

  @override
  State<addcommonpersonpage> createState() => _addcommonpersonpageState();
}

class _addcommonpersonpageState extends State<addcommonpersonpage> {



  logout Logout = logout();
  final _formKey = GlobalKey<FormState>();
  final String url1 = 'https://ancoinnovation.com/visitor/common_people_add.php';

  final nameController = TextEditingController();
  final regidController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final flatController = TextEditingController();
  final roomController = TextEditingController();
  final passwordcontroller=TextEditingController();

  File? _selectedImage;
  bool isLoading = false;

Future<void> pickImage() async {
  print("📸 Pick image option opened");

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      );
    },
  );
}
Future<void> _getImage(ImageSource source) async {
  print("📂 Image source selected: $source");

  final pickedFile = await ImagePicker().pickImage(
    source: source,
    imageQuality: 80,
  );

  if (pickedFile == null) {
    print("❌ Image selection cancelled");
    return;
  }

  print("✅ Image path: ${pickedFile.path}");

  setState(() {
    _selectedImage = File(pickedFile.path);
  });
}


  Future<void> addVisitor() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a photo")));
      return;
    }

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url1));
      request.fields['name'] = nameController.text;
  
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['flat_address'] = flatController.text;
  

      request.files.add(await http.MultipartFile.fromPath(
          'image', _selectedImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
       
        var data = jsonDecode(response.body);
   debugPrint("✅ STATUS CODE: ${response.statusCode}");
  debugPrint("📦 RAW RESPONSE BODY:");
  debugPrint(response.body, wrapWidth: 1024);

  debugPrint("📊 DECODED DATA:");
  debugPrint(data.toString(), wrapWidth: 1024);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Common person added successfully")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to add visitor")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  Widget buildTextField(String label, IconData icon,
      TextEditingController controller,
      {bool required = false, int? maxlenght,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLength: maxlenght,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        validator: required
            ? (value) => value!.isEmpty ? "Enter $label" : null
            : null,
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text('Add Common Person Details:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 20),
                    // Image Picker
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xff1cae81), Color(0xff1cae81)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipOval(
                                child: Image.file(_selectedImage!,
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.camera_alt,
                                color: Colors.white, size: 50),
                      ),
                    ),
                    const SizedBox(height: 20),

                    buildTextField("Name", Icons.person, nameController,
                        required: true),
                    
                    buildTextField("Email", Icons.email, emailController),
                    buildTextField("Phone", Icons.phone, phoneController,maxlenght: 10),
                    buildTextField("Address", Icons.apartment, flatController),
                   // buildTextField( "Room", Icons.meeting_room, roomController),
                     //  buildTextField("RegId", Icons.badge, regidController),
                      //   buildTextField("pass", Icons.password, passwordcontroller),

                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addVisitor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xff1cae81),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Submit",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
    );
  }
}
