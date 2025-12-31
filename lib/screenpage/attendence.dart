import 'dart:convert';

import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class attendencepage extends StatefulWidget {
  final String id;
  const attendencepage({super.key, required this.id});

  @override
  State<attendencepage> createState() => _attendencepageState();
}

class _attendencepageState extends State<attendencepage> {
  logout Logout = logout();
  //editupadte funtiom
    bool isinside = false;

  //entry exit update function
  Future<void> updateentryexit(String id, String type) async {
    final url = Uri.parse(
      'https://ancoinnovation.com/visitor/edit_common_people.php',
    );

    String time = DateTime.now().toString().split('.').first;

    Map<String, String> body = {'id': id};

    // 🔁 Decide entry or exit
    if (type == 'Entry') {
      body['entry_datetime'] = time;
    } else {
      body['exit_datetime'] = time;
    }

    try {
      final response = await http.post(url, body: body);
      print("📥 RESPONSE STATUS: ${response.statusCode}");
      print("📥 RESPONSE BODY: ${response.body}");

      print("📤 REQUEST BODY: $body");

      if (response.statusCode == 200) {
        print("✅ $type updated | ID: $id | TIME: $time");
      } else {
        print('❌ Failed to update | ID: $id | Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating Entry/Exit for ID $id: $e');
    }
  }
  //fetch data
  List<Map<String, dynamic>>? attendencedata = [];
  Future<void> fetchattendnce(String id) async {
    final url = Uri.parse(
      'https://ancoinnovation.com/visitor/fetch_common_people2.php?id=$id',
    );

    print("Fetching attendance for ID: ${widget.id}");
    try {
      final responce = await http.get(url);
      if (responce.statusCode == 200) {
        final data = jsonDecode(responce.body);
        print("Attendance data received: $data");
        setState(() {
          attendencedata = List<Map<String, dynamic>>.from(data['people']);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance data loaded successfully')),
        );
        print('Responce bosy;${responce.body}');
      }
    } catch (e) {
      print("Error fetching attendance: $e");
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchattendnce(widget.id);
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: attendencedata == null || attendencedata!.isEmpty
                  ? Center(child: Text('No attendance data available'))
                  :
              
               ListView.builder(
                itemCount: attendencedata?.length ?? 0,
                itemBuilder: (context, index) {

                  bool isInside = attendencedata![index]['entry_datetime'] != null &&
                attendencedata![index]['entry_datetime'].toString().isNotEmpty &&
               (attendencedata![index]['exit_datetime'] == null ||
                attendencedata![index]['exit_datetime'].toString().isEmpty);
                  
                  return Container(
                   // height: double.infinity,
                   
               child: Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  elevation: 6,
  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with rounded corners
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(
              attendencedata![index]['image'],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 50, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Name
        Row(
          children: [
            const Icon(Icons.person, size: 18, color: Colors.green),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Name: ${attendencedata![index]['name'] ?? '-'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Email
        Row(
          children: [
            const Icon(Icons.email, size: 18, color: Colors.blue),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Email: ${attendencedata![index]['email'] ?? '-'}",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        
        // Phone
        Row(
          children: [
            const Icon(Icons.phone, size: 18, color: Colors.orange),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Phone: ${attendencedata![index]['phone'] ?? '-'}",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        
        // Address
        Row(
          children: [
            const Icon(Icons.home, size: 18, color: Colors.red),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Address: ${attendencedata![index]['flat_address'] ?? '-'}",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
            
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Last Entry: ${attendencedata![index]['entry_datetime'] ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade700)),
              SizedBox(height: 4),
              Text('Last Exit : ${attendencedata![index]['exit_datetime'] ?? '-'}',
                  style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
        ),
        // 🔘 ENTRY / EXIT BUTTON ROW
        const SizedBox(height: 50),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                        TextButton.icon(
  style: TextButton.styleFrom(
    backgroundColor: isInside ? Colors.grey : Colors.green,
  ),
  onPressed: isInside
      ? null
      : () async {
          await updateentryexit(attendencedata![index]['id'], 'Entry');
          fetchattendnce(widget.id); // 🔁 REFRESH DATA
        },
  icon: const Icon(Icons.login, color: Colors.white),
  label: const Text("Entry", style: TextStyle(color: Colors.white)),
),

                                              const SizedBox(width: 10),
                                           TextButton.icon(
  style: TextButton.styleFrom(
    backgroundColor: isInside ? Colors.red : Colors.grey,
  ),
  onPressed: isInside
      ? () async {
          await updateentryexit(attendencedata![index]['id'], 'Exit');
          fetchattendnce(widget.id); // 🔁 REFRESH DATA
        }
      : null,
  icon: const Icon(Icons.logout, color: Colors.white),
  label: const Text("Exit", style: TextStyle(color: Colors.white)),
),

                                            ],
                                          ),
                                          SizedBox(height: 20,)
      ],
    ),
  ),
),


              );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
