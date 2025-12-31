import 'dart:async';
import 'dart:convert';

import 'package:adminvisitorapp/demo.dart';
import 'package:adminvisitorapp/historypage.dart';
import 'package:adminvisitorapp/screenpage/addcommonperson.dart';
import 'package:adminvisitorapp/screenpage/alertsdashboard.dart';
import 'package:adminvisitorapp/screenpage/appvisiterrequst.dart';
import 'package:adminvisitorapp/screenpage/attendence.dart';

import 'package:adminvisitorapp/screenpage/imageview.dart';
import 'package:adminvisitorapp/screenpage/logoutclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class commomvisitorpage extends StatefulWidget {
  const commomvisitorpage({super.key});

  @override
  State<commomvisitorpage> createState() => _commomvisitorpageState();
}

class _commomvisitorpageState extends State<commomvisitorpage> {
  logout Logout = logout();

  @override
  void initState() {
    super.initState();

    Fetchuserdata();
  }

  // searching function
  List<Map<String, dynamic>> filterlist = [];

  TextEditingController searchcontroller = TextEditingController();

  void fetchsearch(String query) {
    List<Map<String, dynamic>>? results = [];
    if (query.isEmpty) {
      results = userdata; // agar khali to full datta/list showing
    } else {
      results = userdata
          ?.where(
            (item) =>
                item['name'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                item['phone'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                item['flat'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
      setState(() {
        filterlist = results!;
      });
    }
  }



  List<Map<String, dynamic>>? userdata = [];

  // fetch user data
  Future<void> Fetchuserdata() async {
    final Response = await http.get(
      Uri.parse('https://ancoinnovation.com/visitor/fetch_common_people.php'),
    );
    if (Response.statusCode == 200) {
      final data = jsonDecode(Response.body);
      setState(() {
        userdata = List<Map<String, dynamic>>.from(data["people"]);
        filterlist = userdata!;
      });
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Succefully data loaded')));
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

      // Visitor data section
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Box
            TextField(
              onChanged: fetchsearch,
              controller: searchcontroller,
              decoration: InputDecoration(
                hintText: 'Enter person name / phone',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchcontroller.clear();
                    fetchsearch('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📋 Visitor List
            Expanded(
              child: RefreshIndicator(
                onRefresh: Fetchuserdata,
                child: filterlist.isEmpty
                    // 🔹 EMPTY STATE (Refresh works)
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'No common visitors found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    // 🔹 VISITOR LIST
                    : ListView.builder(
                        itemCount: filterlist.length,
                        itemBuilder: (context, index) {
                          final visitor = filterlist[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      attendencepage(id: visitor['id']),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🖼 Visitor Image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PhotoViewPage(
                                              imageUrl: visitor['image'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        width: 90,
                                        height: 90,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            visitor['image'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.person,
                                                  size: 50,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // 📄 Visitor Details (Overflow Safe)
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //   'ID number: ${visitor['id'] ?? ''}',
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     color: Colors.grey.shade600,
                                          //   ),
                                          // ),
                                          Text(
                                            visitor['name'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            visitor['email'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            visitor['phone'] ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(height: 10),

                                       
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
            MaterialPageRoute(builder: (context) => addcommonpersonpage()),
          );
        },
        icon: CircleAvatar(
          radius: 40,
          child: Lottie.asset(
            'assets/images/iFlribWNhe.json',
            fit: BoxFit.cover,
          ),
        ),
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
              if (idx == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Homepage()),
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
                        colors: [Color(0xff1cae81), Color(0xff1cae81)],
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
                  if (isSelected) ...[
                    SizedBox(width: 6),
                    Text(
                      item['label'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
