//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPluginResult.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDVPluginResult (BCPFactoryMethods)

+ (instancetype)bcp_success;
+ (instancetype)bcp_successWithMessageAsString:(NSString *)message;
+ (instancetype)bcp_error;

@end

NS_ASSUME_NONNULL_END
