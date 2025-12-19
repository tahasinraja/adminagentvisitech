import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
class commomvisitorpage extends StatefulWidget {
  const commomvisitorpage({super.key});

  @override
  State<commomvisitorpage> createState() => _commomvisitorpageState();
}

class _commomvisitorpageState extends State<commomvisitorpage> {
   logout Logout = logout();
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
      body: Center(
        child: Text('Coming soon'),
      ),
    );
  }
}