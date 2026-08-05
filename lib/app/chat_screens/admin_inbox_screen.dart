import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/chat_screens/chat_screen.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/advertisement_model.dart';
import 'package:restaurant/models/inbox_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:restaurant/widget/firebase_pagination/src/models/view_type.dart';
import 'package:restaurant/widget/translated_text.dart';

class AdminInboxScreen extends StatelessWidget {
  const AdminInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: TranslatedText(
          "Admin Chat Inbox",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
      ),
      body: FirestorePagination(
        query: FireStoreUtils.fireStore
            .collection(CollectionName.chat)
            .where("sender_receiver_id", arrayContains: FireStoreUtils.getCurrentUid())
            .where("chatType", isEqualTo: 'admin')
            .orderBy('createdAt', descending: true),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, documentSnapshots, index) {
          final data = documentSnapshots[index].data() as Map<String, dynamic>?;
          InboxModel inboxModel = InboxModel.fromJson(data!);
          return InkWell(
            splashColor: Colors.transparent,
            onTap: () async {
              ShowToastDialog.showLoader("Please wait");
              UserModel? restaurant = await FireStoreUtils.getUserProfile(Constant.userModel?.id ?? '');

              ShowToastDialog.closeLoader();

              Get.to(const ChatScreen(), arguments: {
                "sectionType": 'adv',
                "senderName": restaurant!.fullName(),
                "senderId": Constant.userModel?.id,
                "senderProfileUrl": restaurant.profilePictureURL,
                "orderId": inboxModel.orderId,
                "receivedName": 'Admin',
                "receivedId": 'admin',
                "receivedProfileUrl": '',
                "token": null,
                "chatType": 'admin',
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Container(
                decoration: ShapeDecoration(
                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                      future: FireStoreUtils.getAdvertisementById(advertisementId: inboxModel.orderId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          AdvertisementModel advertisementModel = snapshot.data!;
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: NetworkImageWidget(
                                  imageUrl: advertisementModel.profileImage.toString(),
                                  fit: BoxFit.cover,
                                  height: Responsive.height(6, context),
                                  width: Responsive.width(12, context),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TranslatedText(
                                            "${advertisementModel.title}",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        TranslatedText(
                                          Constant.timestampToDate(inboxModel.createdAt!),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TranslatedText(
                                      "${inboxModel.lastMessage}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.medium,
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                child: Container(
                                  color: AppThemeData.grey300,
                                  height: Responsive.height(6, context),
                                  width: Responsive.width(12, context),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TranslatedText(
                                            "Loading...",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.semiBold,
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                            ),
                                          ),
                                        ),
                                        TranslatedText(
                                          Constant.timestampToDate(inboxModel.createdAt!),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.regular,
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TranslatedText(
                                      "...",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.medium,
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
              ),
            ),
          );
        },
        shrinkWrap: true,
        onEmpty: Constant.showEmptyView(message: "No conversion found"),

        //Change types customerId
        initialLoader: Constant.loader(),
        // to fetch real-time data
        isLive: true,
        viewType: ViewType.list,
      ),
    );
  }
}
