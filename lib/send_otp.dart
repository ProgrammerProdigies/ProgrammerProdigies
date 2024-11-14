// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<int> sendOTP(String email) async {
  // Note that using a username and password for gmail only works if
  // you have two-factor authentication enabled and created an App password.
  // Search for "gmail app password 2fa"
  // The alternative is to use oauth.
  String username = 'programmerprodigies@gmail.com';
  String password = 'fezydjictcjxgddr';

  Random random = Random();
   int otp = 100000 + random.nextInt(900000);

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username, 'OTP to change the Password of you Programmer Prodigies account.')
    ..recipients.add(email)
    ..subject = 'OTP for Password change'
    ..text = 'Your OTP is: $otp\nFeel free to contact us in case of any other queries.';

  try {
    final sendReport = await send(message, smtpServer);
    if (kDebugMode) {
      print('Message sent: $sendReport');
    }
  } on MailerException catch (e) {
    if (kDebugMode) {
      print('Message not sent.');
    }
    for (var p in e.problems) {
      if (kDebugMode) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  return otp;
}
