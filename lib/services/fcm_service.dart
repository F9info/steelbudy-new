import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:steel_buddy/services/api_service.dart';
import 'dart:io';

class FCMService {
  static Future<void> setupFCM({
    required String userId,
    required BuildContext context,
  }) async {
    // Request permissions (iOS/Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token;
      if (Platform.isIOS) {
        String? apnsToken;
        int retries = 0;
        while (apnsToken == null && retries < 10) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          debugPrint('APNS Token (try $retries): $apnsToken');
          retries++;
        }
        if (apnsToken != null) {
          token = await FirebaseMessaging.instance.getToken();
        } else {
          debugPrint(
              'APNS token was not set after waiting. Skipping FCM token registration.');
        }
      } else {
        token = await FirebaseMessaging.instance.getToken();
      }
      if (token != null) {
        debugPrint('FCM Token: $token');
        await ApiService.sendDeviceTokenToBackend(userId, token);
      }
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      ApiService.sendDeviceTokenToBackend(userId, newToken);
    });

    // Handle notification tap (foreground/background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['enquiry_id'] != null) {
        Navigator.pushNamed(context, '/enquiry-details',
            arguments: message.data['enquiry_id']);
      }
    });

    // Handle notification tap (terminated)
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage?.data['enquiry_id'] != null) {
      Navigator.pushNamed(context, '/enquiry-details',
          arguments: initialMessage!.data['enquiry_id']);
    }
  }
}
