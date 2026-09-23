import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class TermsAcceptanceService {
  static const String adminEmail = 'asmwebtech.tangzo@gmail.com';

  static String htmlToPlainText(String html) {
    return cleanHtml(html)
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  static Future<File> generateTermsPdf({required UserModel user}) async {
    final fontData = await rootBundle.load('assets/fonts/Urbanist-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Urbanist-Bold.ttf');
    final PdfFont regularFont = PdfTrueTypeFont(fontData.buffer.asUint8List(), 11);
    final PdfFont titleFont = PdfTrueTypeFont(boldFontData.buffer.asUint8List(), 18);
    final PdfFont headingFont = PdfTrueTypeFont(boldFontData.buffer.asUint8List(), 12);

    final document = PdfDocument();
    document.pageSettings.margins.all = 36;
    final page = document.pages.add();
    final size = page.getClientSize();

    page.graphics.drawString(
      'Tangzo Restaurant — Terms & Conditions',
      titleFont,
      bounds: Rect.fromLTWH(0, 0, size.width, 28),
    );

    final acceptedAt = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final meta = StringBuffer()
      ..writeln('Accepted by: ${user.fullName().trim()}')
      ..writeln('Email: ${user.email ?? '-'}')
      ..writeln('Phone: ${user.countryCode ?? ''} ${user.phoneNumber ?? ''}'.trim())
      ..writeln('Accepted on: $acceptedAt');

    page.graphics.drawString(
      meta.toString(),
      headingFont,
      bounds: Rect.fromLTWH(0, 36, size.width, 70),
    );

    final termsText = htmlToPlainText(Constant.termsAndConditions);
    final element = PdfTextElement(text: termsText.isEmpty ? 'Terms & Conditions' : termsText, font: regularFont);
    element.draw(
      page: page,
      bounds: Rect.fromLTWH(0, 120, size.width, size.height - 120),
      format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
    );

    final bytes = document.saveSync();
    document.dispose();

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/Tangzo_Terms_and_Conditions.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<void> sendAcceptanceEmails({required UserModel user, required File pdfFile}) async {
    final name = user.fullName().trim().isEmpty ? 'Restaurant owner' : user.fullName().trim();
    final acceptedAt = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final subject = 'Terms & Conditions Accepted - Tangzo Restaurant';
    final body = '''
<p>Hello,</p>
<p><strong>$name</strong> has accepted the Tangzo Restaurant Terms &amp; Conditions.</p>
<ul>
  <li>Name: $name</li>
  <li>Email: ${user.email ?? '-'}</li>
  <li>Phone: ${user.countryCode ?? ''} ${user.phoneNumber ?? ''}</li>
  <li>Accepted on: $acceptedAt</li>
</ul>
<p>A copy of the Terms &amp; Conditions is attached as a PDF.</p>
<p>Thank you,<br/>Tangzo Restaurant</p>
''';

    final recipients = <String>{adminEmail};
    if (user.email != null && user.email!.trim().isNotEmpty) {
      recipients.add(user.email!.trim().toLowerCase());
    }

    await Constant.sendMail(
      subject: subject,
      body: body,
      isAdmin: false,
      recipients: recipients.toList(),
      attachments: [pdfFile],
      attachmentName: 'Tangzo_Terms_and_Conditions.pdf',
    );
  }
}
