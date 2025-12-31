import 'dart:async';
import 'dart:convert';
import 'package:adminvisitorapp/screenpage/pumphistory.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class reportpage extends StatefulWidget {
  const reportpage({super.key});

  @override
  State<reportpage> createState() => _reportpageState();
}

class _reportpageState extends State<reportpage> {
  // ================= STATE =================
  bool _isPump1Running = false;
  bool _isPump2Running = false;

  int _pump1Seconds = 0;
  int _pump2Seconds = 0;

  Timer? _pump1Timer;
  Timer? _pump2Timer;

  String? pump1RunId;
  String? pump2RunId;

  DateTime? pump1StartTime;
  DateTime? pump2StartTime;

  // ================= FETCH =================
  Future<void> fetchpumpdata() async {
    debugPrint('🔵 FETCH pump data');

    final url = Uri.parse('https://ancoinnovation.com/visitor/pump_fetch.php');

    try {
      final response = await http.get(url);
      debugPrint('📡 FETCH ${response.statusCode}');
      debugPrint('📡 BODY ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List stock = data['stock'];

        for (var pump in stock) {
          if (pump['end_time'] == "" || pump['end_time'] == null) {
            DateTime start = DateTime.parse(pump['start_time']);
            int seconds = DateTime.now().difference(start).inSeconds;

            debugPrint(
                '⏱ RUNNING ${pump['pump_name']} | ID ${pump['id']} | SECONDS $seconds');

            if (pump['pump_name'] == "StartpumpOne") {
              setState(() {
                pump1RunId = pump['id'];
                pump1StartTime = start;
                _pump1Seconds = seconds;
                _isPump1Running = true;
              });
              _startPumpTimer(1);
            }

            if (pump['pump_name'] == "StartpumpTwo") {
              setState(() {
                pump2RunId = pump['id'];
                pump2StartTime = start;
                _pump2Seconds = seconds;
                _isPump2Running = true;
              });
              _startPumpTimer(2);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ FETCH ERROR $e');
    }
  }

  // ================= START API =================
  Future<void> startPumpApi(String pumpName, int pumpNumber) async {
    debugPrint('🟢 START $pumpName');

    final url = Uri.parse('https://ancoinnovation.com/visitor/pump_start.php');
    String startTime = DateTime.now().toIso8601String();

    try {
      final response = await http.post(
        url,
        body: {'pump_name': pumpName, 'start_time': startTime},
      );

      debugPrint('📡 START ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          if (pumpNumber == 1) {
            pump1RunId = data['id'];
            pump1StartTime = DateTime.now();
            _pump1Seconds = 0; // 🔥 start from zero
            _isPump1Running = true;
          } else {
            pump2RunId = data['id'];
            pump2StartTime = DateTime.now();
            _pump2Seconds = 0; // 🔥 start from zero
            _isPump2Running = true;
          }
        });
      }
    } catch (e) {
      debugPrint('❌ START ERROR $e');
    }
  }

  // ================= STOP API =================
  Future<void> stopPumpApi(String runId) async {
    debugPrint('🔴 STOP ID $runId');

    final url = Uri.parse('https://ancoinnovation.com/visitor/pump_stop.php');
    String endTime = DateTime.now().toIso8601String();

    try {
      await http.post(
        url,
        body: {'id': runId, 'end_time': endTime},
      );
    } catch (e) {
      debugPrint('❌ STOP ERROR $e');
    }
  }

  // ================= TIMER (COUNT UP) =================
  void _startPumpTimer(int pumpNumber) {
    debugPrint('⏱ TIMER START pump $pumpNumber');

    if (pumpNumber == 1) {
      _pump1Timer?.cancel();
      _pump1Timer =
          Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _pump1Seconds++);
      });
    } else {
      _pump2Timer?.cancel();
      _pump2Timer =
          Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _pump2Seconds++);
      });
    }
  }

  // ================= START / STOP =================
  void _startPump(int pumpNumber) {
    if (pumpNumber == 1) {
      startPumpApi("StartpumpOne", 1);
      _startPumpTimer(1);
    } else {
      startPumpApi("StartpumpTwo", 2);
      _startPumpTimer(2);
    }
  }

  void _stopPump(int pumpNumber) {
    if (pumpNumber == 1 && pump1RunId != null) {
      stopPumpApi(pump1RunId!);
      _pump1Timer?.cancel();
      setState(() {
        _isPump1Running = false;
        _pump1Seconds = 0;
        pump1RunId = null;
        pump1StartTime = null;
      });
    }

    if (pumpNumber == 2 && pump2RunId != null) {
      stopPumpApi(pump2RunId!);
      _pump2Timer?.cancel();
      setState(() {
        _isPump2Running = false;
        _pump2Seconds = 0;
        pump2RunId = null;
        pump2StartTime = null;
      });
    }
  }

  // ================= FORMAT =================
  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return "-- --";
    return "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.year} "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')}";
  }

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    fetchpumpdata();
  }

  @override
  void dispose() {
    _pump1Timer?.cancel();
    _pump2Timer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  Widget _pumpCard(
    String title,
    bool isRunning,
    int seconds,
    DateTime? startTime,
    VoidCallback onStart,
    VoidCallback onStop,
  ) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              _formatDateTime(startTime),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _formatTime(seconds),
              style:
                  const TextStyle(fontSize: 30, color: Colors.blue),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? null : onStart,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text('Start'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isRunning ? onStop : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1cae81),
        title: const Text('Water Pumps'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchpumpdata,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // 🔥 important
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1cae81)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => pumphistorypage()),
                  );
                },
                child: const Text('Pump History',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 70),
              _pumpCard(
                "Pump 1",
                _isPump1Running,
                _pump1Seconds,
                pump1StartTime,
                () => _startPump(1),
                () => _stopPump(1),
              ),
              _pumpCard(
                "Pump 2",
                _isPump2Running,
                _pump2Seconds,
                pump2StartTime,
                () => _startPump(2),
                () => _stopPump(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
