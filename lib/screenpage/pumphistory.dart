import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class pumphistorypage extends StatefulWidget {
  const pumphistorypage({super.key});

  @override
  State<pumphistorypage> createState() => _pumphistorypageState();
}

class _pumphistorypageState extends State<pumphistorypage> {
  List historyList = [];
  bool isLoading = false;

  // ================= FETCH HISTORY =================
  Future<void> fetchpumpdata() async {
    debugPrint('🔄 FETCH HISTORY');

    setState(() => isLoading = true);

    final url =
        Uri.parse('https://ancoinnovation.com/visitor/pump_fetch.php');

    try {
      final response = await http.get(url);
      debugPrint('📡 STATUS: ${response.statusCode}');
      debugPrint('📦 BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          historyList = data['stock'] ?? [];
        });

        for (var item in historyList) {
          debugPrint(
              '🧾 ID:${item['id']} | ${item['pump_name']} | START:${item['start_time']} | END:${item['end_time']}');
        }
      }
    } catch (e) {
      debugPrint('❌ ERROR: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchpumpdata();
  }

  // ================= TIME CALCULATION =================
  String calculateDuration(String startTime, String? endTime) {
    DateTime start = DateTime.parse(startTime);
    DateTime end =
        (endTime == null || endTime.isEmpty) ? DateTime.now() : DateTime.parse(endTime);

    Duration diff = end.difference(start);

    String h = diff.inHours.toString().padLeft(2, '0');
    String m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    String s = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return "$h:$m:$s";
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1cae81),
        title: const Text('Pump History'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchpumpdata,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : historyList.isEmpty
                ?  ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 300),
                      Center(child: Text('No History Found')),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      final bool isRunning =
                          item['end_time'] == null || item['end_time'] == "";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            isRunning
                                ? Icons.play_circle_fill
                                : Icons.stop_circle,
                            color: isRunning ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          title: Text(
                            item['pump_name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Start : ${item['start_time']}"),
                              Text(
                                  "End   : ${isRunning ? 'Running' : item['end_time']}"),
                              Text(
                                "Duration : ${calculateDuration(item['start_time'], item['end_time'])}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          trailing: Text(
                            "ID ${item['id']}",
                            style:
                                const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
