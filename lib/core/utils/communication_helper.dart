import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class CommunicationHelper {
  static Future<void> sendReminder({
    required String phoneNumber,
    required String personName,
    required double amount,
    required bool isLended,
  }) async {
    final message = isLended
        ? "Hi $personName, just a friendly reminder about the $amount you borrowed. Thanks!"
        : "Hi $personName, I'm just checking in regarding the $amount I borrowed from you.";

    final formattedPhone = _formatPhone(phoneNumber);
    final whatsappUrl = Uri.parse(
      "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}",
    );

    bool launched = false;
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        launched = true;
      }
    } catch (_) {}

    if (!launched) {
      final smsUrl = Uri.parse(
        "sms:$formattedPhone${Platform.isAndroid ? '?' : '&'}body=${Uri.encodeComponent(message)}",
      );
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl);
      }
    }
  }

  static String _formatPhone(String phone) {
    // WhatsApp wa.me links require numbers WITHOUT '+' or leading zeros
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
}
