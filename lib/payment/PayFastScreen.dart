// ignore_for_file: file_names

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/payment_model/pay_fast_model.dart';

import 'package:restaurant/widget/translated_text.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayFastScreen extends StatefulWidget {
  final String htmlData;
  final PayFastModel payFastSettingData;

  const PayFastScreen({super.key, required this.htmlData, required this.payFastSettingData});

  @override
  State<PayFastScreen> createState() => _PayFastScreenState();
}

class _PayFastScreenState extends State<PayFastScreen> {
  WebViewController controller = WebViewController();

  @override
  void initState() {
    initController();
    super.initState();
  }

  void initController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            ShowToastDialog.closeLoader();
          },
          onProgress: (int progress) {
            // Update loading bar.
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest navigation) async {
            if (kDebugMode) {
              log("--->2 $navigation");
            }
            if (navigation.url == widget.payFastSettingData.returnUrl) {
              Get.back(result: true);
            } else if (navigation.url == widget.payFastSettingData.notifyUrl) {
              Get.back(result: false);
            } else if (navigation.url == widget.payFastSettingData.cancelUrl) {
              _showMyDialog();
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString((widget.htmlData));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showMyDialog();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              _showMyDialog();
            },
            child: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: TranslatedText('Cancel Payment'),
          content: SingleChildScrollView(
            child: TranslatedText("Are you sure want to cancel payment?"),
          ),
          actions: <Widget>[
            TextButton(
              child: TranslatedText(
                'Exit',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Get.back();
                Get.back(result: false);
              },
            ),
            TextButton(
              child: TranslatedText(
                'Continue Payment',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}
