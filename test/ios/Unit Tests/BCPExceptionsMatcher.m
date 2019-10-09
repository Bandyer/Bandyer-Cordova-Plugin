//
// Copyright © 2019 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information
//

#import <Foundation/Foundation.h>

#import <OCHamcrest/OCHamcrest.h>

#import "BCPExceptionsMatcher.h"


FOUNDATION_EXPORT id BCP_throwsInvalidArgumentException(void)
{
    return HC_throwsException(HC_hasProperty(@"name", HC_equalTo(NSInvalidArgumentException)));
}

FOUNDATION_EXPORT id BCP_throwsInternalInconsistencyException(void)
{
    return HC_throwsException(HC_hasProperty(@"name", HC_equalTo(NSInternalInconsistencyException)));
}
