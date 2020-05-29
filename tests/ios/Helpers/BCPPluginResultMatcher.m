// Copyright © 2020 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPPluginResultMatcher.h"

#import <Foundation/Foundation.h>
#import <OCHamcrest/OCHamcrest.h>
#import <Cordova/CDV.h>

id equalToResult(CDVPluginResult *result)
{
    return HC_allOf(
             HC_hasProperty(@"status", HC_equalTo(result.status)),
             HC_hasProperty(@"message", HC_equalTo(result.message)),
             HC_hasProperty(@"keepCallback", HC_equalTo(result.keepCallback)),
             nil);
}
