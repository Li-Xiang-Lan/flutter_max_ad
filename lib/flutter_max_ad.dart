import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
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

  var _maxInit=false,_fullAdShowing=false;
  AdShowListener? _adShowListener;
  LoadAdListener? _loadAdListener;
  final _facebookAppEvents = FacebookAppEvents();

  initMax({
    required String maxKey,
    required MaxAdBean maxAdBean,
    List? testDeviceAdvertisingIds,
    bool? showMediationDebugger,
  })async{
    setMaxAdInfo(maxAdBean);
    if(null!=testDeviceAdvertisingIds){
      AppLovinMAX.setTestDeviceAdvertisingIds(testDeviceAdvertisingIds);
    }
    var maxConfiguration = await AppLovinMAX.initialize(maxKey);
    if(null!=maxConfiguration){
      _maxInit=true;
      if(kDebugMode&&showMediationDebugger==true){
        AppLovinMAX.showMediationDebugger();
      }
      _setAdListener();
      loadAdByType(AdType.open);
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
    AppLovinMAX.setAppOpenAdListener(
        AppOpenAdListener(
            onAdLoadedCallback: (MaxAd ad) {
              LoadAdUtils.instance.loadAdSuccess(ad);
              LoadAdUtils2.instance.loadAdSuccess(ad);
              _loadAdListener?.loadSuccess.call();
            },
            onAdLoadFailedCallback: (String adUnitId, MaxError error) {
              LoadAdUtils.instance.loadAdFail(adUnitId);
              LoadAdUtils2.instance.loadAdFail(adUnitId);
            },
            onAdDisplayedCallback: (MaxAd ad) {
              printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
              _fullAdShowing=true;
              AdNumUtils.instance.updateShowNum();
              _removeMaxAd(AdType.open);
              _adShowListener?.showAdSuccess.call(ad);
            },
            onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
              printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
              _fullAdShowing=false;
              _removeMaxAd(AdType.open);
              _adShowListener?.showAdFail.call(ad,error);
            },
            onAdClickedCallback: (MaxAd ad) {
              AdNumUtils.instance.updateClickNum();
            },
            onAdHiddenCallback: (MaxAd ad) {
              _fullAdShowing=false;
              loadAdByType(AdType.open);
              _adShowListener?.onAdHidden.call(ad);
            },
            onAdRevenuePaidCallback: (MaxAd ad){
              _onAdRevenuePaidByAdjust(ad);
            }
        )
    );
    AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
          onAdLoadedCallback: (MaxAd ad) {
            LoadAdUtils.instance.loadAdSuccess(ad);
            LoadAdUtils2.instance.loadAdSuccess(ad);
            _loadAdListener?.loadSuccess.call();
          },
          onAdLoadFailedCallback: (String adUnitId, MaxError error) {
            LoadAdUtils.instance.loadAdFail(adUnitId);
            LoadAdUtils2.instance.loadAdFail(adUnitId);
          },
          onAdDisplayedCallback: (MaxAd ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            _removeMaxAd(AdType.reward);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess.call(ad);
          },
          onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            _fullAdShowing=false;
            _removeMaxAd(AdType.reward);
            _adShowListener?.showAdFail.call(ad,error);
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
            LoadAdUtils.instance.loadAdSuccess(ad);
            LoadAdUtils2.instance.loadAdSuccess(ad);
            _loadAdListener?.loadSuccess.call();
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            LoadAdUtils.instance.loadAdFail(adUnitId);
            LoadAdUtils2.instance.loadAdFail(adUnitId);
          },
          onAdDisplayedCallback: (ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            var isOpen = LoadAdUtils.instance.checkIsOpenTypeById(ad.adUnitId)||LoadAdUtils2.instance.checkIsOpenTypeById(ad.adUnitId);
            _removeMaxAd(isOpen?AdType.open:AdType.inter);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess.call(ad);
          },
          onAdDisplayFailedCallback: (ad, error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            var isOpen = LoadAdUtils.instance.checkIsOpenTypeById(ad.adUnitId)||LoadAdUtils2.instance.checkIsOpenTypeById(ad.adUnitId);
            _removeMaxAd(isOpen?AdType.open:AdType.inter);
            _adShowListener?.showAdFail.call(ad,error);
          },
          onAdClickedCallback: (ad) {
            AdNumUtils.instance.updateClickNum();
          },
          onAdHiddenCallback: (ad) {
            _fullAdShowing=false;
            var isOpen = LoadAdUtils.instance.checkIsOpenTypeById(ad.adUnitId)||LoadAdUtils2.instance.checkIsOpenTypeById(ad.adUnitId);
            loadAdByType(isOpen?AdType.open:AdType.inter);
            _adShowListener?.onAdHidden.call(ad);
          },
          onAdRevenuePaidCallback: (MaxAd ad){
            _onAdRevenuePaidByAdjust(ad);
          }
        )
    );
  }

  _removeMaxAd(AdType adType){
    LoadAdUtils.instance.removeAdByType(adType);
    LoadAdUtils2.instance.removeAdByType(adType);
  }

  setMaxAdInfo(MaxAdBean maxAdBean){
    printDebug("FlutterMaxAd max ad info--->${maxAdBean.toString()}");
    AdNumUtils.instance.setNumInfo(maxAdBean);
    maxAdBean.firstOpenAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.secondOpenAdList.sort((a, b) => (b.sort).compareTo(a.sort));
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
    if(!_maxInit){
      printDebug("FlutterMaxAd not init");
      return;
    }
    if(_fullAdShowing){
      printDebug("FlutterMaxAd show ad fail, has ad showing");
      return;
    }
    _adShowListener=adShowListener;
    var resultBean = LoadAdUtils.instance.getAdResultByAdType(adType);
    resultBean ??= LoadAdUtils2.instance.getAdResultByAdType(adType);
    if(null!=resultBean){
      printDebug("FlutterMaxAd --->start show ad $adType");
      switch(adType){
        case AdType.reward:
          if(await AppLovinMAX.isRewardedAdReady(resultBean.maxAd.adUnitId)==true){
            AppLovinMAX.showRewardedAd(resultBean.maxAd.adUnitId);
          }else{
            printDebug("FlutterMaxAd isRewardedAdReady=false");
            _removeMaxAd(adType);
            _adShowListener?.showAdFail.call(null,null);
          }
          break;
        case AdType.inter:
          if(await AppLovinMAX.isInterstitialReady(resultBean.maxAd.adUnitId)==true){
            AppLovinMAX.showInterstitial(resultBean.maxAd.adUnitId);
          }else{
            printDebug("FlutterMaxAd isRewardedAdReady=false");
            _removeMaxAd(adType);
            _adShowListener?.showAdFail.call(null,null);
          }
          break;
        case AdType.open:
          if(resultBean.maxAdInfoBean.adType==AdType.open){
            if(await AppLovinMAX.isAppOpenAdReady(resultBean.maxAd.adUnitId)==true){
              AppLovinMAX.showAppOpenAd(resultBean.maxAd.adUnitId);
            }else{
              printDebug("FlutterMaxAd isRewardedAdReady=false");
              _removeMaxAd(adType);
              _adShowListener?.showAdFail.call(null,null);
            }
          }else if(resultBean.maxAdInfoBean.adType==AdType.inter){
            if(await AppLovinMAX.isInterstitialReady(resultBean.maxAd.adUnitId)==true){
              AppLovinMAX.showInterstitial(resultBean.maxAd.adUnitId);
            }else{
              printDebug("FlutterMaxAd isRewardedAdReady=false");
              _removeMaxAd(adType);
              _adShowListener?.showAdFail.call(null,null);
            }
          }
          break;
        default:
          break;
      }
    }else{
      printDebug("FlutterMaxAd --->$adType result == null");
    }
  }

  fullAdShowing()=>_fullAdShowing;

  _onAdRevenuePaidByAdjust(MaxAd ad){
    var adjustAdRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAppLovinMAX,);
    adjustAdRevenue.setRevenue(ad.revenue, "USD");
    adjustAdRevenue.adRevenueNetwork=ad.networkName;
    adjustAdRevenue.adRevenueUnit=ad.adUnitId;
    adjustAdRevenue.adRevenuePlacement=ad.placement;
    Adjust.trackAdRevenueNew(adjustAdRevenue);
    _facebookAppEvents.logPurchase(amount: ad.revenue, currency: "USD");
    _adShowListener?.onAdRevenuePaidCallback.call(ad,_getMaxInfoById(ad.adUnitId));
  }

  MaxAdInfoBean? _getMaxInfoById(String id){
    var infoBean = LoadAdUtils.instance.getAdInfoById(id);
    infoBean ??= LoadAdUtils2.instance.getAdInfoById(id);
    return infoBean;
  }

  bool checkHasCache(AdType adType){
    if(adType==AdType.open){
      var hasCache = LoadAdUtils.instance.checkHasCache(AdType.open)||LoadAdUtils.instance.checkHasCache(AdType.inter);
      if(!hasCache){
        return LoadAdUtils2.instance.checkHasCache(AdType.open)||LoadAdUtils2.instance.checkHasCache(AdType.inter);
      }
      return true;
    }
    var hasCache = LoadAdUtils.instance.checkHasCache(adType);
    if(!hasCache){
      return LoadAdUtils2.instance.checkHasCache(adType);
    }
    return true;
  }

  printDebug(Object? object){
    if(kDebugMode){
      print(object);
    }
  }
}
