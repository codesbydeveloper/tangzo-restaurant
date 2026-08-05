import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:restaurant/app/Home_screen/home_screen.dart';
import 'package:restaurant/app/dine_in_order_screen/dine_in_order_screen.dart';
import 'package:restaurant/app/product_screens/product_list_screen.dart';
import 'package:restaurant/app/profile_screen/profile_screen.dart';
import 'package:restaurant/app/wallet_screen/wallet_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/tax_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList<NavigationItem> navigationItems = <NavigationItem>[].obs;

  @override
  void onInit() {
    getVendor();
    setNavigationItems();
    super.onInit();
  }

  void setNavigationItems() {
    final baseItems = <NavigationItem>[
      const NavigationItem(
        label: "Home",
        iconPath: "assets/icons/ic_home.svg",
        page: HomeScreen(),
      ),
      if (Constant.isDineInEnable)
        NavigationItem(
          label: "Dine in",
          iconPath: "assets/icons/ic_dinein.svg",
          page: const DineInOrderScreen(),
          permissionModule: "Dine in Request",
        ),
      NavigationItem(
        label: "Products",
        iconPath: "assets/icons/ic_knife_fork.svg",
        page: const ProductListScreen(),
        permissionModule: "Manage Products",
      ),
      NavigationItem(
        label: "Wallet",
        iconPath: "assets/icons/ic_wallet.svg",
        page: const WalletScreen(),
        permissionModule: "Wallet",
      ),
      const NavigationItem(
        label: "Profile",
        iconPath: "assets/icons/ic_profile.svg",
        page: ProfileScreen(),
      ),
    ];

    // filter by permission
    navigationItems.value = baseItems.where((item) {
      if (item.permissionModule == null) return true;
      return Constant.getEmployeeRolePermission(module: item.permissionModule!) == true;
    }).toList();
  }

  Rx<VendorModel?> venderModel = VendorModel().obs;

  Future<void> getVendor() async {
    if (Constant.userModel?.vendorID?.isNotEmpty == true) {
      venderModel.value = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID!);
      if (venderModel.value?.id?.isNotEmpty == true) {
        Constant.vendorAdminCommission = venderModel.value?.adminCommission;
      }
      await FireStoreUtils.getTaxList(double.parse(venderModel.value!.latitude.toString()), double.parse(venderModel.value!.longitude.toString())).then((value) {
        Constant.taxProductList = value!.where((TaxModel taxModel) => taxModel.scope == "product").toList();
      });
    }
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}

class NavigationItem {
  final String label;
  final String iconPath;
  final Widget page;
  final String? permissionModule;

  const NavigationItem({
    required this.label,
    required this.iconPath,
    required this.page,
    this.permissionModule,
  });
}
