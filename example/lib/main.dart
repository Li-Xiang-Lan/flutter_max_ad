import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_max_ad/ad/ad_show_listener.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/export.dart';
import 'package:flutter_max_ad/flutter_max_ad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                  onPressed: ()async{
                    var ad ="ewogICJ6c2ciOiAxMDAsCiAgImRqZyI6IDEwMCwKICAicW5fb3Blbl8zIjogWwogICAgewogICAgICAiZ2lnZCI6ICIzYjY5ZTJjOWQ0MDM0ZjhhIiwKICAgICAgImdwZ2xhdCI6ICJtYXgiLAogICAgICAiZ2xneCI6ICJvcGVuIiwKICAgICAgImdvZ3ZlciI6IDMwMDAsCiAgICAgICJnbGdldmUiOiAzCiAgICAgfSwKICAgewogICAgICAiZ2lnZCI6ICJmNWZjNjc3ZmQxN2E4NjIzIiwKICAgICAgImdwZ2xhdCI6ICJtYXgiLAogICAgICAiZ2xneCI6ICJvcGVuIiwKICAgICAgImdvZ3ZlciI6IDMwMDAsCiAgICAgICJnbGdldmUiOiA0CiAgICAgfSwKICB7CiAgICAgICJnaWdkIjogIjNhMGI3NGVjMmRhOTVkMmIiLAogICAgICAiZ3BnbGF0IjogIm1heCIsCiAgICAgICJnbGd4IjogImludGVyc3RpdGlhbCIsCiAgICAgICJnb2d2ZXIiOiAzMDAwLAogICAgICAiZ2xnZXZlIjogMgogICAgIH0KICBdLAogICJxbl9ydl8zIjogWwogICAgIHsKICAgICAgImdpZ2QiOiAiODE3ZTZkYzdhYjExZTllMSIsCiAgICAgICJncGdsYXQiOiAibWF4IiwKICAgICAgImdsZ3giOiAicmV3YXJkIiwKICAgICAgImdvZ3ZlciI6IDMwMDAsCiAgICAgICJnbGdldmUiOiAzCiAgICAgfSwKICAgIHsKICAgICAgImdpZ2QiOiAiNjQyY2IyODdiNDIyMTdjOCIsCiAgICAgICJncGdsYXQiOiAibWF4IiwKICAgICAgImdsZ3giOiAicmV3YXJkIiwKICAgICAgImdvZ3ZlciI6IDMwMDAsCiAgICAgICJnbGdldmUiOiA0CiAgICAgfQogIF0sCiAgInFuX3J2XzIiOiBbCiAgICAgewogICAgICAiZ2lnZCI6ICJlM2YyNTRkMzE2MDIxZDFiIiwKICAgICAgImdwZ2xhdCI6ICJtYXgiLAogICAgICAiZ2xneCI6ICJyZXdhcmQiLAogICAgICAiZ29ndmVyIjogMzAwMCwKICAgICAgImdsZ2V2ZSI6IDMKICAgICB9CiAgXSwKICAicW5faW50XzMiOiBbCiAgICB7CiAgICAgICJnaWdkIjogIjNhMGI3NGVjMmRhOTVkMmIiLAogICAgICAiZ3BnbGF0IjogIm1heCIsCiAgICAgICJnbGd4IjogImludGVyc3RpdGlhbCIsCiAgICAgICJnb2d2ZXIiOiAzMDAwLAogICAgICAiZ2xnZXZlIjogMwogICAgICB9LAogICB7CiAgICAgICJnaWdkIjogIjVjZWY5NGMxZjQ5YjIxNzgiLAogICAgICAiZ3BnbGF0IjogIm1heCIsCiAgICAgICJnbGd4IjogImludGVyc3RpdGlhbCIsCiAgICAgICJnb2d2ZXIiOiAzMDAwLAogICAgICAiZ2xnZXZlIjogNAogICAgICB9CiAgXSwKICAicW5faW50XzIiOiBbCiAgICAgewogICAgICAiZ2lnZCI6ICIzNDA2YmZlY2YwNDk0ODFkIiwKICAgICAgImdwZ2xhdCI6ICJtYXgiLAogICAgICAiZ2xneCI6ICJpbnRlcnN0aXRpYWwiLAogICAgICAiZ29ndmVyIjogMzAwMCwKICAgICAgImdsZ2V2ZSI6IDMKICAgICB9CiAgXQp9";
                    var json = jsonDecode(String.fromCharCodes(base64Decode(ad)));
                    var maxAdBean = MaxAdBean(
                        maxShowNum: json["zsg"],
                        maxClickNum: json["djg"],
                        openAdList: _getAdList(json["qn_open_3"]),
                        firstRewardedAdList: _getAdList(json["qn_rv_3"]),
                        secondRewardedAdList: _getAdList(json["qn_rv_2"]),
                        firstInterAdList: _getAdList(json["qn_int_3"]),
                        secondInterAdList: _getAdList(json["qn_int_2"]),
                    );

                    FlutterMaxAd.instance.initMax(
                      maxKey: "MWJzhnEPtKqxLKRLAlVrTyQfO2VxWZWtVx_SzTWC_MgoZL7kTKNt9t3M_OgIZ24nBXRXxVd9ogQEp7616TWf3C",
                      maxAdBean: maxAdBean,
                      testDeviceAdvertisingIds: ["57535bec-dff7-437d-849a-d4a66292214d","e9fda85d-2c38-48df-b2a9-10ca1ad1abe1","df0c1cf7-6405-463f-9105-10ca1ad1abe1"]
                    );
                  },
                  child: Text("初始化",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.setBuyUser(true);
                  },
                  child: Text("设置买量",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.loadAdByType(AdType.open);
                  },
                  child: Text("加载开屏广告",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.showAd(
                        adType: AdType.open,
                        adShowListener: AdShowListener(
                            showAdFail: (MaxAd? ad, MaxError? error) {

                            },
                            showAdSuccess: (MaxAd? ad,info) {

                            },
                            onAdHidden: (MaxAd? ad) {

                            })
                    );
                  },
                  child: Text("显示开屏广告",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.loadAdByType(AdType.reward);
                  },
                  child: Text("加载激励广告",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.showAd(
                        adType: AdType.reward,
                        adShowListener: AdShowListener(
                            showAdFail: (MaxAd? ad, MaxError? error) {

                            },
                            showAdSuccess: (MaxAd? ad,info) {

                            },
                            onAdHidden: (MaxAd? ad) {

                            })
                    );
                  },
                  child: Text("显示激励广告",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.loadAdByType(AdType.inter);
                  },
                  child: Text("加载插屏广告",style: TextStyle(fontSize: 20),)
              ),
              TextButton(
                  onPressed: (){
                    FlutterMaxAd.instance.showAd(
                        adType: AdType.inter,
                        adShowListener: AdShowListener(
                            showAdFail: (MaxAd? ad, MaxError? error) {

                            },
                            showAdSuccess: (MaxAd? ad,info) {

                            },
                            onAdHidden: (MaxAd? ad) {

                            })
                    );
                  },
                  child: Text("显示插屏广告",style: TextStyle(fontSize: 20),)
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MaxAdInfoBean> _getAdList(json){
    List<MaxAdInfoBean> adList=[];
    json.forEach((v) {
      var v2 = v["glgx"];
      adList.add(
          MaxAdInfoBean(
            id: v["gigd"],
            plat: v["gpglat"],
            adType: v2=="open"?AdType.open:v2=="interstitial"?AdType.inter:v2=="native"?AdType.native:AdType.reward,
            expire: v["gogver"],
            sort: v["glgeve"],
            adLocationName: ""
          )
      );
    });
    return adList;
  }
}
