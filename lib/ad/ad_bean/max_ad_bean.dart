
import 'package:flutter_max_ad/ad/ad_type.dart';

class MaxAdBean {
  int maxShowNum;
  int maxClickNum;
  List<MaxAdInfoBean> firstOpenAdList;
  List<MaxAdInfoBean> secondOpenAdList;
  List<MaxAdInfoBean> firstRewardedAdList;
  List<MaxAdInfoBean> secondRewardedAdList;
  List<MaxAdInfoBean> firstInterAdList;
  List<MaxAdInfoBean> secondInterAdList;
  MaxAdBean({
    required this.maxShowNum,
    required this.maxClickNum,
    required this.firstOpenAdList,
    required this.secondOpenAdList,
    required this.firstRewardedAdList,
    required this.secondRewardedAdList,
    required this.firstInterAdList,
    required this.secondInterAdList,
  });

  @override
  String toString() {
    return 'MaxAdBean{maxShowNum: $maxShowNum, maxClickNum: $maxClickNum, openAdList: $firstOpenAdList, firstRewardedAdList: $firstRewardedAdList, secondRewardedAdList: $secondRewardedAdList, firstInterAdList: $firstInterAdList, secondInterAdList: $secondInterAdList}';
  }
}

class MaxAdInfoBean{
  String id;
  String plat;
  AdType adType;
  int expire;
  int sort;
  String adLocationName;
  MaxAdInfoBean({
    required this.id,
    required this.plat,
    required this.adType,
    required this.expire,
    required this.sort,
    required this.adLocationName,
  });

  @override
  String toString() {
    return 'MaxAdInfoBean{id: $id, plat: $plat, adType: $adType, expire: $expire, sort: $sort, adLocationName: $adLocationName}';
  }
}