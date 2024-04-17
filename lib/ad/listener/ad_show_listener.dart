import 'package:applovin_max/applovin_max.dart';
import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';

class AdShowListener{
  final Function(MaxAd? ad) showAdSuccess;
  final Function(MaxAd? ad, MaxError? error) showAdFail;
  final Function(MaxAd? ad) onAdHidden;
  final Function(MaxAd ad, MaxReward reward)? onAdReceivedReward;
  final Function(MaxAd ad,MaxAdInfoBean? maxAdInfoBean) onAdRevenuePaidCallback;
  AdShowListener({
    required this.showAdSuccess,
    required this.showAdFail,
    required this.onAdHidden,
    required this.onAdRevenuePaidCallback,
    this.onAdReceivedReward,
});
}