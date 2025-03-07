// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../saveSharePreferences.dart'; // Import for clipboard

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<StatefulWidget> createState() => _ContactUs();
}

class _ContactUs extends State<ContactUs> {
  @override
  void initState() {
    super.initState();
  }

  // Modified launchEmail method with clipboard copy fallback
  Future<void> launchEmail() async {
    final Uri gmailUri = Uri(
      scheme: 'intent',
      path: 'mailto:programmerprodigiese@gmail.com',
    );

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(
          gmailUri,
          mode: LaunchMode.externalApplication, // Launch using external app
        );
      } else {
        // If unable to launch email, copy the email address to clipboard
        await Clipboard.setData(const ClipboardData(text: 'programmerprodigiese@gmail.com'));
        // Show a snackbar to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email address copied to clipboard. You can use it into your email app.'),
            ),
          );
        }
      }
    } catch (e) {
      // In case of error, copy the email to clipboard
      await Clipboard.setData(const ClipboardData(text: 'programmerprodigiese@gmail.com'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email address copied to clipboard. You can paste it into your email app.'),
          ),
        );
      }
      if (kDebugMode) {
        print('Error launching email: $e');
      }
    }
  }

  Future<void> launchWhatsApp() async {
    var firstName = (await getData("FirstName"))!;
    var lastname = (await getData("LastName"))!;
    String url;
    if (Platform.isIOS) {
      url = 'https://wa.me/+918849165682?text=${Uri.encodeFull("Hello,My name is $firstName $lastname.")}';
    } else {
      url = 'whatsapp://send?phone=+918849165682&text=${Uri.encodeFull("Hello,My name is $firstName $lastname.")}';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // If unable to launch email, copy the email address to clipboard
      await Clipboard.setData(const ClipboardData(text: '+91 8849165682'));
      // Show a snackbar to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number copied you can save the number and do message on that number.'),
          ),
        );
      }
      throw 'Could not launch $url';
    }
  }

  Future<void> makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+918849165682',
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error making phone call: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2a446b),
        title: const Text(
          'Contact',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text(
                  'Phone: ',
                  style: TextStyle(fontSize: 16.0),
                ),
                TextButton(
                  onPressed: makePhoneCall,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  child: const Text(
                    '+91 8849165682',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                      decorationThickness: 2.0,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Text(
                  'Whatsapp: ',
                  style: TextStyle(fontSize: 16.0),
                ),
                TextButton(
                  onPressed: launchWhatsApp,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  child: const Text(
                    '+91 8849165682',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                      decorationThickness: 2.0,
                    ),
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Text(
                  'Email: ',
                  style: TextStyle(fontSize: 17.0),
                ),
                TextButton(
                  onPressed: launchEmail,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  child: const Text(
                    'programmerprodigiese@gmail.com',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                      decorationThickness: 2.0,
                      fontSize: 17,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
