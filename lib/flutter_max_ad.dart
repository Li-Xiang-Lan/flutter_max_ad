import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_max_ad/ad/ad_location_key.dart';
import 'package:flutter_max_ad/ad/ad_num_utils.dart';
import 'package:flutter_max_ad/ad/ad_show_listener.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';
import 'package:flutter_max_ad/ad/load_ad/base_load.dart';
import 'package:flutter_max_ad/ad/load_ad/inter_ad.dart';
import 'package:flutter_max_ad/ad/load_ad/load_ad_listener.dart';
import 'package:flutter_max_ad/ad/load_ad/open_ad.dart';
import 'package:flutter_max_ad/ad/load_ad/rewared_ad.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';

class FlutterMaxAd {
  static final FlutterMaxAd _instance = FlutterMaxAd();

  static FlutterMaxAd get instance => _instance;

  var _maxInit=false,_isBuyUser=false,_fullAdShowing=false;
  final Map<String,BaseLoad> _loadAdMap={};
  AdShowListener? _adShowListener;
  LoadAdListener? _loadAdListener;

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
    }
  }

  setBuyUser(bool buyUser){
    _isBuyUser=buyUser;
  }

  setLoadAdListener(LoadAdListener loadAdListener){
    _loadAdListener=loadAdListener;
  }

  loadAdByType(AdType adType)async{
    if(!_maxInit){
      printDebug("FlutterMaxAd not init");
      return;
    }
    if(!_isBuyUser){
      printDebug("FlutterMaxAd not buy user, can not load ad");
      return;
    }
    if(AdNumUtils.instance.getAdNumLimit()){
      printDebug("FlutterMaxAd show or click num limit");
      return;
    }
    if(_getAdLoadingByType(adType)){
      printDebug("FlutterMaxAd $adType is loading");
      return;
    }
    switch(adType){
      case AdType.open:
        _loadAdMap[AdLocationKey.open]?.loadAd(0);
        break;
      case AdType.reward:
        _loadAdMap[AdLocationKey.firstRewarded]?.loadAd(0);
        _loadAdMap[AdLocationKey.secondRewarded]?.loadAd(0);
        break;
      case AdType.inter:
        _loadAdMap[AdLocationKey.firstInter]?.loadAd(0);
        _loadAdMap[AdLocationKey.secondInter]?.loadAd(0);
        break;
      default:break;
    }
  }

  bool _getAdLoadingByType(AdType adType){
    switch(adType){
      case AdType.open:
        return _loadAdMap[AdLocationKey.open]?.isLoading()??false;
      case AdType.reward:
        return (_loadAdMap[AdLocationKey.firstRewarded]?.isLoading()??false)||(_loadAdMap[AdLocationKey.secondRewarded]?.isLoading()??false);
      case AdType.inter:
        return (_loadAdMap[AdLocationKey.firstInter]?.isLoading()??false)||(_loadAdMap[AdLocationKey.secondInter]?.isLoading()??false);
      default:
        return false;
    }
  }

  _setAdListener(){
    AppLovinMAX.setAppOpenAdListener(
        AppOpenAdListener(
            onAdLoadedCallback: (MaxAd ad) {
              printDebug("FlutterMaxAd load open ad success,adUnitId--->${ad.adUnitId}");
              _loadAdListener?.loadSuccess.call();
              for (var element in _loadAdMap.keys) {
                _loadAdMap[element]?.loadAdSuccess(ad);
              }
            },
            onAdLoadFailedCallback: (String adUnitId, MaxError error) {
              printDebug("FlutterMaxAd load open ad fail--->adUnitId=$adUnitId---${error.code}---${error.message}");
              for (var element in _loadAdMap.keys) {
                _loadAdMap[element]?.loadAdFail(adUnitId);
              }
            },
            onAdDisplayedCallback: (MaxAd ad) {
              printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
              _fullAdShowing=true;
              AdNumUtils.instance.updateShowNum();
              _removeMaxAd(ad.adUnitId);
              _adShowListener?.showAdSuccess.call(ad);
            },
            onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
              printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
              _fullAdShowing=false;
              _removeMaxAd(ad.adUnitId);
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
            printDebug("FlutterMaxAd load reward ad success,adUnitId--->${ad.adUnitId}");
            _loadAdListener?.loadSuccess.call();
            for (var element in _loadAdMap.keys) {
              _loadAdMap[element]?.loadAdSuccess(ad);
            }
          },
          onAdLoadFailedCallback: (String adUnitId, MaxError error) {
            printDebug("FlutterMaxAd load reward ad fail--->adUnitId=$adUnitId---${error.code}---${error.message}");
            for (var element in _loadAdMap.keys) {
              _loadAdMap[element]?.loadAdFail(adUnitId);
            }
          },
          onAdDisplayedCallback: (MaxAd ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            _removeMaxAd(ad.adUnitId);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess.call(ad);
          },
          onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            _fullAdShowing=false;
            _removeMaxAd(ad.adUnitId);
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
            printDebug("FlutterMaxAd load inter ad success,adUnitId--->${ad.adUnitId}");
            _loadAdListener?.loadSuccess.call();
            for (var element in _loadAdMap.keys) {
              _loadAdMap[element]?.loadAdSuccess(ad);
            }
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            printDebug("FlutterMaxAd load inter ad fail--->adUnitId=$adUnitId---${error.code}---${error.message}");
            for (var element in _loadAdMap.keys) {
              _loadAdMap[element]?.loadAdFail(adUnitId);
            }
          },
          onAdDisplayedCallback: (ad) {
            printDebug("FlutterMaxAd show ad success---->${ad.adUnitId}");
            _fullAdShowing=true;
            _removeMaxAd(ad.adUnitId);
            AdNumUtils.instance.updateShowNum();
            _adShowListener?.showAdSuccess.call(ad);
          },
          onAdDisplayFailedCallback: (ad, error) {
            printDebug("FlutterMaxAd show ad fail---->${ad.adUnitId}---${error.message}");
            _removeMaxAd(ad.adUnitId);
            _adShowListener?.showAdFail.call(ad,error);
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

  _removeMaxAd(String adUnitId){
    for (var element in _loadAdMap.keys) {
      _loadAdMap[element]?.removeMaxAd(adUnitId);
    }
  }

  setMaxAdInfo(MaxAdBean maxAdBean){
    printDebug("FlutterMaxAd max ad info--->${maxAdBean.toString()}");
    AdNumUtils.instance.setNumInfo(maxAdBean);
    maxAdBean.openAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.firstRewardedAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.secondRewardedAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.firstInterAdList.sort((a, b) => (b.sort).compareTo(a.sort));
    maxAdBean.secondInterAdList.sort((a, b) => (b.sort).compareTo(a.sort));

    _loadAdMap[AdLocationKey.open]=OpenAd(adInfoList: maxAdBean.openAdList);
    _loadAdMap[AdLocationKey.firstRewarded]=RewordedAd(adInfoList: maxAdBean.firstRewardedAdList);
    _loadAdMap[AdLocationKey.secondRewarded]=RewordedAd(adInfoList: maxAdBean.secondRewardedAdList);
    _loadAdMap[AdLocationKey.firstInter]=InterAd(adInfoList: maxAdBean.firstInterAdList);
    _loadAdMap[AdLocationKey.secondInter]=InterAd(adInfoList: maxAdBean.secondInterAdList);
  }

  Future<MaxAd?> checkHasMaxAd(AdType adType)async{
    switch(adType){
      case AdType.open:
        return _loadAdMap[AdLocationKey.open]?.getMaxAd();
      case AdType.reward:
        var firstMaxAd = await _loadAdMap[AdLocationKey.firstRewarded]?.getMaxAd();
        if(null==firstMaxAd){
          var secondMaxAd = await _loadAdMap[AdLocationKey.secondRewarded]?.getMaxAd();
          if(null!=secondMaxAd){
            firstMaxAd=secondMaxAd;
          }
        }
        return firstMaxAd;
      case AdType.inter:
        var firstMaxAd = await _loadAdMap[AdLocationKey.firstInter]?.getMaxAd();
        if(null==firstMaxAd){
          var secondMaxAd = await _loadAdMap[AdLocationKey.secondInter]?.getMaxAd();
          if(null!=secondMaxAd){
            firstMaxAd=secondMaxAd;
          }
        }
        return firstMaxAd;
      default:
        return null;
    }
  }

  showAd({
    required AdType adType,
    required AdShowListener? adShowListener
  })async{
    if(!_maxInit){
      printDebug("FlutterMaxAd not init");
      return;
    }
    if(!_isBuyUser){
      printDebug("FlutterMaxAd show ad fail, not buy user");
      return;
    }
    if(_fullAdShowing){
      printDebug("FlutterMaxAd show ad fail, has ad showing");
      return;
    }
    _adShowListener=adShowListener;
    switch(adType){
      case AdType.open:
        var maxAd = await checkHasMaxAd(adType);
        if(null!=maxAd){
          var openMaxAdType = _loadAdMap[AdLocationKey.open]?.getMaxInfoById(maxAd.adUnitId)?.adType;
          if(openMaxAdType==AdType.open){
            printDebug("FlutterMaxAd start show open ad-->${maxAd.adUnitId}");
            AppLovinMAX.showAppOpenAd(maxAd.adUnitId);
          }else if(openMaxAdType==AdType.inter){
            printDebug("FlutterMaxAd start show open ad-->${maxAd.adUnitId}");
            AppLovinMAX.showInterstitial(maxAd.adUnitId);
          }else{
            printDebug("FlutterMaxAd show open ad fail,open ad result type not match");
            _adShowListener?.showAdFail.call(null,null);
          }
        }else{
          printDebug("FlutterMaxAd show open ad fail,no open result");
          _adShowListener?.showAdFail.call(null,null);
        }
        break;
      case AdType.reward:
        var maxAd = await checkHasMaxAd(adType);
        if(null!=maxAd){
          printDebug("FlutterMaxAd start show reward ad-->${maxAd.adUnitId}");
          AppLovinMAX.showRewardedAd(maxAd.adUnitId);
        }else{
          printDebug("FlutterMaxAd show reward ad fail,no reward result");
          _adShowListener?.showAdFail.call(null,null);
        }
        break;
      case AdType.inter:
        var maxAd = await checkHasMaxAd(adType);
        if(null!=maxAd){
          printDebug("FlutterMaxAd start show inter ad-->${maxAd.adUnitId}");
          AppLovinMAX.showInterstitial(maxAd.adUnitId);
        }else{
          printDebug("FlutterMaxAd show inter ad fail,no inter result");
          _adShowListener?.showAdFail.call(null,null);
        }
        break;
      default:

        break;
    }
  }

  fullAdShowing()=>_fullAdShowing;

  MaxAdInfoBean? _getMaxInfoById(String adUnitId){
    for (var element in _loadAdMap.keys) {
      var infoBean = _loadAdMap[element]?.getMaxInfoById(adUnitId);
      if(null!=infoBean){
        return infoBean;
      }
    }
    return null;
  }

  startLoadAdCallBack(){
    _loadAdListener?.startLoad.call();
  }

  _onAdRevenuePaidByAdjust(MaxAd ad){
    var adjustAdRevenue = AdjustAdRevenue(AdjustConfig.AdRevenueSourceAppLovinMAX,);
    adjustAdRevenue.setRevenue(ad.revenue, "USD");
    adjustAdRevenue.adRevenueNetwork=ad.networkName;
    adjustAdRevenue.adRevenueUnit=ad.adUnitId;
    adjustAdRevenue.adRevenuePlacement=ad.placement;
    Adjust.trackAdRevenueNew(adjustAdRevenue);
    _adShowListener?.onAdRevenuePaidCallback.call(ad,_getMaxInfoById(ad.adUnitId));
  }

  printDebug(Object? object){
    if(kDebugMode){
      print(object);
    }
  }
}
