import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/payment_model/flutter_wave_model.dart';
import 'package:restaurant/models/payment_model/paypal_model.dart';
import 'package:restaurant/models/payment_model/razorpay_model.dart';
import 'package:restaurant/models/payment_model/stripe_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/models/wallet_transaction_model.dart';
import 'package:restaurant/models/withdraw_method_model.dart';
import 'package:restaurant/models/withdrawal_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WalletController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> amountTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> noteTextFieldController = TextEditingController().obs;

  Rx<UserModel> userModel = UserModel().obs;
  RxList<WalletTransactionModel> walletTransactionList = <WalletTransactionModel>[].obs;
  RxList<WithdrawalModel> withdrawalList = <WithdrawalModel>[].obs;

  RxInt selectedTabIndex = 0.obs;
  RxInt selectedValue = 0.obs;

  Rx<WithdrawMethodModel> withdrawMethodModel = WithdrawMethodModel().obs;

  Rx<RazorPayModel> razorPayModel = RazorPayModel().obs;
  Rx<PayPalModel> paypalDataModel = PayPalModel().obs;
  Rx<StripeModel> stripeSettingData = StripeModel().obs;
  Rx<FlutterWaveModel> flutterWaveSettingData = FlutterWaveModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getWalletTransaction(false);

    super.onInit();
  }

  Future<void> createAndSavePdf() async {
    try {
      // Load Unicode font
      final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final PdfFont unicodeFont = PdfTrueTypeFont(fontData.buffer.asUint8List(), 10);

      // Create PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      final PdfGrid grid = PdfGrid();
      grid.columns.add(count: 4);

      // Apply font to entire grid
      grid.style = PdfGridStyle(
        font: unicodeFont,
        cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
      );

      // Header
      grid.headers.add(1);
      final header = grid.headers[0];
      header.style = PdfGridRowStyle(
        font: PdfTrueTypeFont(fontData.buffer.asUint8List(), 11),
      );

      header.cells[0].value = 'Description';
      header.cells[1].value = 'Order Id';
      header.cells[2].value = 'Amount';
      header.cells[3].value = 'Date';

      // Rows
      for (var element in walletTransactionList) {
        final row = grid.rows.add();
        row.cells[0].value = element.note ?? '';
        row.cells[1].value = element.orderId == null ? '' : Constant.orderId(orderId: element.orderId.toString());

        // ₹ symbol now SAFE ✅
        row.cells[2].value = Constant.amountShow(amount: element.amount.toString());

        row.cells[3].value = Constant.timestampToDateTime(element.date!);
      }

      grid.draw(
        page: page,
        bounds: const Rect.fromLTWH(0, 0, 0, 0),
      );

      final bytes = document.saveSync();
      document.dispose();

      File file;

      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }

        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        file = File('${directory.path}/statement_${DateTime.now().millisecondsSinceEpoch}.pdf');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        file = File('${directory.path}/statement_${DateTime.now().millisecondsSinceEpoch}.pdf');
      }

      await file.writeAsBytes(bytes, flush: true);

      ShowToastDialog.showToast("Statement downloaded successfully");
    } catch (e) {
      debugPrint('PDF Error: $e');
      ShowToastDialog.showToast("Failed to download statement");
    }
  }

  RxDouble orderAmount = 0.0.obs;
  RxDouble taxAmount = 0.0.obs;

  Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 1)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  RxBool isWithdrawBTnEnabled = true.obs;
  RxString userId = ''.obs;
  Future<void> getWalletTransaction(bool isFilter) async {
    if (isFilter) {
      await FireStoreUtils.getFilterWalletTransaction(Timestamp.fromDate(DateTime(startDate.value.year, startDate.value.month, startDate.value.day, 00, 00)),
              Timestamp.fromDate(DateTime(endDate.value.year, endDate.value.month, endDate.value.day, 23, 59)))
          .then(
        (value) {
          if (value != null) {
            taxAmount.value = 0;
            orderAmount.value = 0;
            walletTransactionList.value = value;

            walletTransactionList.where((element) => element.paymentMethod == "tax").toList();
            for (var element in walletTransactionList) {
              if (element.orderId != null && element.orderId != '') {
                if (element.paymentMethod == "tax") {
                  if (element.isTopup == false) {
                    taxAmount.value -= double.parse(element.amount.toString());
                  } else {
                    taxAmount.value += double.parse(element.amount.toString());
                  }
                } else {
                  if (element.isTopup == false) {
                    orderAmount.value -= double.parse(element.amount.toString());
                  } else {
                    orderAmount.value += double.parse(element.amount.toString());
                  }
                }
              }
            }
          }
        },
      );
    } else {
      await FireStoreUtils.getWalletTransaction().then(
        (value) {
          if (value != null) {
            taxAmount.value = 0;
            orderAmount.value = 0;
            walletTransactionList.value = value;

            walletTransactionList.where((element) => element.paymentMethod == "tax").toList();
            for (var element in walletTransactionList) {
              if (element.orderId != null && element.orderId != '') {
                if (element.paymentMethod == "tax") {
                  if (element.isTopup == false) {
                    taxAmount.value -= double.parse(element.amount.toString());
                  } else {
                    taxAmount.value += double.parse(element.amount.toString());
                  }
                } else {
                  if (element.isTopup == false) {
                    orderAmount.value -= double.parse(element.amount.toString());
                  } else {
                    orderAmount.value += double.parse(element.amount.toString());
                  }
                }
              }
            }
          }
        },
      );
    }

    await FireStoreUtils.getWithdrawHistory().then(
      (value) {
        if (value != null) {
          withdrawalList.value = value;
        }
      },
    );
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    await getPaymentMethod();
    isLoading.value = false;
  }

  Future<void> getPaymentMethod() async {
    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("razorpaySettings").get().then((user) {
      try {
        razorPayModel.value = RazorPayModel.fromJson(user.data() ?? {});
      } catch (e) {
        debugPrint('FireStoreUtils.getUserByID failed to parse user object ${user.id}');
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("paypalSettings").get().then((paypalData) {
      try {
        paypalDataModel.value = PayPalModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("stripeSettings").get().then((paypalData) {
      try {
        stripeSettingData.value = StripeModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });

    await FireStoreUtils.fireStore.collection(CollectionName.settings).doc("flutterWave").get().then((paypalData) {
      try {
        flutterWaveSettingData.value = FlutterWaveModel.fromJson(paypalData.data() ?? {});
      } catch (error) {
        debugPrint(error.toString());
      }
    });
    if (Constant.userModel?.role == Constant.userRoleEmployee) {
      VendorModel? vendorModel = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID!);
      userId.value = vendorModel?.author ?? '';
    } else {
      userId.value = FireStoreUtils.getCurrentUid();
    }
    await FireStoreUtils.getWithdrawMethod(userId: userId.value).then(
      (value) {
        if (value != null) {
          withdrawMethodModel.value = value;
        }
      },
    );
  }
}
