//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import "CDVPluginResult+BCPFactoryMethods.h"


@implementation CDVPluginResult (BCPFactoryMethods)

+ (instancetype)bcp_success
{
    return [self resultWithStatus:CDVCommandStatus_OK];
}

+ (instancetype)bcp_successWithMessageAsString:(NSString *)message
{
    return [self resultWithStatus:CDVCommandStatus_OK messageAsString:message];
}

+ (instancetype)bcp_error
{
    return [self resultWithStatus:CDVCommandStatus_ERROR];
}


@end
