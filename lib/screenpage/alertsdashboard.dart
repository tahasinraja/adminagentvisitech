import 'dart:convert';
import 'package:adminvisitorapp/demo.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';

import 'package:adminvisitorapp/screenpage/imageview.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:url_launcher/url_launcher.dart';


class alertsdashboard extends StatefulWidget {
  const alertsdashboard({super.key});

  @override
  State<alertsdashboard> createState() => _alertsdashboardState();
}

class _alertsdashboardState extends State<alertsdashboard>

    with SingleTickerProviderStateMixin {
String formatNumber(String number) {
  number = number.trim();
  if (number.startsWith("+")) return number;
  return "+91$number";
}


      //twillo
Future<void> startTwilioCall(
  String visitorNumber,
  String hostNumber,
) async {
  final url = Uri.parse(
    "https://visitechservice-6578.twil.io/call",
  );

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "visitor": visitorNumber,
        "host": hostNumber,
      },
      
    );
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text("📞 Calling visitor...")),
);

    print("📞 Twilio Status: ${response.statusCode}");
    print("📞 Twilio Response: ${response.body}");
  } catch (e) {
    print("❌ Twilio Call Error: $e");
  }
}



// callnumber(String phone) async {
//   if (phone.trim().isEmpty) return;

//   final uri = Uri.parse("tel:$phone");
//   await launchUrl(uri);
// }





  //  Uri dialnumber = Uri(scheme: 'tel', path: '100');
  // callnumber() async {
  //   await launchUrl(dialnumber);
  // }

  logout Logout = logout();

  String selectedfilter = 'Today';

  List<Map<String, dynamic>>? userdata = [];
  List<dynamic> allHistory = [];
  List<dynamic> approved = [];
  List<dynamic> rejected = [];
  List<dynamic> waiting = [];

  bool isLoading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchHistoryData();
    Fetchuserdata();
  }

  Future<void> Fetchuserdata() async {
    try {
      final response = await http.get(
        Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userdata = List<Map<String, dynamic>>.from(data["stock"]);
        });
      }
    } catch (e) {
      print("⚠ Error fetching userdata: $e");
    }
  }

  Future<void> fetchHistoryData() async {
    try {
      final response = await http.get(
        Uri.parse("https://ancoinnovation.com/visitor/reg_fetch.php"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          allHistory = decoded['stock'];
          approved = allHistory
              .where((item) => item['mem_status']?.toLowerCase() == "approved")
              .toList();
          rejected = allHistory
              .where((item) => item['mem_status']?.toLowerCase() == "rejected")
              .toList();
          waiting = allHistory
              .where((item) {
                final status = item['mem_status']?.toLowerCase() ?? "";
                return status == "waiting" || status == "pending";
              })
              .toList();

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("⚠ Error: $e");
    }
  }

 List<dynamic> applyDateFilter(List<dynamic> data) {
  DateTime now = DateTime.now();
  return data.where((item) {
    String? dateStr = item['mem_feeddatetime'];
    if (dateStr == null || dateStr.isEmpty) return false;

    DateTime itemDate = DateTime.tryParse(dateStr) ?? DateTime(2000);

    // ✅ Only today ke records
    return itemDate.year == now.year &&
        itemDate.month == now.month &&
        itemDate.day == now.day;
  }).toList();
}


  String getPhotoUrl(String? photo) {
    if (photo != null && photo.isNotEmpty) {
      if (photo.toLowerCase().contains("no_photo") ||
          photo.toLowerCase().contains("no_id")) {
        return "assets/images/no-picture-taking_2542641.png";
      }
      if (photo.startsWith("http")) {
        return photo;
      } else {
        return "https://ancoinnovation.com/visitor/$photo";
      }
    }
    return "assets/images/default.jpg";
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
     appBar: AppBar(
        backgroundColor: Color(0xff1cae81),
        title: Row(
          
          children: [
            Image.asset(  'assets/images/logo.png', height: 35),
            SizedBox(width: 10),
            Spacer(),
            Text('VISITECH ', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () => Logout.signout(context),
            )
          ]
        ) 
      
      ),
    body: RefreshIndicator(
      onRefresh: () async {
        await fetchHistoryData();
      },
      child: Column(
        children: [
          // 🔹 Modern pill-style tab toggle
          Container(
            height: 53,
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xff1cae81),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabToggle("Approved", 0, Colors.black),
                _buildTabToggle("Rejected", 1, Colors.red),
                _buildTabToggle("Waiting", 2, Colors.orange),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      buildList(approved, Colors.green),
                      buildList(rejected, Colors.red),
                      buildList(waiting, Colors.orange),
                    ],
                  ),
          ),
        ],
      ),
    ),
    bottomNavigationBar:_customBottomNavBar(2),
  );
}

Widget buildList(List<dynamic> data, Color color) {
  // ✅ Always apply Today filter here
  List<dynamic> filteredData = applyDateFilter(data);

  if (filteredData.isEmpty) {
    return Center(child: Text("No records found for Today"));
  }

  return ListView.builder(
    padding: EdgeInsets.all(12),
    itemCount: filteredData.length,
    itemBuilder: (context, index) {
      final item = filteredData[index];
      return Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(getPhotoUrl(item['visitorphoto'])),
          ),
          title: Row(
            children: [
              Text(item['guest_name'] ?? "Unknown"),

              Spacer(),
 IconButton(
  icon: Icon(Icons.phone, color: Colors.green),
  onPressed: () {
    final visitor = item['guest_mobile'];
    final host = item['phone'];

    if (visitor == null || host == null) return;

    startTwilioCall(
      formatNumber(visitor.toString()), // visitor
      formatNumber(host.toString()),    // host (dynamic ✅)
    );
  },
),



// IconButton(
//   onPressed: item['phone'] == null || item['phone'].toString().isEmpty
//       ? null
//       : () => callnumber(item['phone'].toString()),
//   icon: Icon(Icons.phone),
//   color: Colors.green,
// ),


            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${item['guest_mobile'] ?? '-'}"),
              Text("Status: ${item['mem_status'] ?? '-'}",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Text("Date: ${item['mem_feeddatetime'] ?? '-'}"),
              Text('Host No. : ${item['phone'] ?? '-'}'),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewPage(
                  imageUrl: item['idproofphoto'] ?? "",
                ),
              ),
            );
          },
        ),
      );
    },
  );
}


  Widget _buildTabToggle(String text, int index, Color color) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? color : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => Homepage()));
              } else if (idx == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppVisitRequestPage(visitors: userdata??[])));
              } else if (idx == 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => alertsdashboard()));
              } else if (idx == 3) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => historypage()));
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xff1cae81), Color(0xff1cae81)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
                    )
                  : BoxDecoration(),
              child: Row(
                children: [
                  Icon(item['icon'], color: isSelected ? Colors.white : Colors.black54),
                  if (isSelected) ...[
                    SizedBox(width: 6),
                    Text(item['label'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  }