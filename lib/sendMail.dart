import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<void> sendMail(Map data2) async {
  // Note that using a username and password for gmail only works if
  // you have two-factor authentication enabled and created an App password.
  // Search for "gmail app password 2fa"
  // The alternative is to use oauth.
  print("data from sendMail ${data2["FirstName"]}");
  String username = 'programmerprodigies@gmail.com';
  String password = 'yfywwsbkbnhmixha';

  final smtpServer = gmail(username, password);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username, '${data2["FirstName"]}, Welcome to Programmer Prodigies.')
    ..recipients.add(data2["Email"])
    ..subject = 'Congratulations on the Login approval.🎉🎉🎉'
    ..text = 'Now you can login with you this email address in our application and if you have created the password then use that password or else use your email address as password.';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message sent: $sendReport');
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      print('Problem: ${p.code}: ${p.msg}');
    }
  }
}
