import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';

class AdShowListener{
  final Function(MaxAd? ad,MaxAdInfoBean? maxAdInfoBean)? showAdSuccess;
  final Function(MaxAd? ad, MaxError? error)? showAdFail;
  final Function(MaxAd? ad) onAdHidden;
  final Function(MaxAd ad, MaxReward reward)? onAdReceivedReward;
  final Function(MaxAd ad)? onAdRevenuePaidCallback;
  AdShowListener({
    required this.onAdHidden,
    this.showAdSuccess,
    this.showAdFail,
    this.onAdRevenuePaidCallback,
    this.onAdReceivedReward,
});
}