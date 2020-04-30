//
// Copyright © 2019 Bandyer S.r.l. All Rights Reserved.
// See LICENSE for licensing information
//

#import "NSString+BandyerPlugin.h"

@implementation NSString (BandyerPlugin)

- (nullable BDKEnvironment *)toBDKEnvironment
{
    NSString *environment = [self lowercaseString];
    
    if ([environment isEqualToString:@"sandbox"])
        return BDKEnvironment.sandbox;
    
    if ([environment isEqualToString:@"production"])
        return BDKEnvironment.production;
    
    return nil;
}

- (BDKCallType)toBDKCallType
{
    if ([[self lowercaseString] isEqualToString:@"audio"])
        return BDKCallTypeAudioOnly;

    if ([[self lowercaseString] isEqualToString:@"audioupgradable"])
        return BDKCallTypeAudioUpgradable;

    return BDKCallTypeAudioVideo;
}

@end
