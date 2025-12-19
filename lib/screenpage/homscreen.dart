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

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  logout Logout = logout();
  List<Map<String, dynamic>>? userdata = [];

  Future<void> Fetchuserdata() async {
    final Response = await http.get(
      Uri.parse('https://ancoinnovation.com/visitor/flat_mam_fetch.php'),
    );
    if (Response.statusCode == 200) {
      final data = jsonDecode(Response.body);
      setState(() {
        userdata = List<Map<String, dynamic>>.from(data["stock"]);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Data loaded successfully')));
    }
  }

  // Time & Weather
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
    Fetchuserdata();
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
        "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey",
      );
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

  // ------------------- Widgets -------------------
  Widget _cardButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 300,
        height: 140,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(width: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color backgroundColor = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, size: 30, color: color),
              ),
              SizedBox(width: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget combinedInfoCard({
    // required String location,
    required String time,
    required String date,
    required String temperature,
    required IconData weatherIcon,
  }) {
    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Location
          Column(
            children: [
              // Icon(Icons.location_on, color: Colors.green, size: 32),
              //    SizedBox(height: 8),
              // Text("Location", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              // SizedBox(height: 4),
              //  Text(location,
              //  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          // Time
          Column(
            children: [
              Icon(Icons.access_time, color: Colors.blueAccent, size: 32),
              SizedBox(height: 8),
              Text(
                "Time",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // Date
          Column(
            children: [
              Icon(Icons.calendar_today, color: Colors.orangeAccent, size: 32),
              SizedBox(height: 8),
              Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // Temperature
          Column(
            children: [
              Icon(weatherIcon, color: Colors.redAccent, size: 32),
              SizedBox(height: 8),
              Text(
                "Temp",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Text(
                temperature,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------- Build -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),

      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ---------------- AppBar Background ----------------
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff1cae81), Color(0xff1cae81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => Logout.signout(context),
                          icon: Icon(Icons.logout, size: 30),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'VISITECH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              'Security is here',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      Image.asset(
                        'assets/images/logo.png',
                        // fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ---------------- Overlapping Quick Action Cards ----------------
          Positioned(
            top: 170, // AppBar ke thoda neeche
            left: 0,
            right: 0,
            child: SizedBox(
              height: 160,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _cardButton(
                      title: "Updates & News",
                      icon: Icons.person,
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => updatenewspage()),
                        );
                      },
                    ),
                    SizedBox(width: 30),
                    _cardButton(
                      title: "Reports",
                      icon: Icons.report,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => reportpage()),
                        );
                      },
                    ),
                    SizedBox(width: 30),
                    _cardButton(
                      title: "Alerts",
                      icon: Icons.notifications,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => alertsdashboard()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 330, // Overlapping card ke neeche
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  combinedInfoCard(
                    // location: "",
                    time: _time,
                    date: _date,
                    temperature: _temperature,
                    weatherIcon: _weatherIcon,
                  ),

                  // infoCard("Location",'kolkata' , Icons.location_on, Colors.green),
                  // infoCard("Current Time", _time, Icons.access_time, Colors.blue),
                  // infoCard("Date", _date, Icons.calendar_today, Colors.orange),
                  // infoCard("Temperature", _temperature, _weatherIcon, Colors.redAccent),
                  SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      cardButton(
                        title: "Common Visitor",
                        icon: Icons.person,
                        color: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => commomvisitorpage(),
                            ),
                          );
                        },
                      ),
                      cardButton(
                        title: "Host List",
                        icon: Icons.person,
                        color: Colors.deepPurple,
                        backgroundColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => datasheetpage()),
                          );
                        },
                      ),
                      cardButton(
                        title: "Request",
                        icon: Icons.file_open,
                        color: Colors.teal,
                        backgroundColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AppVisitRequestPage(visitors: userdata ?? []),
                            ),
                          );
                        },
                      ),
                      cardButton(
                        title: "Alerts",
                        icon: Icons.settings,
                        color: Colors.redAccent,
                        backgroundColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => alertsdashboard(),
                            ),
                          );
                        },
                      ),
                      cardButton(
                        title: "V-History",
                        icon: Icons.history,
                        color: Colors.blueAccent,
                        backgroundColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => historypage()),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 100), // Bottom padding for scroll
                ],
              ),
            ),
          ),

          // Info Cards
          // Expanded(
          //   child: SingleChildScrollView(
          //     padding: EdgeInsets.all(16),
          //     child: Column(
          //       children: [

          //         SizedBox(height: MediaQuery.of(context).size.height ),

          //       ],
          //     ),
          //   ),
          // )
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: customBottomNavBar(0),
    );
  }

  Widget customBottomNavBar(int currentIndex) {
    List<Map<String, dynamic>> navItems = [
      {"icon": Icons.home, "label": "Home"},
      {"icon": Icons.swipe_up, "label": "Request"},
      {"icon": Icons.notifications, "label": "Alerts"},
      {"icon": Icons.history, "label": "History"},
    ];

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          bool isSelected = currentIndex == idx;

          return GestureDetector(
            onTap: () {
              // handle navigation based on index
              if (idx == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => homepage()),
                );
              } else if (idx == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AppVisitRequestPage(visitors: userdata ?? []),
                  ),
                );
              } else if (idx == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => alertsdashboard()),
                );
              } else if (idx == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => historypage()),
                );
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xffa7e9cf), Color(0xFFa7e9cf)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    )
                  : BoxDecoration(),
              child: Row(
                children: [
                  Icon(
                    item['icon'],
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                  SizedBox(width: 6),
                  if (isSelected)
                    Text(
                      item['label'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
