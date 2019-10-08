//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

/**
 * Raises an NSInvalidArgumentException if the condition provided as first argument is not met.
 */
#if !defined(BCPAssertOrThrowInvalidArgument)
#define BCPAssertOrThrowInvalidArgument(condition, exception_reason, ...) \
    do {                \
        if (__builtin_expect(!(condition), 0)) {        \
                _Pragma("clang diagnostic push") \
                _Pragma("clang diagnostic ignored \"-Wformat-nonliteral\"") \
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:([NSString stringWithFormat:exception_reason, ##__VA_ARGS__]) userInfo:nil]; \
                _Pragma("clang diagnostic pop") \
        }                \
    } while(0)
#endif
