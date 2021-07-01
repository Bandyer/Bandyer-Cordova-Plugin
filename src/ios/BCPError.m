// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import "BCPError.h"

NSString *const kBCPErrorDomain = @"com.bandyer.BandyerPlugin";

@implementation BCPError

+ (instancetype)createError:(BCPErrorCode)code
{
    return [self errorWithDomain:kBCPErrorDomain code:code userInfo:nil];
}

+ (instancetype)createFileNotFoundError
{
    return [self createError:BCPBroadcastConfigurationReaderFileNotFoundError];
}

+ (instancetype)createNotAFileError
{
    return [self createError:BCPBroadcastConfigurationReaderNotAFileError];
}

+ (instancetype)createNotAPlistError
{
    return [self createError:BCPBroadcastConfigurationReaderNotAPlistFileError];
}

+ (instancetype)createAppGroupMissingError
{
    return [self createError:BCPBroadcastConfigurationReaderAppGroupMissingError];
}

+ (instancetype)createExtensionBundleIdMissingError
{
    return [self createError:BCPBroadcastConfigurationReaderExtensionBundleIdMissingError];
}

@end
