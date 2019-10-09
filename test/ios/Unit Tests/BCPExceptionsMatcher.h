//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT id BCP_throwsInvalidArgumentException(void);

#ifndef BCP_DISABLE_SHORT_SYNTAX

static inline id throwsInvalidArgumentException(void)
{
    return BCP_throwsInvalidArgumentException();
}

#endif

FOUNDATION_EXPORT id BCP_throwsInternalInconsistencyException(void);

#ifndef BCP_DISABLE_SHORT_SYNTAX

static inline id throwsInternalInconsistencyException(void)
{
    return BCP_throwsInternalInconsistencyException();
}

#endif


NS_ASSUME_NONNULL_END
