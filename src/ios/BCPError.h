// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, BCPErrorCode) {

    BCPBroadcastConfigurationReaderFileNotFoundError = 0x01,
    BCPBroadcastConfigurationReaderNotAPlistFileError = 0x02,
    BCPBroadcastConfigurationReaderNotAFileError = 0x03,
    BCPBroadcastConfigurationReaderAppGroupMissingError = 0x04,
    BCPBroadcastConfigurationReaderExtensionBundleIdMissingError = 0x05,
    BCPGenericError = 0xFF,
};

FOUNDATION_EXPORT NSString *const kBCPErrorDomain;

@interface BCPError : NSError

+ (instancetype)createFileNotFoundError;
+ (instancetype)createNotAFileError;
+ (instancetype)createNotAPlistError;
+ (instancetype)createAppGroupMissingError;
+ (instancetype)createExtensionBundleIdMissingError;

@end

NS_ASSUME_NONNULL_END
