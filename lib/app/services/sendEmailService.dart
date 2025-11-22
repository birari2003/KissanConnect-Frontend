import 'dart:async';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // SMTP configuration (Brevo SMTP Relay)
  // Provided credentials
  static const String _smtpHost = 'smtp-relay.brevo.com';
  static const int _smtpPort = 587; // STARTTLS
  // Brevo SMTP login (not necessarily the same as the From address)
  static const String _smtpUsername = '9b6ff6001@smtp-brevo.com';
  static const String _smtpPassword =
      'xsmtpsib-ec0deaa7ced6fe8ae4d322809c4ac0a0a8504190a6ca0e7ef87c29277aec8a6b-zMrNaei9dcNmWd44';

  // Default from details (can be overridden by the UI)
  static const String _defaultFromAddress = 'gauravbirari690@gmail.com';
  static const String _defaultFromName = 'Smart Shetkari';

  static Future<bool> sendEmail({
    required String toEmail,
    required String subject,
    required String message,
    String? senderEmail,
    String? senderName,
  }) async {
    final fromEmail = senderEmail?.trim().isNotEmpty == true
        ? senderEmail!.trim()
        : _defaultFromAddress;
    final fromName = senderName?.trim().isNotEmpty == true
        ? senderName!.trim()
        : _defaultFromName;

    final htmlContent = '<p>${message.replaceAll('\n', '<br>')}</p>';

    // Configure SMTP server (STARTTLS on port 587)
    final smtpServer = SmtpServer(
      _smtpHost,
      port: _smtpPort,
      username: _smtpUsername,
      password: _smtpPassword,
      // mailer enables STARTTLS automatically on port 587 when available
      // ssl: false is implicit; do not force SSL on 587
    );

    final mail = Message()
      ..from = Address(fromEmail, fromName)
      ..recipients.add(toEmail)
      ..subject = subject
      ..html = htmlContent;

    try {
      final sendReport = await send(mail, smtpServer);
      // If no exception, treat as success
      print('✅ Email sent via SMTP. Report: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('❌ SMTP send failed. Problems:');
      if (e.problems.isEmpty) {
        print(' - (no detailed problems reported)');
      }
      for (final p in e.problems) {
        print(' - code: ${p.code}, msg: ${p.msg}');
      }
      print('Exception: $e');
      return false;
    } on SocketException catch (e) {
      print('❌ Network error while connecting to SMTP server: $e');
      return false;
    } on TimeoutException catch (e) {
      print('❌ SMTP connection timed out: $e');
      return false;
    } catch (e) {
      print('⚠️ Unexpected error while sending email via SMTP: $e');
      return false;
    }
  }
}

