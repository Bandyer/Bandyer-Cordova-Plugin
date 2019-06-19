//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "AppDelegate+BandyerPlugin.h"
#import "BCPSwizzler.h"

@implementation AppDelegate (BandyerPlugin)

+ (void)load {
    [AppDelegate swizzleReceiveIncomingPushPayload];
    [AppDelegate swizzleReceiveIncomingPushPayloadWithCompletionHandler];
}

+ (void)swizzleReceiveIncomingPushPayload {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:);
        SEL swizzledSelector = @selector(bandyerPushRegistry:didReceiveIncomingPushWithPayload:forType:);
        
        BCPSwizzler *swizzler = [[BCPSwizzler alloc] initWithClass:[self class] sourceSelector:originalSelector targetSelector:swizzledSelector];
        [swizzler swizzle];
    });
}

+ (void)swizzleReceiveIncomingPushPayloadWithCompletionHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:);
        SEL swizzledSelector = @selector(bandyerPushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:);
        
        BCPSwizzler *swizzler = [[BCPSwizzler alloc] initWithClass:[self class] sourceSelector:originalSelector targetSelector:swizzledSelector];
        [swizzler swizzle];
    });
}

- (void)bandyerPushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    [[BandyerManager shared] setPayload:payload];
        
    [[BandyerManager shared].webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.pushRegistryListener('ios_didReceiveIncomingPushWithPayload')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    [self bandyerPushRegistry:registry didReceiveIncomingPushWithPayload:payload forType:type];
}

- (void)bandyerPushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    [[BandyerManager shared] setPayload:payload];
        
    [[BandyerManager shared].webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.pushRegistryListener('ios_didReceiveIncomingPushWithPayload')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    [self bandyerPushRegistry:registry didReceiveIncomingPushWithPayload:payload forType:type withCompletionHandler:completion];
}

@end
