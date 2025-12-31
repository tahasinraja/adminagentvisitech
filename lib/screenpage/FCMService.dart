import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';

class FCMService {
  static const String fcmUrl =
      "https://fcm.googleapis.com/v1/projects/visitorapp-36456/messages:send";

  /// Send notification via FCM HTTP v1 API
  static Future<void> sendFCM({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    if (fcmToken.isEmpty) return;

    try {
      // 1️⃣ Load service account JSON
      final serviceAccountJson =
          await rootBundle.loadString('assets/images/service-account.json');
      final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);

      // 2️⃣ Obtain access token for FCM
      final client = await clientViaServiceAccount(
        serviceAccount,
        ['https://www.googleapis.com/auth/firebase.messaging'],
      );

      // 3️⃣ Build request payload
      final Map<String, dynamic> payload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'priority': 'high',
          },
          'apns': {
            'headers': {'apns-priority': '10'},
          },
        }
      };

      // 4️⃣ Send HTTP POST
      final response = await client.post(
        Uri.parse(fcmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print("✅ FCM sent successfully");
      } else {
        print("❌ FCM failed: ${response.statusCode} ${response.body}");
      }

      client.close();
    } catch (e) {
      print("⚠️ Exception while sending FCM: $e");
    }
  }
}
