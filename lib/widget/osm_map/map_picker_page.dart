import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';
import 'package:restaurant/utils/translation_notifier.dart';

import 'package:restaurant/widget/osm_map/map_controller.dart';
import 'package:restaurant/widget/translated_text.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: TranslatedText(
          "PickUp Location",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.pickedPlace.value?.coordinates ?? LatLng(20.5937, 78.9629), // Default India center
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  controller.addLatLngOnly(latlng);
                  controller.mapController.move(latlng, controller.mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: Platform.isAndroid ? 'com.foodies.restaurant.restaurant' : 'com.foodies.restaurant.restaurant',
                ),
                MarkerLayer(
                  markers: controller.pickedPlace.value != null
                      ? [
                          Marker(
                            point: controller.pickedPlace.value!.coordinates,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_pin,
                              size: 36,
                              color: AppThemeData.secondary300,
                            ),
                          ),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: ValueListenableBuilder(
                      valueListenable: TranslationNotifier.refresh,
                      builder: (_, __, ___) {
                        return TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search location...'.tr,
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: controller.searchPlace,
                        );
                      }),
                ),
                Obx(() {
                  if (controller.searchResults.isEmpty) return SizedBox.shrink();

                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final place = controller.searchResults[index];
                        return ListTile(
                          title: TranslatedText(place['display_name']),
                          onTap: () {
                            controller.selectSearchResult(place);
                            final lat = double.parse(place['lat']);
                            final lon = double.parse(place['lon']);
                            final pos = LatLng(lat, lon);
                            controller.mapController.move(pos, 15);
                            searchController.text = place['display_name'];
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16),
          color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TranslatedText(
                controller.pickedPlace.value != null ? "Picked Location:" : "No Location Picked",
                style: TextStyle(
                  color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                  fontFamily: AppThemeData.semiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (controller.pickedPlace.value != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: TranslatedText(
                    "${controller.pickedPlace.value!.address}\n(${controller.pickedPlace.value!.coordinates.latitude.toStringAsFixed(5)}, ${controller.pickedPlace.value!.coordinates.longitude.toStringAsFixed(5)})",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Confirm Location",
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      height: 5,
                      onPress: () async {
                        final selected = controller.pickedPlace.value;
                        if (selected != null) {
                          Get.back(result: selected); // ✅ Return the selected place
                          print("Selected location: $selected");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: controller.clearAll,
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
