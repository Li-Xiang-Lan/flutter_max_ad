import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_result_bean.dart';
import 'package:flutter_max_ad/ad/ad_type.dart';

class LoadAdUtils2{
  static final LoadAdUtils2 _instance = LoadAdUtils2();

  static LoadAdUtils2 get instance => _instance;

  late MaxAdBean _maxAdBean;
  final List<AdType> _loadingList=[];
  final Map<AdType,MaxAdResultBean> _resultMap={};

  initAdInfo(MaxAdBean bean){
    _maxAdBean=bean;
  }

  loadAd(AdType adType){
    if(_loadingList.contains(adType)){
      printDebug("FlutterMaxAd2 --->$adType is loading");
      return;
    }
    if(checkHasCache(adType)){
      printDebug("FlutterMaxAd2 --->$adType has cache");
      return;
    }
    var list = _getAdListByType(adType);
    if(list.isEmpty){
      printDebug("FlutterMaxAd2 --->$adType list is empty");
      return;
    }
    _loadingList.add(adType);
    _loadAdByType(adType,list.first);
  }

  _loadAdByType(AdType adType,MaxAdInfoBean bean){
    printDebug("FlutterMaxAd2 --->start load $adType ad,data=${bean.toString()}");
    switch(bean.adType){
      case AdType.open:
        if(bean.adType==AdType.open){
          AppLovinMAX.loadAppOpenAd(bean.id);
        }else if(bean.adType==AdType.inter){
          AppLovinMAX.loadInterstitial(bean.id);
        }else{
          _loadingList.remove(adType);
        }
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

  bool checkHasCache(AdType adType){
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
      case AdType.open: return _maxAdBean.secondOpenAdList;
      case AdType.reward: return _maxAdBean.secondRewardedAdList;
      case AdType.inter: return _maxAdBean.secondInterAdList;
      default: return [];
    }
  }

  loadAdSuccess(MaxAd ad){
    var info = _getAdInfoById(ad.adUnitId);
    if(null!=info){
      printDebug("FlutterMaxAd2 --->${info.adType} load success");
      _loadingList.remove(info.adType);
      _resultMap[info.adType]=MaxAdResultBean(maxAd: ad, loadTime: DateTime.now().millisecondsSinceEpoch, maxAdInfoBean: info);
    }
  }

  loadAdFail(String adUnitId){
    var info = _getAdInfoById(adUnitId);
    if(null!=info){
      printDebug("FlutterMaxAd2 --->${info.adType} load fail");
      var nextAdInfo = getNextAdInfoById(adUnitId);
      if(null!=nextAdInfo){
        _loadAdByType(info.adType, nextAdInfo);
      }else{
        _loadingList.remove(info.adType);
      }
    }
  }

  MaxAdResultBean? getAdResultByAdType(AdType adType)=>_resultMap[adType];

  MaxAdInfoBean? _getAdInfoById(String id){
    var indexWhere = _maxAdBean.secondOpenAdList.indexWhere((element) => element.id==id);
    if(indexWhere>=0){
      return _maxAdBean.secondOpenAdList[indexWhere];
    }
    var indexWhere2 = _maxAdBean.secondRewardedAdList.indexWhere((element) => element.id==id);
    if(indexWhere2>=0){
      return _maxAdBean.secondRewardedAdList[indexWhere2];
    }
    var indexWhere3 = _maxAdBean.secondInterAdList.indexWhere((element) => element.id==id);
    if(indexWhere3>=0){
      return _maxAdBean.secondInterAdList[indexWhere3];
    }
    return null;
  }

  MaxAdInfoBean? getNextAdInfoById(String id){
    var indexWhere = _maxAdBean.secondOpenAdList.indexWhere((element) => element.id==id);
    if(indexWhere>=0&&_maxAdBean.secondOpenAdList.length>indexWhere+1){
      return _maxAdBean.secondOpenAdList[indexWhere+1];
    }
    var indexWhere2 = _maxAdBean.secondRewardedAdList.indexWhere((element) => element.id==id);
    if(indexWhere2>=0&&_maxAdBean.secondRewardedAdList.length>indexWhere+1){
      return _maxAdBean.secondRewardedAdList[indexWhere2+1];
    }
    var indexWhere3 = _maxAdBean.secondInterAdList.indexWhere((element) => element.id==id);
    if(indexWhere3>=0&&_maxAdBean.secondInterAdList.length>indexWhere+1){
      return _maxAdBean.secondInterAdList[indexWhere3+1];
    }
    return null;
  }

  removeAdByType(AdType adType){
    _resultMap.remove(adType);
  }

  removeAdById(String id){
    var infoBean = _getAdInfoById(id);
    if(null!=infoBean){
      removeAdByType(infoBean.adType);
    }
  }

  printDebug(Object? object){
    if(kDebugMode){
      print(object);
    }
  }
}