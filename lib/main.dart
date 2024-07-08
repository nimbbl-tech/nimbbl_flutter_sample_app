import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nimbbl_flutter_sample_app/ui/screens/config_page_view.dart';
import 'package:nimbbl_flutter_sample_app/ui/screens/order_create_data_values.dart';
import 'package:nimbbl_flutter_sample_app/ui/screens/order_create_view.dart';
import 'package:nimbbl_flutter_sample_app/utils/constants/constants.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/utils/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/network_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nimbbl Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const HomePage(),
    );
  }



}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? envValue;
  String? appExp;

  Future<void>getData()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    envValue = prefs.getString(environmentPref);
    appExp = prefs.getString(appExperiencePref);
    setSelectedEnvironment(envValue);
    setSelectedAppExp(appExp);
    if(envValue == environmentTypeList[0]){
      NetworkHelper.baseUrl = baseUrlPROD;
    }else if(envValue == environmentTypeList[1]){
      NetworkHelper.baseUrl = baseUrlPP;
    }else if(envValue == environmentTypeList[2]){
      NetworkHelper.baseUrl = baseUrlUAT;
    }

  }
  @override
  Widget build(BuildContext context) {
    return
      FutureBuilder(
          future: Future.wait([
            getData()
          ]),
          builder: (BuildContext context, snapshot) {
            if(snapshot.connectionState == ConnectionState.done){
              if(envValue != null){
                return const OrderCreateView();
              }else{
                return const ConfigPageView();
              }

            }
            else{
              return Container();}
          },

        );


  }
}



