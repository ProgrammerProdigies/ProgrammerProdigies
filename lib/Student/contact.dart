import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> launchEmail() async {
    final url = Uri.parse('mailto:programmerprodigies@gmail.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch email app. User might not have Gmail installed.';
    }
  }

  // Future<void> makePhoneCall() async {
  //   final url = Uri.parse("tel:+919016204659");
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url);
  //   } else {
  //     throw 'Could not launch phone app';
  //   }
  // }

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
            // const SizedBox(height: 8.0),
            // const Row(
            //   children: [
            //     Text(
            //       'Address:',
            //       style: TextStyle(fontSize: 16.0),
            //     ),
            //     Text(
            //       ' 123 Main Street, City, Country',
            //       style: TextStyle(fontSize: 16.0),
            //     ),
            //   ],
            // ),
            // Row(
            //   children: [
            //     const Text(
            //       'Phone: ',
            //       style: TextStyle(fontSize: 16.0),
            //     ),
            //     TextButton(
            //       onPressed: makePhoneCall,
            //       style: ButtonStyle(
            //         padding: MaterialStateProperty.all(
            //             EdgeInsets.zero), // Remove padding
            //       ),
            //       child: const Text(
            //         '+91 9016204659',
            //         style: TextStyle(
            //             color: Colors.blue,
            //             decoration: TextDecoration.underline,
            //             decorationColor: Colors.blue,
            //             decorationThickness: 2.0),
            //       ),
            //     )
            //   ],
            // ),
            Row(
              children: [
                const Text(
                  'Email: ',
                  style: TextStyle(fontSize: 17.0),
                ),
                TextButton(
                  onPressed: launchEmail,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        EdgeInsets.zero), // Remove padding
                  ),
                  child: const Text(
                    'programmerprodigies@gmail.com',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                      decorationThickness: 2.0,
                      fontSize: 17
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
