import 'dart:convert';
import 'package:adminvisitorapp/demo.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';

import 'package:adminvisitorapp/screenpage/imageview.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class historypage extends StatefulWidget {
  const historypage({super.key});

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {
  logout Logout = logout();
// fetch function from userdata passing for data list
  List <Map<String, dynamic>>? userdata=[];
  


  // fetch user data
  Future<void> Fetchuserdata() async {
    final Response = await http.get(
      Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'),
    );
    if (Response.statusCode == 200) {
      final data=jsonDecode(Response.body);
      setState(() {
         userdata = List<Map<String, dynamic>>.from(data["stock"]);
         
      }); 
    }ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succefully data loaded')));
  } 

  // Static visitor list
 

  List<dynamic> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
     Fetchuserdata();
  }

  Future<void> fetchHistoryData() async {
    try {
      final response = await http.get(
        Uri.parse("https://ancoinnovation.com/visitor/reg_fetch.php"),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          historyData = decoded['stock'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("⚠ Error: $e");
    }
  }

  /// ✅ Photo URL builder
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
    return "assets/images/default.png";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1cae81),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              // fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
            SizedBox(width: 10),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Visitor History",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
               
              ],
            ),
            Spacer(),
            IconButton(
              onPressed: () => Logout.signout(context),
              icon: Icon(Icons.logout, size: 30),
              color: Colors.white,
            )
          ],
        ),
      ),
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(100),
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
          
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      //     ),
      //     flexibleSpace: Container(
            
      //          decoration: BoxDecoration(
      //         gradient: LinearGradient(
      //           colors: [ Color(0xffc92402), // Red
      //   Color(0xff77bd1f)],
      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //         ),
      //         borderRadius: BorderRadius.vertical(
      //           bottom: Radius.circular(30),
      //         ),
      //       ),
      //       child: Padding(
              
      //         padding: EdgeInsets.only(top: 40),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceAround,
      //           children: [
      //                Image.asset(
      //                     'assets/images/logo.png',
      //                    // fit: BoxFit.cover,
      //                     width: 60,
      //                     height: 60,
      //                   ),
      //             Column(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 Text("Visitor History",
      //                     style: TextStyle(
      //                         color: Colors.white,
      //                         fontWeight: FontWeight.bold,
      //                         fontSize: 24)),
      //                 Text("Security is here",
      //                     style: TextStyle(color: Colors.white))
      //               ],
      //             ),
      //             IconButton(
      //               onPressed: () => Logout.signout(context),
      //               icon: Icon(Icons.logout, size: 35),
      //               color: Colors.black,
      //             )
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: RefreshIndicator(
        onRefresh: ()async {
          await fetchHistoryData();
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : historyData.isEmpty
                ? Center(child: Text("No history found"))
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      final item = historyData[index];
        
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔹 Owner & Visitor section
                              Row(
                                children: [
                                  _buildPersonCard(
                                    name: item["name"] ?? "Unknown",
                                    phone: item['phone'] ?? "-",
                                    regid: item["regid"] ?? "-",
                                    photo: getPhotoUrl(item["image"]),
                                    role: "Host",
                                    bgColor: Color(0xff77bd1f),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.compare_arrows,
                                      size: 30, color: Colors.grey),
                                  SizedBox(width: 12),
                                  _buildPersonCard(
                                    name: item["guest_name"] ?? "Unknown",
                                    phone: item['guest_mobile'] ?? "-",
                                    regid: item["guest_email"] ?? "-",
                                    photo: getPhotoUrl(item["visitorphoto"]),
                                    role: "Visitor",
                                    bgColor: Color(0xffc92402),
                                  ),
                                ],
                              ),
        
                              Divider(height: 20, thickness: 1),
                              
                              ExpansionTile(title: Text('View Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                             
                              children: [
                                Padding(padding: EdgeInsets.all(2),
                                child: Column(
                                  
                                 
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
        
                                Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                                    /// 🔹 Extra Details
                              Text("Flat: ${item['flat'] ?? '-'}",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Room: ${item['room'] ?? '-'}",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("V-Address: ${item['guest_address'] ?? '-'}"),
                              Text("V-Vehicle: ${item['guest_vichle'] ?? '-'}"),
                              Text("V-Purpose: ${item['guest_visit_parpase'] ?? '-'}"),
                              Text("Other: ${item['other'] ?? '-'}"),
                              Text("VisitorID: ${item['regid'] ?? '-'}"),
                              Text("Comment: ${item['comment'] ?? '-'}"),
                             // Text('Request Date&time:${item['datetime']}'),
                              SizedBox(height: 20,),
                            Text('Date&time:${item['mem_feeddatetime']}'),
                              Text('Stutas:${item['mem_status']}'),
                              Text('Feedback:${item['mem_feed']}'),
        
        
                                      ],
                                    ),
                              
                              SizedBox(height: 10),
                               
                              /// 🔹 Visitor ID Proof Photo
                              if ((item['idproofphoto'] ?? "").isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Visitor ID Proof:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                         MaterialPageRoute(builder: (context) => PhotoViewPage(imageUrl: item['idproofphoto']),));
                                      },
                                      child: Image.network(
                                        getPhotoUrl(item['idproofphoto']),
                                        height: 105,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                    "assets/images/default.png",
                                                    height: 120,
                                                   
                                                    fit: BoxFit.cover),
                                      ),
                                    ),
                                  ],
                                ),
                                      ],
                                    ),
                                   
                                  ],
                                ),
                                
                                ),
        
                             
                              ],
                              
                              ),
                             
                           
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: _customBottomNavBar(3),
    );
  }

  Widget _buildPersonCard({
    required String name,
    required String phone,
    required String regid,
    required String photo,
    required String role,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: photo.startsWith("http")
                  ? NetworkImage(photo)
                  : AssetImage(photo) as ImageProvider,
            ),
            SizedBox(height: 6),
            Text(name,
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text("phone: $phone",
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            Text(role,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: bgColor)),
          ],
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
