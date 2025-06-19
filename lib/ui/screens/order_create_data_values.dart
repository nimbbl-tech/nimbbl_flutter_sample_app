import 'package:flutter/material.dart';
import 'package:nimbbl_flutter_sample_app/api/network_helper.dart';
import 'package:nimbbl_flutter_sample_app/ui/screens/config_page_view.dart';
import 'package:nimbbl_mobile_kit_flutter_core_api_sdk/utils/api_utils.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/constants/constants.dart';
import '../../utils/constant_images.dart';
import 'order_create_view.dart';

String selectedCountryType = 'INR';

List<String> countyTypeList = ['INR', 'USD', 'CAD', 'EUR'];

final TextEditingController rspController = TextEditingController(text: '4');

bool _switchValue = true;
bool get switchValue => _switchValue;

//bool isLoading = true;

String selectedHeaderEnabled = 'your brand name and brand logo';
String selectedHeaderDisable = 'your brand name';

List<String> headerCustomTypeEnabled = [
  'your brand name and brand logo',
  'your brand logo'
];

List<String> headerCustomTypeDisabled = [
  'your brand name',
];

final List<Color> colorVal = [
  Colors.indigo.shade900,
  Colors.indigo.shade600,
];



final List<IconWithName> paymentTypeList = [
  IconWithName(icon: Icons.dashboard_outlined, name: 'all payments modes'),
  IconWithName(icon: Icons.account_balance_outlined, name: 'netbanking'),
  IconWithName(icon: Icons.account_balance_wallet_outlined, name: 'wallet'),
  IconWithName(icon: Icons.credit_card_outlined, name: 'card'),
  IconWithName(icon: Icons.paypal, name: 'upi'),
];

final List<ImageWithName> netBankingSubPaymentTypeList = [
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        menuImg,
      ),
      name: 'all banks'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        hdfcImg,
      ),
      name: 'hdfc bank'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
          sbiImg,
      ),
      name: 'sbi bank'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        kotakImg,
      ),
      name: 'kotak bank'),
];

final List<ImageWithName> walletSubPaymentTypeList = [
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        menuImg,
      ),
      name: 'all wallets'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        freeChargeImg,
      ),
      name: 'freecharge'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        jioMoneyImg,
      ),
      name: 'jio money'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        phonePeImg,
      ),
      name: 'phonepe'),
];

final List<ImageWithName> upiSubPaymentTypeList = [
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        upiImg,
      ),
      name: 'collect + intent'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        upiImg,
      ),
      name: 'collect'),
  ImageWithName(
      image: Image.asset(
        height: 16,
        width: 16,
        upiImg,
      ),
      name: 'intent'),
];

bool userDetailsChecked = false;

final TextEditingController nameController = TextEditingController();

final TextEditingController numberController = TextEditingController();

final TextEditingController emailController = TextEditingController();

final GlobalKey<FormState> formKey = GlobalKey<FormState>();


Future<void> launchURL(String urlStr) async {
  final Uri url = Uri.parse(urlStr);
  if (await canLaunch(url.toString())) {
    await launch(url.toString());
  } else {
    throw Exception('Could not launch $url');
  }
}

//bool isLoading = true;

//late InAppWebViewController inAppWebViewController;

bool showSubPaymentMode = false;

class IconWithName {
  final IconData icon;
  final String name;

  IconWithName({required this.icon, required this.name});
}

class ImageWithName {
  final Image image;
  final String name;

  ImageWithName({required this.image, required this.name});
}


Future<void> navigateToSettingPage(BuildContext context) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => const ConfigPageView()));
}

//Setting Page constants
bool navigatedFromHome = false;

List<String> environmentTypeList = [
  'Prod',
  'Pre-Prod',
  'QA 1',
  'QA 2',
];

String _selectedEnvironment = environmentTypeList.first;

String get selectedEnvironment => _selectedEnvironment;

setSelectedEnvironment(String? env) {
  if (env != null) {
    _selectedEnvironment = env;
  }
}

List<String> appExperienceTypeList = [
  'Native',
  'WebView',
];

String get selectedAppExperience => _selectedAppExperience;
String _selectedAppExperience = appExperienceTypeList.first;

setSelectedAppExp(String? exp) {
  if (exp != null) {
    _selectedAppExperience = exp;
  }
}

Future<void> navigateToHomePage(BuildContext context) async {
  Navigator.push(context,
      MaterialPageRoute(builder: (context) => const OrderCreateView()));
}

Future<void> onDone(
    String environment, String appExperience) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(environmentPref, environment);
  await prefs.setString(appExperiencePref, appExperience);
  if(environment == environmentTypeList[0]){
    NetworkHelper.baseUrl = baseUrlPROD;
  }else if(environment == environmentTypeList[1]){
    NetworkHelper.baseUrl = baseUrlPP;
  }else if(environment == environmentTypeList[2]){
    NetworkHelper.baseUrl = baseUrlQA1;
  }
  else if(environment == environmentTypeList[3]){
    NetworkHelper.baseUrl = baseUrlQA2;
  }
  NimbblCheckoutSDK.instance.setEnvironmentUrl(NetworkHelper.baseUrl);

}
setSwitchValue(bool istrue){
  _switchValue = istrue;
}
