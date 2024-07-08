import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../utils/colors.dart';
import '../../utils/strings.dart';
import 'order_create_data_values.dart';
import 'order_create_view.dart';

class ConfigPageView extends StatefulWidget {
  const ConfigPageView({super.key});

  @override
  State<ConfigPageView> createState() => _ConfigPageViewState();
}

class _ConfigPageViewState extends State<ConfigPageView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leadingWidth: navigatedFromHome ? 30 : 0,
        leading: navigatedFromHome
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: whiteColor,
                ),
                padding: EdgeInsets.zero,
              )
            : Container(),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          header2,
          style: TextStyle(
              color: whiteColor, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),
            const Text(
              settingTxt1,
              maxLines: 2,
              style: TextStyle(
                color: blackColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const Gap(8),
            DropdownButtonFormField2(
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: greyColor,
                ),
                iconEnabledColor: greyColor,
                iconDisabledColor: whiteColor,
              ),
              buttonStyleData: const ButtonStyleData(
                width: 160,
                padding: EdgeInsets.only(left: 0, right: 0),
              ),
              dropdownStyleData: DropdownStyleData(
                  maxHeight: 160,
                  padding: null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  elevation: 8,
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: MaterialStateProperty.all(4),
                  )),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyColor.shade300, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyColor.shade300, width: 2),
                ),
                filled: true,
                fillColor: whiteColor,
              ),
              value: selectedEnvironment,
              onChanged: (String? newValue) {
                setState(() {
                  setSelectedEnvironment(newValue);
                });
              },
              items: environmentTypeList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),
            const Text(
              settingTxt2,
              maxLines: 2,
              style: TextStyle(
                color: blackColor,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
            ),
            const Gap(8),
            DropdownButtonFormField2(
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: greyColor,
                ),
                iconEnabledColor: greyColor,
                iconDisabledColor: whiteColor,
              ),
              buttonStyleData: const ButtonStyleData(
                width: 160,
                padding: EdgeInsets.only(left: 0, right: 0),
              ),
              dropdownStyleData: DropdownStyleData(
                  maxHeight: 160,
                  padding: null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  elevation: 8,
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: MaterialStateProperty.all(4),
                  )),
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyColor.shade300, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: greyColor.shade300, width: 2),
                ),
                filled: true,
                fillColor: whiteColor,
              ),
              value: selectedAppExperience,
              onChanged: (String? newValue) {
                setState(() {
                  setSelectedAppExp(newValue);
                });
              },
              items: appExperienceTypeList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                );
              }).toList(),
            ),
            const Gap(20),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return;
                await onDone(selectedEnvironment, selectedAppExperience);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const OrderCreateView()));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: veryLightGreyColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                settingButtonTxt1,
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
