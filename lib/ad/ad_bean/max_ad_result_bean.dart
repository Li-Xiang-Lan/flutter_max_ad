import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';

class MaxAdResultBean{
  MaxAd maxAd;
  int loadTime;
  MaxAdInfoBean maxAdInfoBean;
  MaxAdResultBean({
    required this.maxAd,
    required this.loadTime,
    required this.maxAdInfoBean
  });
}