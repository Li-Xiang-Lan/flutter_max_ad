import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_result_bean.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';
import 'package:flutter_max_ad/ad/load_ad/base_load.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/flutter_max_ad.dart';

class OpenAd extends BaseLoad{
  List<MaxAdInfoBean> adInfoList;
  MaxAdResultBean? _adResultBean;
  bool _loading=false;
  Timer? _loadCountTimer;

  OpenAd({
    required this.adInfoList
  });

  @override
  bool checkHasCache() {
    if(null==_adResultBean){
      return false;
    }
    var maxAdInfoBean = getMaxInfoById(_adResultBean?.maxAd.adUnitId??"");
    if(null==maxAdInfoBean){
      _adResultBean=null;
      return false;
    }
    var expire = DateTime.now().millisecondsSinceEpoch-(_adResultBean?.loadTime??0)>maxAdInfoBean.expire*1000;
    if(expire){
      _adResultBean=null;
      return false;
    }
    return true;
  }

  @override
  loadAd(int index) {
    if(null!=_adResultBean){
      FlutterMaxAd.instance.printDebug("FlutterMaxAd open has cache");
      return;
    }
    if(_loading&&index==0){
      FlutterMaxAd.instance.printDebug("FlutterMaxAd open ad is loading");
      return;
    }
    if(index<adInfoList.length){
      _loading=true;
      var maxAdInfoBean = adInfoList[index];
      _startLoadAd(maxAdInfoBean);
      _startCountDownTimer(maxAdInfoBean,(){
        loadAd(index+1);
      });
      return;
    }
    _loading=false;
  }

  @override
  loadAdFail(String adUnitId) {
    var indexWhere = adInfoList.indexWhere((element) => element.id==adUnitId);
    if(indexWhere>=0){
      _stopCountDownTimer();
      loadAd(indexWhere+1);
    }
  }

  @override
  loadAdSuccess(MaxAd ad) {
    _stopCountDownTimer();
    _adResultBean=MaxAdResultBean(maxAd: ad, loadTime: DateTime.now().millisecondsSinceEpoch);
    _loading=false;
  }

  @override
  bool isLoading() => _loading;

  // @override
  // Future<MaxAd?> getMaxAd() async{
  //   if(null==_adResultBean){
  //     return null;
  //   }
  //   var maxAdInfoBean = getMaxInfoById(_adResultBean?.maxAd.adUnitId??"");
  //   if(null!=maxAdInfoBean){
  //     if(maxAdInfoBean.adType==AdType.open){
  //       var isAppOpenAdReady=await AppLovinMAX.isAppOpenAdReady(_adResultBean?.maxAd.adUnitId??"")??false;
  //       if(isAppOpenAdReady){
  //         return _adResultBean?.maxAd;
  //       }
  //     }else if(maxAdInfoBean.adType==AdType.inter){
  //       var isInterstitialReady=await AppLovinMAX.isInterstitialReady(_adResultBean?.maxAd.adUnitId??"")??false;
  //       if(isInterstitialReady){
  //         return _adResultBean?.maxAd;
  //       }
  //     }
  //   }
  //   _adResultBean=null;
  //   return null;
  // }
  @override
  MaxAd? getMaxAd() {
    return _adResultBean?.maxAd;
  }

  @override
  MaxAdInfoBean? getMaxInfoById(String adUnitId) {
    var indexWhere = adInfoList.indexWhere((element) => element.id==adUnitId);
    if(indexWhere>=0){
      return adInfoList[indexWhere];
    }
    return null;
  }

  @override
  removeMaxAd(String adUnitId) {
    if(null!=getMaxInfoById(adUnitId)){
      _adResultBean=null;
    }
  }

  _startCountDownTimer(MaxAdInfoBean maxAdInfoBean,Function() complete){
    _loadCountTimer=Timer.periodic(const Duration(milliseconds: 10000), (timer) {
      FlutterMaxAd.instance.printDebug("FlutterMaxAd load ad time out ---> ${maxAdInfoBean.toString()}");
      timer.cancel();
      complete();
    });
  }

  _stopCountDownTimer(){
    _loadCountTimer?.cancel();
    _loadCountTimer=null;
  }

  _startLoadAd(MaxAdInfoBean infoBean){
    FlutterMaxAd.instance.printDebug("FlutterMaxAd start load ad----->${infoBean.toString()}");
    switch(infoBean.adType){
      case AdType.open:
        FlutterMaxAd.instance.startLoadAdCallBack();
        AppLovinMAX.loadAppOpenAd(infoBean.id);
        break;
      case AdType.inter:
        FlutterMaxAd.instance.startLoadAdCallBack();
        AppLovinMAX.loadInterstitial(infoBean.id);
        break;
      default:break;
    }
  }
}