//
//  Created by WhiteTiger "sgama la rete" on 24/05/2019.
//

#import "AppDelegate+BandyerPlugin.h"

@implementation AppDelegate (BandyerPlugin)

+ (void)load {
    [AppDelegate swizzledReceiveIncomingPushPayload];
    [AppDelegate swizzledReceiveIncomingPushPayloadWithCompletionHandler];
}

+ (void)swizzledReceiveIncomingPushPayload {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:);
        SEL swizzledSelector = @selector(bandyerPushRegistry:didReceiveIncomingPushWithPayload:forType:);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

+ (void)swizzledReceiveIncomingPushPayloadWithCompletionHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(pushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:);
        SEL swizzledSelector = @selector(bandyerPushRegistry:didReceiveIncomingPushWithPayload:forType:withCompletionHandler:);
        
        Method original = class_getInstanceMethod(class, originalSelector);
        Method swizzled = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzled),
                        method_getTypeEncoding(swizzled));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(original),
                                method_getTypeEncoding(original));
        } else {
            method_exchangeImplementations(original, swizzled);
        }
    });
}

- (void)bandyerPushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    [[BandyerManager shared] setPayload:payload];
    
    NSLog(@"%s", __FUNCTION__);
    
    [[BandyerManager shared].webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.pushRegistryListener('ios_didReceiveIncomingPushWithPayload')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    [self bandyerPushRegistry:registry didReceiveIncomingPushWithPayload:payload forType:type];
}

- (void)bandyerPushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    [[BandyerManager shared] setPayload:payload];
    
    NSLog(@"%s", __FUNCTION__);
    
    [[BandyerManager shared].webViewEngine evaluateJavaScript:@"window.cordova.plugins.BandyerPlugin.pushRegistryListener('ios_didReceiveIncomingPushWithPayload')" completionHandler:^(id obj, NSError *error) {
        // NOP
    }];
    
    [self bandyerPushRegistry:registry didReceiveIncomingPushWithPayload:payload forType:type withCompletionHandler:completion];
}

@end
