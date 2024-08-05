//
//  ATFSplashAdManger.m
//  anythink_sdk
//
//  Created by GUO PENG on 2023/9/7.
//

#import "ATFSplashAdManger.h"
#import "ATFSplashDelegate.h"
#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATFCommonTool.h"


@interface ATFSplashAdManger()

@property(nonatomic, strong) ATFSplashDelegate *splashAdDelegate;

@end


@implementation ATFSplashAdManger

/// 加载开屏
- (void)loadSplashAd:(NSString *)placementID extraDic:(NSDictionary *)extraDic {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:extraDic];
    NSString *keyString = @"tolerateTimeout";
    if ([extraDic.allKeys containsObject:keyString]) {
        [dic removeObjectForKey:keyString];
        dic[kATSplashExtraTolerateTimeoutKey] = @([extraDic[keyString] floatValue] * 0.001);
    }
    
    [[ATAdManager sharedManager] loadADWithPlacementID:placementID extra:dic delegate:self.splashAdDelegate];
}

/// 是否有广告缓存
- (BOOL)splashAdReady:(NSString *)placementID {
    
    BOOL isReady = [[ATAdManager sharedManager] splashReadyForPlacementID:placementID];
    return  isReady;
}

/// 检查广告状态
- (NSDictionary *)checkSplashAdLoadStatus:(NSString *)placementID {
    
    ATCheckLoadModel *checkLoadModel = [[ATAdManager sharedManager] checkSplashLoadStatusForPlacementID:placementID];
    NSDictionary *dic = [ATFCommonTool objectToJSONString:checkLoadModel];
    return  dic;
}

/// 获取当前广告位下所有可用广告的信息，v5.7.53及以上版本支持
- (NSString *)getSplashAdValidAds:(NSString *)placementID {

    NSArray *array = [[ATAdManager sharedManager] getSplashValidAdsForPlacementID:placementID];
    NSString *str = [ATFCommonTool toReadableJSONString:array];
    return str;
}

/// 展示开屏广告
- (void)showSplashAd:(NSString *)placementID {
    
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:@20000 forKey:kATSplashExtraCountdownKey];
    [mutableDict setValue:@1000 forKey:kATSplashExtraCountdownIntervalKey];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID scene:nil window:window delegate:self.splashAdDelegate];
    
}

///  展示场景开屏广告
- (void)showSplashAd:(NSString *)placementID sceneID:(NSString *)sceneID {
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
//    [mutableDict setValue:@20000 forKey:kATSplashExtraCountdownKey];
//    [mutableDict setValue:@1000 forKey:kATSplashExtraCountdownIntervalKey];
    
    if (sceneID == nil || sceneID.length == 0) {
        sceneID = @"";
    }
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [[ATAdManager sharedManager] showSplashWithPlacementID:placementID scene:sceneID window:window delegate:self.splashAdDelegate];
}

#pragma mark - lazy
- (ATFSplashDelegate *)splashAdDelegate {
    if (_splashAdDelegate) return _splashAdDelegate;
    ATFSplashDelegate *splashDelegate = [ATFSplashDelegate new];
    return _splashAdDelegate = splashDelegate;
}

@end
