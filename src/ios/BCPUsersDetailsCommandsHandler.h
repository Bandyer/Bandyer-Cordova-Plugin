//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVCommandDelegate.h>

@class BCPUsersDetailsCache;

NS_ASSUME_NONNULL_BEGIN

@interface BCPUsersDetailsCommandsHandler : NSObject

- (instancetype)initWithCommandDelegate:(id <CDVCommandDelegate>)commandDelegate cache:(BCPUsersDetailsCache *)cache;

- (void)addUsersDetails:(CDVInvokedUrlCommand *)command;
- (void)purge:(CDVInvokedUrlCommand *)command;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
