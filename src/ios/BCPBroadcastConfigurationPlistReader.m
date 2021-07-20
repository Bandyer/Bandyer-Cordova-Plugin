// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPBroadcastConfigurationPlistReader.h"
#import "BCPFunctions.h"
#import "BCPError.h"

#import <Bandyer/BDKBroadcastScreensharingToolConfiguration.h>

@implementation BCPBroadcastConfigurationPlistReader

- (nullable BDKBroadcastScreensharingToolConfiguration *)read:(NSURL *)fileURL error:(NSError * __autoreleasing _Nullable *)error
{
    if (!fileURL)
    {
        BCPSetObjectPointer(error, [BCPError createFileNotFoundError]);
        return nil;
    }

    if (!fileURL.isFileURL)
    {
        BCPSetObjectPointer(error, [BCPError createNotAFileError]);
        return nil;
    }

    if (![[fileURL pathExtension] isEqualToString:@"plist"])
    {
        BCPSetObjectPointer(error, [BCPError createNotAPlistError]);
        return nil;
    }

    NSDictionary *values = [NSDictionary dictionaryWithContentsOfURL:fileURL error:error];
    NSString *appGroupIdentifier = [values valueForKeyPath:@"broadcast.appGroupIdentifier"];
    NSString *extensionBundleIdentifier = [values valueForKeyPath:@"broadcast.extensionBundleIdentifier"];

    if (appGroupIdentifier == nil || ![appGroupIdentifier isKindOfClass:NSString.class] || [appGroupIdentifier isEqualToString:[NSString string]] || [appGroupIdentifier isEqualToString:@"NOT_AVAILABLE"])
    {
        BCPSetObjectPointer(error, [BCPError createAppGroupMissingError]);
        return nil;
    }

    if (extensionBundleIdentifier == nil || ![extensionBundleIdentifier isKindOfClass:NSString.class] || [extensionBundleIdentifier isEqualToString:[NSString string]] || [extensionBundleIdentifier isEqualToString:@"NOT_AVAILABLE"])
    {
        BCPSetObjectPointer(error, [BCPError createExtensionBundleIdMissingError]);
        return nil;
    }

    return [BDKBroadcastScreensharingToolConfiguration enabledWithAppGroupIdentifier:appGroupIdentifier broadcastExtensionBundleIdentifier:extensionBundleIdentifier];
}

@end
