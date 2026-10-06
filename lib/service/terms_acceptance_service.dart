import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/food_safety_agreement.dart';
import 'package:restaurant/models/user_model.dart';

class TermsAcceptanceService {
  static const String adminEmail = 'sumit.mittal@tangzo.in';

  /// Loads the official agreement PDF from assets for email attachment.
  static Future<File> getAgreementPdfFile() async {
    final data = await rootBundle.load(FoodSafetyAgreement.assetPdfPath);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${FoodSafetyAgreement.pdfFileName}');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return file;
  }

  static Future<void> sendAcceptanceEmails({required UserModel user, required File pdfFile}) async {
    final name = user.fullName().trim().isEmpty ? 'Restaurant owner' : user.fullName().trim();
    final acceptedAt = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final subject = 'Food Safety Agreement Accepted - Tangzo Restaurant';
    final body = '''
<p>Hello,</p>
<p><strong>$name</strong> has accepted the Tangzo Restaurant Partner Food Safety, FSSAI Compliance, Indemnity &amp; Delivery Responsibility Agreement (${FoodSafetyAgreement.ref}).</p>
<ul>
  <li>Name: $name</li>
  <li>Email: ${user.email ?? '-'}</li>
  <li>Phone: ${user.countryCode ?? ''} ${user.phoneNumber ?? ''}</li>
  <li>Accepted on: $acceptedAt</li>
  <li>Agreement Ref: ${FoodSafetyAgreement.ref}</li>
</ul>
<p>A copy of the Agreement is attached as a PDF.</p>
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
      attachmentName: FoodSafetyAgreement.pdfFileName,
    );
  }
}
