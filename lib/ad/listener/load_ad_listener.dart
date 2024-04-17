import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/export.dart';

class LoadAdListener{
  final Function() startLoad;
  final Function() loadSuccess;
  LoadAdListener({
    required this.startLoad,
    required this.loadSuccess,
});
}