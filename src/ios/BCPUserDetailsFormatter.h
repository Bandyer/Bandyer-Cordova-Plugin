// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BCPUserDetailsFormatter : NSFormatter

- (instancetype)initWithFormat:(NSString *)format;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
