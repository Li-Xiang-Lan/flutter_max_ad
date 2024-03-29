import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';

abstract class BaseLoad{
  bool isLoading();
  bool checkHasCache();
  loadAd(int index);
  loadAdFail(String adUnitId);
  loadAdSuccess(MaxAd ad);
  Future<MaxAd?> getMaxAd();
  MaxAdInfoBean? getMaxInfoById(String adUnitId);
  removeMaxAd(String adUnitId);
}