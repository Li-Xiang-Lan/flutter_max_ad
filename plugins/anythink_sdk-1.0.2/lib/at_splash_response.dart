
import 'package:anythink_sdk/at_base_response.dart';

/*Splash status */
enum SplashStatus {
  splashDidFinishLoading,
  splashDidFailToLoad,
  splashDidTimeout,
  splashDidShowSuccess,
  splashDidShowFailed,
  splashDidClick,
  splashDidClose,
  splashWillClose,
  splashDidDeepLink,

  splashUnknown
}

/*Splash callback */
class ATSplashResponse extends BaseResponse {
  final SplashStatus splashStatus;
  final Map extraMap;
  final bool? isTimeout;

  ATSplashResponse(this.splashStatus,this.extraMap,String errStr,String placementID,bool isDeeplinkSuccess, this.isTimeout):
        super(errStr,placementID,isDeeplinkSuccess);


 factory ATSplashResponse.withMap(Map map){

   var tempSplashStatus;
   var requestMessage = map['requestMessage'];
   var placementID = map['placementID'];
   var adStatus = map['callbackName'];

   var tempExtraMap;


   var isDeeplinkSuccess = false;
   if (map.containsKey('isDeeplinkSuccess')){
     isDeeplinkSuccess =  map['isDeeplinkSuccess'];
   }

   if (map.containsKey('extraDic')){
     tempExtraMap =  map['extraDic'];
   }else{
     tempExtraMap =  {'message': 'No additional information'};
   }

   var isTimeout = false;
   if (map.containsKey('isTimeout')){
     isTimeout =  map['isTimeout'];
   }


   if (adStatus == 'splashDidFailToLoad'){
     tempSplashStatus = SplashStatus.splashDidFailToLoad;
   }
   else if(adStatus == 'splashDidFinishLoading'){
     tempSplashStatus = SplashStatus.splashDidFinishLoading;
   }
   else if(adStatus == 'splashDidTimeout'){
     tempSplashStatus = SplashStatus.splashDidTimeout;
   }
   else if(adStatus == 'splashDidShowSuccess'){
     tempSplashStatus = SplashStatus.splashDidShowSuccess;
   }
   else if(adStatus == 'splashDidShowFailed'){
     tempSplashStatus = SplashStatus.splashDidShowFailed;
   }
   else if(adStatus == 'splashDidClick'){
     tempSplashStatus = SplashStatus.splashDidClick;
   }
   else if(adStatus == 'splashDidClose'){
     tempSplashStatus = SplashStatus.splashDidClose;
   }
   else if(adStatus == 'splashWillClose'){
     tempSplashStatus = SplashStatus.splashWillClose;
   }
   else if(adStatus == 'splashDidDeepLink'){
     tempSplashStatus = SplashStatus.splashDidDeepLink;
   }

   else{
     tempSplashStatus = SplashStatus.splashUnknown;
   }

   return ATSplashResponse(tempSplashStatus,tempExtraMap,requestMessage,placementID,isDeeplinkSuccess,isTimeout);

 }
}







