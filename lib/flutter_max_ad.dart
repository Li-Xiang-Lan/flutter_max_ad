import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/ad/ad_num_utils.dart';
import 'package:flutter_max_ad/ad/listener/ad_show_listener.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';
import 'package:flutter_max_ad/ad/listener/load_ad_listener.dart';
import 'package:flutter_max_ad/ad/load/load_ad_utils.dart';
import 'package:flutter_max_ad/ad/load/load_ad_utils2.dart';


class FlutterMaxAd {
  static final FlutterMaxAd _instance = FlutterMaxAd();

  static FlutterMaxAd get instance => _instance;

  var _maxInit=false,_fullAdShowing=false,_logFacebookPurchase=false;
  AdShowListener? _adShowListener;
  LoadAdListener? _loadAdListener;
  final _facebookAppEvents = FacebookAppEvents();

  initMax({
    required String maxKey,
    required String topOnAppId,
    required String topOnAppKey,
    required MaxAdBean maxAdBean,
    bool? logFacebookPurchase,
    List<String>? maxTestDeviceIds,  //android->gaid   ios->idfa
    String? topOnTestDeviceId,  //android->gaid   ios->idfa
    bool? maxOpenDebugger,
  })async{
    _logFacebookPurchase=logFacebookPurchase??false;
    setMaxAdInfo(maxAdBean);
    if(null!=maxTestDeviceIds){
      AppLovinMAX.setTestDeviceAdvertisingIds(maxTestDeviceIds);
    }
    var maxConfiguration = await AppLovinMAX.initialize(maxKey);
    if(null!=maxConfiguration){
      _maxInit=true;
      if(kDebugMode&&maxOpenDebugger==true){
        AppLovinMAX.showMediationDebugger();
      }
      _setAdListener();
      loadAdByType(AdType.reward);
      loadAdByType(AdType.inter);
    }
  }

  setLoadAdListener(LoadAdListener loadAdListener){
    _loadAdListener=loadAdListener;
  }

  loadAdByType(AdType adType)async{
    if(!_maxInit){
      printDebug("FlutterMaxAd not init");
      return;
    }
    if(AdNumUtils.instance.getAdNumLimit()){
      printDebug("FlutterMaxAd show or click num limit");
      return;
    }
    LoadAdUtils.instance.loadAd(adType);
    LoadAdUtils2.instance.loadAd(adType);
  }

