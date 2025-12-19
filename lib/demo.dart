import 'dart:async';
import 'dart:convert';
import 'package:adminvisitorapp/screenpage/commomvisite.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:adminvisitorapp/data_sheet.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:adminvisitorapp/screenpage/reports.dart';
import 'package:adminvisitorapp/screenpage/updates&newspage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Logout = logout();
  List<Map<String, dynamic>> userdata = [];

  String _time = "";
  String _date = "";
  String _temperature = "--";
  IconData _weatherIcon = Icons.cloud;
  Timer? _timer;
  final String apiKey = "36022fdb7a64ba2d597c36c3d6a56928";
  final String city = "Kolkata";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) => _updateTime());
    _fetchWeather();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http
          .get(Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userdata = List<Map<String, dynamic>>.from(data["stock"]);
        });
      }
    } catch (e) {
      print("User fetch error: $e");
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time = DateFormat('hh:mm a').format(now);
      _date = DateFormat('EEE, MMM d, yyyy').format(now);
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temp = data["main"]["temp"].toString();
        final condition = data["weather"][0]["main"].toString();
        setState(() {
          _temperature = "$temp°C";
          _weatherIcon = _getWeatherIcon(condition);
        });
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case "clear":
        return Icons.wb_sunny_rounded;
      case "clouds":
        return Icons.cloud;
      case "rain":
        return Icons.water_drop;
      default:
        return Icons.cloud_queue;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _cardButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
    double height = 140,
    double width = 300,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 5))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 30,
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, size: 30, color: color)),
              SizedBox(width: 20),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget combinedInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Time
          Column(
            children: [
              Icon(Icons.access_time, color: Colors.blueAccent, size: 25),
              SizedBox(height: 8),
              Text("Time", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54,fontSize: 12)),
              SizedBox(height: 4),
              Text(_time,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          // Date
          Column(
            children: [
              Icon(Icons.calendar_today, color: Colors.orangeAccent, size: 25),
              SizedBox(height: 8),
              Text("Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54,fontSize: 12)),
              SizedBox(height: 4),
              Text(_date,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87,)),
            ],
          ),
          // Temperature
          Column(
            children: [
              Icon(_weatherIcon, color: Colors.redAccent, size: 25),
              SizedBox(height: 8),
              Text("Temp", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              SizedBox(height: 4),
              Text(_temperature,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),  
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
      body: Column(
        children: [
          // // AppBar
          // Container(
          //   height: 160,
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [Color(0xff1cae81), Color(0xff1cae81)],
          //     ),
          //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text('VISITECH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          //             Text('Security is here', style: TextStyle(color: Colors.white)),
          //           ],
          //         ),
          //         Row(
          //           children: [
          //             Image.asset('assets/images/logo.png', width: 60, height: 60),
          //             IconButton(
          //               icon: Icon(Icons.logout, color: Colors.black),
          //               onPressed: () => Logout.signout(context),
          //             )
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
       combinedInfoCard(),
          // Overlapping Quick Action Cards
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(16),
              children: [
                _cardButton(
                  title: "Updates & News",
                  icon: Icons.person,
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => updatenewspage())),
                ),
                SizedBox(width: 20),
                _cardButton(
                  title: "Reports",
                  icon: Icons.report,
                  color: Colors.green,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => reportpage())),
                ),
                SizedBox(width: 20),
                _cardButton(
                  title: "Alerts",
                  icon: Icons.notifications,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => alertsdashboard())),
                ),
              ],
            ),
          ),
      
          // Info Card
         
      
          // Buttons
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                   _cardButton(
                    title: "Common Visitors",
                    icon: Icons.person,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => commomvisitorpage())),
                    width: double.infinity,
                    height: 65,
                  ),
                  _cardButton(
                    title: "Host List",
                    icon: Icons.person,
                    color: Colors.deepPurple,
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => datasheetpage())),
                    width: double.infinity,
                    height: 65,
                  ),
                  _cardButton(
                    title: "Request",
                    icon: Icons.file_open,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AppVisitRequestPage(visitors: userdata)),
                    ),
                    width: double.infinity,
                    height: 65,
                  ),
                  _cardButton(
                    title: "Alerts",
                    icon: Icons.settings,
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => alertsdashboard())),
                    width: double.infinity,
                    height: 65,
                  ),
                  _cardButton(
                    title: "V-History",
                    icon: Icons.history,
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => historypage())),
                    width: double.infinity,
                    height: 65,
                  ),
                ],
              ),
            ),
          ),
        ],
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppVisitRequestPage(visitors: userdata)));
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
