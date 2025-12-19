import 'dart:convert';
import 'dart:io';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class AddDataPage extends StatefulWidget {
  const AddDataPage({super.key});

  @override
  State<AddDataPage> createState() => _AddDataPageState();
}

class _AddDataPageState extends State<AddDataPage> {
  logout Logout = logout();
  final _formKey = GlobalKey<FormState>();
  final String url1 = 'https://ancoinnovation.com/visitor/flat_mem_reg.php';

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
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
      request.fields['regid'] = regidController.text;
      request.fields['email'] = emailController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['flat'] = flatController.text;
      request.fields['room'] = roomController.text;
      request.fields['pass']=passwordcontroller.text;

      request.files.add(await http.MultipartFile.fromPath(
          'image', _selectedImage!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print("Response: $data");
        print('Response.body');
         print("📩 Status Code: ${response.statusCode}");
  print("📦 Raw Response Body: ${response.body}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Visitor added successfully")),
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
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          flexibleSpace: Container(
                decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 13, 67, 110), Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 40,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                     child: Icon(Icons.admin_panel_settings,
                          color: Colors.black, size: 40),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Visitor App', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20)),
                        Text('Security is here', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                IconButton(onPressed: ()=>Logout.signout(context), icon: Icon(Icons.logout,size: 30,),color: Colors.white,)
                ],
              ),
            ),
          ),
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
                    // Image Picker
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurpleAccent],
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
                    buildTextField("Flat", Icons.apartment, flatController),
                    buildTextField( "Room", Icons.meeting_room, roomController),
                       buildTextField("RegId", Icons.badge, regidController),
                         buildTextField("pass", Icons.password, passwordcontroller),

                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addVisitor,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.deepPurple,
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
