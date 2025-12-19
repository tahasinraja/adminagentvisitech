import 'dart:convert';

import 'package:adminvisitorapp/adduserdata.dart';
import 'package:adminvisitorapp/demo.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';

import 'package:adminvisitorapp/screenpage/imageview.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';




class datasheetpage extends StatefulWidget {
  const datasheetpage({super.key});

  @override
  State<datasheetpage> createState() => _datasheetpageState();
}

class _datasheetpageState extends State<datasheetpage> {
  logout Logout = logout();

  // searching function
  List<Map<String,dynamic>>filterlist=[];

  TextEditingController searchcontroller=TextEditingController();

 void fetchsearch(String query){
 List<Map<String, dynamic>>? results=[];
 if(query.isEmpty){
  results = userdata;  // agar khali to full datta/list showing
 } else{
  results = userdata?.where((item)=>item['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
  item['phone'].toString().toLowerCase().contains(query.toLowerCase())||
  item['flat'].toString().toLowerCase().contains(query.toLowerCase())
  ).toList();
  setState(() {
    filterlist=results!;
  });
 }
 }

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
         filterlist=userdata!;
      }); 
    }ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succefully data loaded')));
  } 

  // Static visitor list
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Fetchuserdata();
    
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

      // Visitor data section
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            TextField(
              onChanged: fetchsearch,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  
                  borderRadius: BorderRadius.circular(12),
                
                ),
                
                label: Text('Host name here'),
                prefixIcon: Icon(Icons.search),
                iconColor: Color(0xff77bd1f),
                
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => searchcontroller.clear(),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator( onRefresh: Fetchuserdata,
                child: ListView.builder(
                  itemCount: filterlist.length,
                  itemBuilder: (context, index) {
                    final visitor = filterlist[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                 MaterialPageRoute(builder: (context) => PhotoViewPage(imageUrl: visitor['image']),));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  visitor["image"], 
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name: ${visitor["name"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                 // SizedBox(height: 4),
                                  // Text(
                                  //   visitor['regid']!,
                                  //   style: TextStyle(
                                  //     color: const Color.fromARGB(
                                  //       255,
                                  //       243,
                                  //       54,
                                  //       54,
                                  //     ),
                                  //   ),
                                  // ),
                                  Text(
                                    visitor["email"]!,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  Text(
                                    visitor["phone"]!,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Flat: ${visitor["flat"]}"),
                                  Text("Room: ${visitor["room"]}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDataPage()),
          );
        },
        icon: CircleAvatar(
          radius: 40,
          child: Lottie.asset('assets/images/iFlribWNhe.json',fit: BoxFit.cover,
        )
      )
      ),
   bottomNavigationBar: _customBottomNavBar(0),
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
