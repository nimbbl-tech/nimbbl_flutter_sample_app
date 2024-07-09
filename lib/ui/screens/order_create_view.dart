import 'package:dotted_line/dotted_line.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:nimbbl_flutter_sample_app/api/network_helper.dart';
import 'package:nimbbl_flutter_sample_app/api/result.dart';
import 'package:nimbbl_flutter_sample_app/ui/screens/order_success_view.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_options.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/utils/api_utils.dart';

import '../../api/api_response.dart';
import '../../model/home_page_model/generate_token_vo.dart';
import '../../model/home_page_model/order_data_response_vo.dart';
import '../../utils/colors.dart';
import '../../utils/constant_images.dart';
import '../../utils/helpers/utills.dart';
import '../../utils/strings.dart';
import 'order_create_data_values.dart';

class OrderCreateView extends StatefulWidget {
  const OrderCreateView({super.key});

  @override
  State<OrderCreateView> createState() => _OrderCreateViewState();
}

class _OrderCreateViewState extends State<OrderCreateView> {
  IconWithName? selectedPaymentType =
      paymentTypeList.isNotEmpty ? paymentTypeList.first : null;
  ImageWithName? selectedSubPaymentType =
      paymentTypeList.isNotEmpty ? netBankingSubPaymentTypeList.first : null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: whiteColor),
        backgroundColor: blackColor,
        leading: Row(
          children: [
            const Gap(14),
            Image.asset(
              height: 31,
              width: 85,
              headerLogoImg,
            ),
          ],
        ),
        titleSpacing: 0,
        leadingWidth: 100,
        title: const Text(
          header1,
          //style:  context.gorditasTitle1.copyWith(
          style: TextStyle(
              color: whiteColor, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                navigateToSettingPage(context);
                setState(() {
                  navigatedFromHome = true;
                });
              },
              child: const Icon(
                Icons.settings,
                size: 30,
                color: whiteColor,
              )),
          const Gap(14)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(14.0),
                  child: Image.asset(
                    paperPlaneImg,
                    height: 200,
                    fit: BoxFit.fill,
                  )),
              const Gap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    homeTxt3,
                    style: TextStyle(
                        color: blackColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 20),
                  ),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: greyColor[100],
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        const Gap(10),
                        DropdownButton<String>(
                          icon: const Icon(Icons.keyboard_arrow_down_outlined),
                          value: selectedCountryType,
                          items: countyTypeList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCountryType = newValue!;
                            });
                          },
                        ),
                        const VerticalDivider(
                          thickness: 2,
                        ),
                        SizedBox(
                          width: 100,
                          height: 28,
                          child: Column(
                            children: [
                              Expanded(
                                child: TextField(
                                  enableInteractiveSelection: false,
                                  controller: rspController,
                                  decoration: InputDecoration(
                                    fillColor: greyColor[100],
                                    filled: true,
                                    border: InputBorder.none,
                                  ),
                                  cursorColor: greyColor,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(7),
                                  ],
                                  // Only numbers can be entered
                                ),
                              ),
                              const DottedLine(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                lineLength: 104,
                                lineThickness: 2.0,
                                dashLength: 4.0,
                                dashColor: greyColor,
                                dashGapLength: 4.0,
                              ),
                            ],
                          ),
                        ),
                        const Gap(5),
                      ],
                    ),
                  )
                ],
              ),
              const Gap(20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_sharp,
                    size: 18,
                    color: indigoColor,
                  ),
                  Gap(5),
                  Expanded(
                    child: Text(
                      homeTxt4,
                      maxLines: 2,
                      style: TextStyle(
                        color: greyColor,
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      switchValue = !switchValue;
                      if (switchValue == true) {
                        selectedHeaderEnabled =
                            "your brand name and brand logo";
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Expanded(
                        child: Text(
                          homeTxt5,
                          maxLines: 2,
                          style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: switchValue,
                          onChanged: (value) {
                            setState(() {
                              switchValue = value;
                              if (switchValue == true) {
                                selectedHeaderEnabled =
                                    "your brand name and brand logo";
                              }
                            });
                          },
                          activeColor: whiteColor,
                          activeTrackColor: blackColor,
                          inactiveThumbColor: whiteColor,
                          inactiveTrackColor: greyColor[300],
                          trackOutlineWidth:
                              MaterialStateProperty.resolveWith<double>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return 0.5; // Custom outline width for disabled state
                              }
                              return 0.1; // Default outline width
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(14),
              const Text(
                homeTxt6,
                maxLines: 2,
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Gap(6),
              DropdownButtonFormField2(
                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: switchValue ? greyColor : whiteColor,
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
                        color: whiteColor,
                      ),
                      elevation: 8,
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all(4),
                      )),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: greyColor.shade300, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: greyColor.shade300, width: 2),
                    ),
                    filled: true,
                    fillColor: whiteColor,
                  ),
                  value: switchValue == true
                      ? selectedHeaderEnabled
                      : selectedHeaderDisable,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedHeaderEnabled = newValue!;
                    });
                  },
                  items: switchValue == true
                      ? headerCustomTypeEnabled.asMap().entries.map((e) {
                          final value = e.value;
                          final index = e.key;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: colorVal[index],
                                  //color: switchValue == true?colorVal[index]:orangeColor,
                                  size: 20,
                                ),
                                const Gap(5),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      : headerCustomTypeDisabled.asMap().entries.map((e) {
                          final value = e.value;
                          //final index = e.key;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: orangeColor,
                                  //color: switchValue == true?colorVal[index]:orangeColor,
                                  size: 20,
                                ),
                                const Gap(5),
                                Text(
                                  value,
                                  style: const TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()),
              const Gap(14),
              const Text(
                homeTxt7,
                maxLines: 2,
                style: TextStyle(
                  color: blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Gap(6),
              DropdownButtonFormField2<IconWithName>(
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
                      color: whiteColor,
                    ),
                    elevation: 8,
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all(4),
                    )),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greyColor.shade300, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greyColor.shade300, width: 2),
                  ),
                  filled: true,
                  fillColor: whiteColor,
                ),
                value: selectedPaymentType,
                onChanged: (IconWithName? newValue) {
                  setState(() {
                    selectedPaymentType = newValue!;
                    if (selectedPaymentType?.name == "netbanking") {
                      setState(() {
                        showSubPaymentMode = true;
                        selectedSubPaymentType =
                            netBankingSubPaymentTypeList.first;
                      });
                    } else if (selectedPaymentType?.name == "wallet") {
                      setState(() {
                        showSubPaymentMode = true;
                        selectedSubPaymentType = walletSubPaymentTypeList.first;
                      });
                    } else if (selectedPaymentType?.name == "upi") {
                      showSubPaymentMode = true;
                      selectedSubPaymentType = upiSubPaymentTypeList.first;
                    } else {
                      showSubPaymentMode = false;
                    }
                  });
                },
                items: paymentTypeList.map((value) {
                  return DropdownMenuItem<IconWithName>(
                    value: value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          value.icon,
                          size: 20,
                        ),
                        const Gap(5),
                        Text(
                          value.name,
                          style: const TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              //Sub payment mode
              showSubPaymentMode == true
                  ? Wrap(
                      children: [
                        Container(height: 14),
                        const Text(
                          homeTxt8,
                          maxLines: 2,
                          style: TextStyle(
                            color: blackColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Container(height: 6),
                        DropdownButtonFormField2<ImageWithName>(
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: greyColor,
                            ),
                            iconEnabledColor: greyColor,
                            iconDisabledColor: whiteColor,
                          ),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: greyColor.shade300, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: greyColor.shade300, width: 2),
                            ),
                            filled: true,
                            fillColor: whiteColor,
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
                                color: whiteColor,
                              ),
                              elevation: 8,
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(4),
                              )),
                          value: selectedSubPaymentType,
                          onChanged: (ImageWithName? newValue) {
                            setState(() {
                              selectedSubPaymentType = newValue!;
                            });
                          },
                          items: selectedPaymentType?.name == "netbanking"
                              ? netBankingSubPaymentTypeList.map((value) {
                                  return DropdownMenuItem<ImageWithName>(
                                    value: value,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        value.image,
                                        const Gap(5),
                                        Text(
                                          value.name,
                                          style: const TextStyle(
                                            color: blackColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : selectedPaymentType?.name == "wallet"
                                  ? walletSubPaymentTypeList.map((value) {
                                      return DropdownMenuItem<ImageWithName>(
                                        value: value,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            value.image,
                                            const Gap(5),
                                            Text(
                                              value.name,
                                              style: const TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList()
                                  : upiSubPaymentTypeList.map((value) {
                                      return DropdownMenuItem<ImageWithName>(
                                        value: value,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            value.image,
                                            const Gap(5),
                                            Text(
                                              value.name,
                                              style: const TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                        ),
                      ],
                    )
                  : Container(),

              const Gap(14),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.only(left: 20),
                title: Transform.translate(
                    offset: const Offset(-20, 0),
                    child: const Text(
                      homeTxt9,
                      style: TextStyle(
                        color: blackColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    )),
                value: userDetailsChecked,
                onChanged: (value) {
                  setState(() {
                    userDetailsChecked = value!;
                  });
                },
                activeColor: blackColor,
                checkColor: whiteColor,
              ),
              userDetailsChecked == true
                  ? Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Container(
                            height: 14,
                          ),
                          TextFormField(
                            enableInteractiveSelection: true,
                            cursorColor: greyColor.shade700,
                            controller: nameController,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                color: blackColor,
                                fontSize: 16,
                              ),
                              labelText: homeTxt10,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade300, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade800, width: 2),
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: lightRedColor, width: 2),
                              ), // Optional: Remove this line for no border
                            ),
                          ),
                          Container(
                            height: 14,
                          ),
                          TextFormField(
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            cursorColor: greyColor.shade700,
                            controller: numberController,
                            validator: (value) {
                              if (value?.length != 10) {
                                return "Invalid Number";
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                color: blackColor,
                                fontSize: 16,
                              ),
                              labelText: homeTxt11,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade300, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade800, width: 2),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade800, width: 2),
                              ),
                            ),
                          ),
                          Container(
                            height: 14,
                          ),
                          TextFormField(
                            enableInteractiveSelection: true,
                            cursorColor: greyColor.shade700,
                            controller: emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) =>
                                EmailValidator.validate(value!)
                                    ? null
                                    : 'Invalid Email',
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(
                                color: blackColor,
                                fontSize: 16,
                              ),
                              labelText: homeTxt12,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade300, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: greyColor.shade800, width: 2),
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: lightRedColor, width: 2),
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 20,
                    ),
              ElevatedButton(
                onPressed: () async {
                  String testMerchant = switchValue == true
                      ? selectedHeaderEnabled
                      : selectedHeaderDisable;

                  GenerateTokenVo tokenData = await APIResponse().getToken(
                      Utils().getAccessKey(NetworkHelper.baseUrl, testMerchant),
                      Utils().getAccessSecret(
                          NetworkHelper.baseUrl, testMerchant));
                  if (kDebugMode) {
                    print('TokenData=====>>${tokenData.token.toString()}');
                  }

                  Result<OrderDataResponseVo>? orderData = await APIResponse()
                      .getOrderData(
                          selectedCountryType,
                          int.tryParse(rspController.text.toString()) ?? 4,
                          nameController.text.toString().isEmpty
                              ? ''
                              : nameController.text.toString(),
                          emailController.text.toString().isEmpty
                              ? ''
                              : emailController.text.toString(),
                          numberController.text.toString().isEmpty
                              ? ''
                              : numberController.text.toString(),
                          tokenData.token!);
                  if (kDebugMode) {
                    print('OrderData=====>>${orderData.toString()}');
                  }
                  if (orderData.data != null) {
                    NimbblCheckoutOptions options = NimbblCheckoutOptions(
                        token: tokenData.token,
                        orderToken: orderData.data?.token,
                        orderID: orderData.data?.orderId,
                        paymentModeCode: Utils()
                            .getPaymentModeCode(selectedPaymentType!.name),
                        bankCode:
                            Utils().getBankCode(selectedSubPaymentType!.name),
                        paymentFlow:
                            Utils().getBankCode(selectedSubPaymentType!.name),
                        walletCode:
                            Utils().getBankCode(selectedSubPaymentType!.name),
                        invoiceId: orderData.data?.invoiceId);
                    NimbblCheckoutSDK.instance
                        .init(context, NetworkHelper.baseUrl);
                    final result =
                        await NimbblCheckoutSDK.instance.checkout(options);
                    if (result != null) {
                      if (result.isSuccess!) {
                        Utils.showToast(context,
                            '$orderIdStr${result.data?["order_id"]}, $statusStr${result.data?["status"]}');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OrderSuccessView(
                                  orderID: result.data?["order_id"],
                                  status: result.data?["status"],
                                )));
                      } else {
                        Utils.showToast(context, result.data?['message']);
                      }
                      if (kDebugMode) {
                        print(
                            'isSucees-->${result.isSuccess}/message-->${result.data?['message']}');
                      }
                    }
                  } else {
                    Utils.showToast(context,
                        orderData.error!.error!.nimbblMerchantMessage!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  homeButtonTxt2,
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),

              const Gap(40),
              Container(
                //height: 282,
                color: blackColor,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              launchURL(nimbblWebUrl);
                            },
                            child: Image.asset(
                              height: 26,
                              width: 49,
                              nimbblLogoImg,
                            ),
                          ),
                          const Gap(20),
                          const Expanded(
                            child: Text(
                              homeTxt13,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: veryLightGreyColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
