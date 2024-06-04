import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_max_ad_method_channel.dart';

abstract class FlutterMaxAdPlatform extends PlatformInterface {
  /// Constructs a FlutterMaxAdPlatform.
  FlutterMaxAdPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterMaxAdPlatform _instance = MethodChannelFlutterMaxAd();

  /// The default instance of [FlutterMaxAdPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterMaxAd].
  static FlutterMaxAdPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterMaxAdPlatform] when
  /// they register themselves.
  static set instance(FlutterMaxAdPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
  Future<String> dismissMaxAdView()=>_instance.dismissMaxAdView();

}
