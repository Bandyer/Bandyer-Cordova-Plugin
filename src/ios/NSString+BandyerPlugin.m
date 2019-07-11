//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "NSString+BandyerPlugin.h"

@implementation NSString (BandyerPlugin)

- (nullable BDKEnvironment *)toBDKEnvironment {
    NSString *environment = [self lowercaseString];
    
    if ([environment isEqualToString:@"sandbox"]) {
        return BDKEnvironment.sandbox;
    
    } else if ([environment isEqualToString:@"production"]) {
        return BDKEnvironment.production;
    }
    
    return nil;
}

- (BDKCallType)toBDKCallType {
    if ([[self lowercaseString] isEqualToString:@"audio"]) {
        return BDKCallTypeAudioOnly;
    } else if ([[self lowercaseString] isEqualToString:@"audioUpgradable"]) {
        return BDKCallTypeAudioUpgradable;
    } else {
        return BDKCallTypeAudioVideo;
    }
}

@end
