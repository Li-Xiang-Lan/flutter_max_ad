import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_result_bean.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';

class LoadAdUtils{
  static final LoadAdUtils _instance = LoadAdUtils();

  static LoadAdUtils get instance => _instance;

  late MaxAdBean _maxAdBean;
  final List<AdType> _loadingList=[];
  final Map<AdType,MaxAdResultBean> _resultMap={};

  initAdInfo(MaxAdBean bean){
    _maxAdBean=bean;
  }

  loadAd(AdType adType){
    if(_loadingList.contains(adType)){
      printDebug("flutter max new ad --->$adType is loading");
      return;
    }
    if(_checkHasCache(adType)){
      printDebug("flutter max new ad --->$adType has cache");
      return;
    }
    var list = _getAdListByType(adType);
    if(list.isEmpty){
      printDebug("flutter max new ad --->$adType list is empty");
      return;
    }
    _loadingList.add(adType);
    _loadAdByType(adType,list.first);
  }

  _loadAdByType(AdType adType,MaxAdInfoBean bean){
    switch(bean.adType){
      case AdType.open:

        break;
      case AdType.reward:
        AppLovinMAX.loadRewardedAd(bean.id);
        break;
      case AdType.inter:
        AppLovinMAX.loadInterstitial(bean.id);
        break;
      default:

        break;
    }
  }

  bool _checkHasCache(AdType adType){
    var bean = _resultMap[adType];
    if(null!=bean?.maxAd){
      var expired = DateTime.now().millisecondsSinceEpoch-(bean?.loadTime??0)>(bean?.maxAdInfoBean.expire??0)*1000;
      if(expired){
        removeAdByType(adType);
        return false;
      }else{
        return true;
      }
    }
    return false;
  }

  List<MaxAdInfoBean> _getAdListByType(AdType adType){
    switch(adType){
      case AdType.open: return [];
      case AdType.reward: return _maxAdBean.firstRewardedAdList;
      case AdType.inter: return _maxAdBean.firstInterAdList;
      default: return [];
    }
  }

  loadAdSuccess(MaxAd ad){
    var info = _getAdInfoById(ad.adUnitId);
    if(null!=info){
      printDebug("flutter max new ad --->${info.adType} load success");
      _loadingList.remove(info.adType);
      _resultMap[info.adType]=MaxAdResultBean(maxAd: ad, loadTime: DateTime.now().millisecondsSinceEpoch, maxAdInfoBean: info);
    }
  }

  loadAdFail(String adUnitId){
    var info = _getAdInfoById(adUnitId);
    if(null!=info){
      printDebug("flutter max new ad --->${info.adType} load fail");
      _loadingList.remove(info.adType);
    }
  }

  MaxAdResultBean? getAdResultByAdType(AdType adType)=>_resultMap[adType];

  MaxAdInfoBean? _getAdInfoById(String id){
    var indexWhere = _maxAdBean.firstOpenAdList.indexWhere((element) => element.id==id);
    if(indexWhere>=0){
      return _maxAdBean.firstOpenAdList[indexWhere];
    }
    var indexWhere2 = _maxAdBean.firstRewardedAdList.indexWhere((element) => element.id==id);
    if(indexWhere2>=0){
      return _maxAdBean.firstRewardedAdList[indexWhere2];
    }
    var indexWhere3 = _maxAdBean.firstInterAdList.indexWhere((element) => element.id==id);
    if(indexWhere3>=0){
      return _maxAdBean.firstInterAdList[indexWhere3];
    }
    return null;
  }

  removeAdByType(AdType adType){
    _resultMap.remove(adType);
  }

  printDebug(Object? object){
    if(kDebugMode){
      print(object);
    }
  }
}