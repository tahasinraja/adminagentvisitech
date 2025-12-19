
import 'package:adminvisitorapp/screenpage/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class logout{
 Future<void> signout(BuildContext context)async{
final prefs= await SharedPreferences.getInstance();
await prefs.clear();
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout successfully'),backgroundColor: Colors.green,duration: Duration(seconds: 1),));
await Future.delayed(Duration(seconds: 1));
Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => loginpage(),), (route) => false,);
 }
}