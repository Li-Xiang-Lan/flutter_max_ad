import 'package:flutter_max_ad/ad/ad_bean/max_ad_bean.dart';
import 'package:flutter_max_ad/local_storage/local_storage.dart';
import 'package:flutter_max_ad/local_storage/local_storage_key.dart';

class AdNumUtils{
  factory AdNumUtils() => _getInstance();

  static AdNumUtils get instance => _getInstance();

  static AdNumUtils? _instance;

  static AdNumUtils _getInstance() {
    _instance ??= AdNumUtils._internal();
    return _instance!;
  }

  final Map<String,int> _loadFailNumMap={};
  var _todayAdShowNum=0,_todayAdClickNum=0,_maxShowNum=100,_maxClickNum=100;

  AdNumUtils._internal(){
    try{
      //2022-02-02_0
      var list = (LocalStorage.read<String>(LocalStorageKey.todayAdShowNum)??"").split("_");
      if(list.first==_getTodayTimeStr()){
        _todayAdShowNum=int.parse(list.last);
      }
    }catch(e){

    }
    try{
      //2022-02-02_0
      var list = (LocalStorage.read<String>(LocalStorageKey.todayAdClickNum)??"").split("_");
      if(list.first==_getTodayTimeStr()){
        _todayAdClickNum=int.parse(list.last);
      }
    }catch(e){

    }
  }

  setNumInfo(MaxAdBean maxAdBean){
    _maxShowNum=maxAdBean.maxShowNum;
    _maxClickNum=maxAdBean.maxClickNum;
  }

  updateShowNum(){
    _todayAdShowNum++;
    LocalStorage.write(LocalStorageKey.todayAdShowNum, "${_getTodayTimeStr()}_$_todayAdShowNum");
  }

  updateClickNum(){
    _todayAdClickNum++;
    LocalStorage.write(LocalStorageKey.todayAdClickNum, "${_getTodayTimeStr()}_$_todayAdClickNum");
  }

  getAdNumLimit()=>_todayAdClickNum>=_maxClickNum||_todayAdShowNum>=_maxShowNum;

  String _getTodayTimeStr(){
    var dateTime = DateTime.now();
    return "${dateTime.year}-${dateTime.month}-${dateTime.day}";
  }

  // addLoadFailNum(String adLocationName){
  //   var num = _loadFailNumMap[adLocationName]??0;
  //   _loadFailNumMap[adLocationName]=num++;
  // }
  //
  // resetLoadFailNum(String adLocationName){
  //   _loadFailNumMap[adLocationName]=0;
  // }
  //
  // int getLoadFailNum(String adLocationName)=>_loadFailNumMap[adLocationName]??0;
}