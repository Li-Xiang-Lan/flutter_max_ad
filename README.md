# flutter_max_ad

A new Flutter project.

## Getting Started

### Set Proguard

#### Android

Open your android->app->repositories, add content in this file
```dart
google()
jcenter()
mavenCentral()
gradlePluginPortal()
maven { url 'https://jitpack.io' }
maven { url 'https://artifacts.applovin.com/android' }
maven { url "https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea" }
maven { url "https://artifact.bytedance.com/repository/pangle" }
maven { url "https://cboost.jfrog.io/artifactory/chartboost-ads/" }
maven { url 'https://jfrog.anythinktech.com/artifactory/overseas_sdk' }
maven { url "https://android-sdk.is.com" }
```

Open your app->`build.gradle`, add content in this file
```dart
implementation 'com.applovin.mediation:inmobi-adapter:10.1.4.3'
implementation 'com.applovin.mediation:chartboost-adapter:9.4.1.0'
implementation 'com.applovin.mediation:unityads-adapter:4.8.0.0'
implementation 'com.applovin.mediation:vungle-adapter:6.12.1.1'
implementation 'com.applovin.mediation:mintegral-adapter:16.5.11.0'
implementation 'com.applovin.mediation:bytedance-adapter:5.4.1.0.0'
implementation 'com.applovin.mediation:google-adapter:22.3.0.0'
implementation 'com.applovin.mediation:google-ad-manager-adapter:22.3.0.0'
implementation 'com.applovin.mediation:fyber-adapter:8.2.4.0'
implementation 'com.applovin.mediation:ironsource-adapter:+'
implementation 'com.applovin.mediation:facebook-adapter:6.16.0.0'
implementation 'com.squareup.picasso:picasso:2.71828'
```

Open your AndroidManifest, add content in this file
```dart
  <uses-library
     android:name="org.apache.http.legacy"
     android:required="false" />
  <meta-data
     android:name="com.google.android.gms.ads.APPLICATION_ID"
     android:value="ca-app-pub-3940256099942544~3347511713" />
  <meta-data
     android:name="com.google.android.gms.ads.AD_MANAGER_APP"
     android:value="true" />
```

#### iOS

Open your Podfile, add content in target 'Runner' do

```dart
pod 'AppLovinSDK'
pod 'AppLovinMediationChartboostAdapter'
pod 'AppLovinMediationFyberAdapter'
pod 'AppLovinMediationGoogleAdManagerAdapter'
pod 'AppLovinMediationGoogleAdapter'
pod 'AppLovinMediationInMobiAdapter'
pod 'AppLovinMediationIronSourceAdapter'
pod 'AppLovinMediationVungleAdapter'
pod 'AppLovinMediationMintegralAdapter'
pod 'AppLovinMediationUnityAdsAdapter'
```
