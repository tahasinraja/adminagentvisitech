import 'dart:convert';

import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:adminvisitorapp/screenpage/homscreen.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class visitrequestpage extends StatefulWidget {
  const visitrequestpage({super.key});

  @override
  State<visitrequestpage> createState() => _visitrequestpageState();
}

class _visitrequestpageState extends State<visitrequestpage> {

  logout Logout=logout();

   List <Map<String, dynamic>>? userdata=[];

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

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Fetchuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: 40,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 Image.asset(
                          'assets/images/logo.png',
                         // fit: BoxFit.cover,
                          width: 60,
                height: 60,
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
              IconButton(onPressed: ()=>Logout.signout(context), icon: Icon(Icons.logout,size: 35,),color: Colors.white,)
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add_alt_1,
                    size: 80, color: Colors.deepPurple),
                const SizedBox(height: 15),
                const Text(
                  "Select  Host",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Choose a visitor from the list to create a visit request.\nYou can manage visitor access easily.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AppVisitRequestPage(visitors: userdata!)),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text(
                      "Click here to Select Host",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => homepage(),));
          }
          if(index==1){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AppVisitRequestPage(visitors: userdata!)));
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


