// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <Foundation/Foundation.h>

@class BDKBroadcastScreensharingToolConfiguration;

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(12.0))
@interface BCPBroadcastConfigurationPlistReader : NSObject

- (nullable BDKBroadcastScreensharingToolConfiguration *)read:(NSURL *)fileURL error:(NSError * __autoreleasing _Nullable *)error ;

@end

NS_ASSUME_NONNULL_END
