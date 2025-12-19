import 'dart:convert';

import 'package:adminvisitorapp/adduserdata.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:adminvisitorapp/screenpage/homscreen.dart';
import 'package:adminvisitorapp/screenpage/imageview.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:adminvisitorapp/visitrequestpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class requestvisiter extends StatefulWidget {
  const requestvisiter({super.key});

  @override
  State<requestvisiter> createState() => _requestvisiterState();
}

class _requestvisiterState extends State<requestvisiter> {
  logout Logout = logout();

  List <Map<String, dynamic>>? userdata=[];
  
//searching  function
List<Map<String, dynamic>>filterlist=[];

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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Visitor App',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Security is here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Logout.signout(context),
                  icon: Icon(Icons.logout, size: 35),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
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
                label: Text('Geust name here'),
                prefixIcon: Icon(Icons.search),
              ),
            ),

            Expanded(
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
                                height: 100,
                                width: 100,
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
                                  visitor["name"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  visitor['regid']!,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      243,
                                      54,
                                      54,
                                    ),
                                  ),
                                ),
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
                                  SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                AppVisitRequestPage(visitors: userdata!)));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Visit request sent for ${visitor["name"]}"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text("Request Visite",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
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
        icon: CircleAvatar(radius: 30,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.person_add,size: 28, color: Colors.white,),)
      ),
    bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 4button navigation
         currentIndex: 1,
          selectedItemColor: Colors.black,
         unselectedItemColor: Colors.white,
         backgroundColor: Color(0xff77bd1f),
           
        
        items:[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home' ),
          BottomNavigationBarItem(icon: Icon(Icons.swipe_up),label: 'Request'),
          BottomNavigationBarItem(icon: Icon(Icons.watch_later_outlined),label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.format_list_numbered_outlined),label: 'History'),

        ],
        onTap: (index){
          if(index==0){
            Navigator.push(context, MaterialPageRoute(builder: (context) => homepage(),));
          }
          if(index==1){
            Navigator.push(context, MaterialPageRoute(builder: (context) => visitrequestpage(),));
          }
          if(index==2){
            Navigator.push(context, MaterialPageRoute(builder: (context) => alertsdashboard()));

          }
          if(index==3){
            Navigator.push(context, MaterialPageRoute(builder: (context) => historypage(),));
          }
        },
        
        ),
    );
  }
}
