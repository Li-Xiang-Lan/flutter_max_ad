import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_max_ad_platform_interface.dart';

/// An implementation of [FlutterMaxAdPlatform] that uses method channels.
class MethodChannelFlutterMaxAd extends FlutterMaxAdPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_max_ad');

  @override
  Future<String> dismissMaxAdView() async{
    return await methodChannel.invokeMethod("dismissMaxAdView");
  }
}
