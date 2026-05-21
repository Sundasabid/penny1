import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactHelper {
  static Future<List<Contact>> getContacts() async {
    if (await Permission.contacts.request().isGranted) {
      // Fetch contacts with properties (phones, etc.)
      return await FlutterContacts.getContacts(withProperties: true);
    }
    return [];
  }

  static List<Contact> filterContacts(List<Contact> contacts, String query) {
    if (query.isEmpty) return contacts;
    return contacts
        .where((contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()) ||
            contact.phones.any((phone) => phone.number.contains(query)))
        .toList();
  }
}
