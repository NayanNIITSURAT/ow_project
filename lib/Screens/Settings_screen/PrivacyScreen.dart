import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:owlet/Widgets/SettingsBar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import '../../Components/Toast.dart';
import '../../constants/constants.dart';
import '../../constants/images.dart';
import '../../services/utils.dart';
import 'package:http/http.dart' as http;

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool value = true;
  bool isload = false;

  @override
  Widget build(BuildContext context) {
    return SettingsBar(trailing: false,
        isappbar: true,
        Title: "Privacy",
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children:  [
                          SizedBox(
                              height :20 ,
                              child: Image.asset(lock)),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Private account",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
isload==true?
      SizedBox(
          height: 20,
          child: CupertinoActivityIndicator()):SizedBox.shrink(),
                    Row(children: [
                      Transform.scale(
                        scale: 0.9,
                        child: CupertinoSwitch(
                          activeColor: Colors.greenAccent,
                            trackColor: Colors.grey.withOpacity(0.5),
                            thumbColor:Colors.black ,
                            value: value,
                            onChanged: (value) {



                              setState(() {
                                isload = true;
                                this.value = value;
                              });
                              callapi();


                            }



                        ),
                      ),
                    ]),
                  ],
                ),
              )
            ],
          ),
        ));
  }


  callapi() async {
    var onof = "";
    if (value) {
      onof = "on";
    } else {
      onof = "off";
    }

    Map<String, dynamic> getdatamodel = await on_off_private_ac(onof);
    if (!getdatamodel['isError']) {
      var data = getdatamodel['response'];
      var mesg = data['message'];
      Toast(
        context,
        message: mesg,
        duration: Duration(milliseconds: 100),
        type: ToastType.SUCCESS,
      ).showTop();
      setState(() {
        isload = false;
      });
    } else {
      var data = getdatamodel['response'];
      var mesg = data['message'];

      Toast(
        context,
        message: mesg,
        duration: Duration(milliseconds: 100),
        type: ToastType.ERROR,
      ).showTop();
      setState(() {
        isload = false;
      });
      // throw HttpException(data['message']);
    }
  }


  // callapi() async {
  //   var onof="";
  //   if(value)
  //     {
  //       onof="on";
  //     }
  //   else
  //     {
  //       onof="off";
  //     }
  //
  //   final userid=await getuserid;
  //
  //   final headers = Global.jsonHeaders;
  //   headers.addAll({HttpHeaders.authorizationHeader: 'Bearer ${await getToken}'});
  //   final response = await http.get(
  //     Uri.parse('https://api.the-owlette.com/v4/users/privateAccUpdate?userId=$userid&value=$onof'),
  //     headers: headers,
  //   );
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //       var mesg=data['message'];
  //
  //
  //     Toast(
  //
  //       context,
  //       message:mesg,
  //       duration:  Duration(milliseconds: 100),
  //       type: ToastType.SUCCESS,
  //     ).showTop();
  //     setState(() {
  //       isload = false;
  //
  //     });
  //
  //
  //   }
  //   else {
  //
  //     var data = jsonDecode(response.body);
  //     var mesg=data['message'];
  //     Toast(
  //
  //       context,
  //       message:mesg,
  //       duration:  Duration(milliseconds: 100),
  //       type: ToastType.ERROR,
  //     ).showTop();
  //     setState(() {
  //       isload = false;
  //
  //     });
  //     throw HttpException(data['message']);
  //   }
  //
  // }
}
