import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hsequize/hsequize.dart';
import 'package:hsequize/models/user_data.dart';

import '../blocs/manager.dart';
import '../models/user_workplace.dart';
import '../repository/admob_repositroy.dart';

class QuizeGamePage extends StatefulWidget {  
  const QuizeGamePage({super.key});
  @override
  State<QuizeGamePage> createState() => _QuizeGamePageState();
}

class _QuizeGamePageState extends State<QuizeGamePage>  with Manager<_QuizeGamePageState>{
  UserData? _userData; // Store UserData

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load data when the widget initializes
  }

  Future<void> _loadUserData() async {
    if(db.currentUser!=null && db.currentUser?.currentWorkplaceDataId!=null){
      await db.findOne<UserWorkplace>(db.currentUser!.currentWorkplaceDataId!)
      .then((onValue){
        if(onValue !=null){
            final points = onValue.points;
            final quizeLevels = onValue.quizeGamelevel;  
            setState(() {
            _userData = UserData(points: points, quizeLevelsAvailable: quizeLevels);
          });
        }
      });
      
    }
  }

  // Future<void> _saveUserData(UserData userData) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('quizePoints', userData.points);
  //   await prefs.setStringList('quizeLevels', userData.quizeLevels.map((e) => e.toString()).toList()); // Store as string list
  //   await prefs.setStringList('quizeLocks', userData.quizeLocks.map((e) => e.toString()).toList());  //Store as string list
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
                title: Text( 'quizeGameTitle'.tr(),
                        style: 
                          const TextStyle(
                              fontSize: 40, fontWeight: 
                              FontWeight.bold)
                        )
              ),
      body: QuizeGame(
              userData:_userData!,
              interstitialAdUnitId:AdHelper.interstitialAdUnitId,
              bannerAddId:AdHelper.bannerAdUnitId,
              lang : prefs.language,
              showAds : true,
              // primaryColor: Theme.of(context).primaryColor,
              // menuLogoPath: 'assets/images/flutterlogo.jpg',
              // buttonPath: 'assets/images/primary_button.png',
              // labelPath: 'assets/images/label.png',
              // //bgImagePath: 'assets/images/bg.png',
              // gradient: LinearGradient(
              //   stops: const [0, 1],
              //   begin: const Alignment(1, -1),
              //   end: const Alignment(0, 1),
              //   colors: [Theme.of(context).primaryColor, const Color(0xff753bc6)],
              // ),
              // secondaryColor: const Color(0xff753bc6),
              // onTapEvent: (context,action){
              //   log.i("index: ${action.index} , name:${action.name}");
              // },
            )
        );
  }

}