  _setAdListener(){
    AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
          onAdLoadedCallback: (MaxAd ad) {
            LoadAdUtils.instance.loadAdSuccess(ad.adUnitId);
            LoadAdUtils2.instance.loadAdSuccess(ad.adUnitId);
            _loadAdListener?.loadSuccess.call(ad,_getMaxInfoById(ad.adUnitId));
          },
          onAdLoadFailedCallback: (String adUnitId, MaxError error) {
            LoadAdUtils.instance.loadAdFail(adUnitId);
            LoadAdUtils2.instance.loadAdFail(adUnitId);
          },
          onAdDisplayedCallback: (MaxAd ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            _removeMaxAd(ad.adUnitId);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess?.call(ad,_getMaxInfoById(ad.adUnitId));
          },
          onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            _fullAdShowing=false;
            _removeMaxAd(ad.adUnitId);
            _adShowListener?.showAdFail?.call(ad,error);
            loadAdByType(AdType.reward);
            loadAdByType(AdType.inter);
          },
          onAdClickedCallback: (MaxAd ad) {
            AdNumUtils.instance.updateClickNum();
          },
          onAdHiddenCallback: (MaxAd ad) {
            _fullAdShowing=false;
            loadAdByType(AdType.reward);
            _adShowListener?.onAdHidden.call(ad);
          },
          onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {
            _adShowListener?.onAdReceivedReward?.call(ad,reward);
          },
          onAdRevenuePaidCallback: (MaxAd ad){
            _onAdRevenuePaidByAdjust(ad);
          }
        )
    );
    AppLovinMAX.setInterstitialListener(
        InterstitialListener(
          onAdLoadedCallback: (ad) {
            LoadAdUtils.instance.loadAdSuccess(ad.adUnitId);
            LoadAdUtils2.instance.loadAdSuccess(ad.adUnitId);
            _loadAdListener?.loadSuccess.call(ad,_getMaxInfoById(ad.adUnitId));
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            LoadAdUtils.instance.loadAdFail(adUnitId);
            LoadAdUtils2.instance.loadAdFail(adUnitId);
          },
          onAdDisplayedCallback: (ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            _removeMaxAd(ad.adUnitId);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess?.call(ad,_getMaxInfoById(ad.adUnitId));
          },
          onAdDisplayFailedCallback: (ad, error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            _removeMaxAd(ad.adUnitId);
            _adShowListener?.showAdFail?.call(ad,error);
            loadAdByType(AdType.reward);
            loadAdByType(AdType.inter);
          },
          onAdClickedCallback: (ad) {
            AdNumUtils.instance.updateClickNum();
          },
          onAdHiddenCallback: (ad) {
            _fullAdShowing=false;
            loadAdByType(AdType.inter);
            _adShowListener?.onAdHidden.call(ad);
          },
          onAdRevenuePaidCallback: (MaxAd ad){
            _onAdRevenuePaidByAdjust(ad);
          }
        )
    );
  }

  _removeMaxAd(String? adUnitId){
    LoadAdUtils.instance.removeAdByType(adUnitId);
    LoadAdUtils2.instance.removeAdByType(adUnitId);
  }

  setMaxAdInfo(MaxAdBean maxAdBean){
    printDebug("FlutterMaxAd max ad info--->${maxAdBean.toString()}");
    AdNumUtils.instance.setNumInfo(maxAdBean);
    maxAdBean.firstRewardedAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.secondRewardedAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.firstInterAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.secondInterAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    LoadAdUtils.instance.initAdInfo(maxAdBean);
    LoadAdUtils2.instance.initAdInfo(maxAdBean);
  }
  
  showAd({
    required AdType adType,
    required AdShowListener? adShowListener
  })async{
    _adShowListener=adShowListener;
    if(!_maxInit){
      printDebug("FlutterMaxAd not init");
      _adShowListener?.showAdFail?.call(null,null);
      return;
    }
    if(_fullAdShowing){
      printDebug("FlutterMaxAd show ad fail, has ad showing");
      _adShowListener?.showAdFail?.call(null,null);
      return;
    }
    var resultBean = LoadAdUtils.instance.getAdResultByAdType(adType);
    resultBean ??= LoadAdUtils2.instance.getAdResultByAdType(adType);
    if(null!=resultBean){
      printDebug("FlutterMaxAd --->start show ad $adType");
      switch(adType){
        case AdType.reward:
          if(await AppLovinMAX.isRewardedAdReady(resultBean.maxAdInfoBean.id)==true){
            AppLovinMAX.showRewardedAd(resultBean.maxAdInfoBean.id);
          }else{
            printDebug("FlutterMaxAd isRewardedAdReady=false");
            _removeMaxAd(resultBean.maxAdInfoBean.id);
            _adShowListener?.showAdFail?.call(null,null);
            loadAdByType(AdType.reward);
            loadAdByType(AdType.inter);
          }
          break;
        case AdType.inter:
          if(await AppLovinMAX.isInterstitialReady(resultBean.maxAdInfoBean.id)==true){
            AppLovinMAX.showInterstitial(resultBean.maxAdInfoBean.id);
          }else{
            printDebug("FlutterMaxAd isRewardedAdReady=false");
            _removeMaxAd(resultBean.maxAdInfoBean.id);
            _adShowListener?.showAdFail?.call(null,null);
            loadAdByType(AdType.reward);
            loadAdByType(AdType.inter);
          }
          break;
        default:
          _adShowListener?.showAdFail?.call(null,null);
          break;
      }
    }else{
      printDebug("FlutterMaxAd --->$adType result == null");
      _adShowListener?.showAdFail?.call(null,null);
      loadAdByType(AdType.reward);
      loadAdByType(AdType.inter);
    }
  }

  fullAdShowing()=>_fullAdShowing;

  _onAdRevenuePaidByAdjust(MaxAd ad){
    try{
      var adjustAdRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAppLovinMAX,);
      adjustAdRevenue.setRevenue(ad.revenue, "USD");
      adjustAdRevenue.adRevenueNetwork=ad.networkName;
      adjustAdRevenue.adRevenueUnit=ad.adUnitId;
      adjustAdRevenue.adRevenuePlacement=ad.placement;
      Adjust.trackAdRevenueNew(adjustAdRevenue);
    }catch(e){

    }
    try{
      FirebaseAnalytics.instance.logPurchase(
        value: ad.revenue,
        currency: "USD",
      );
    }catch(e){

    }
    try{
      if(_logFacebookPurchase){
        _facebookAppEvents.logPurchase(amount: ad.revenue, currency: "USD");
      }
    }catch(e){

    }
    _adShowListener?.onAdRevenuePaidCallback?.call(ad);
  }

  MaxAdInfoBean? _getMaxInfoById(String id){
    var infoBean = LoadAdUtils.instance.getAdInfoById(id);
    infoBean ??= LoadAdUtils2.instance.getAdInfoById(id);
    return infoBean;
  }

  bool checkHasCache(AdType adType)=>LoadAdUtils.instance.checkHasCache(adType)||LoadAdUtils2.instance.checkHasCache(adType);

  startLoadAd(){
    _loadAdListener?.startLoad.call();
  }

  printDebug(Object? object){
    if(kDebugMode){
      print(object);
    }
  }
}
