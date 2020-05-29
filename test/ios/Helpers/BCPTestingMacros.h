//
// Copyright © 2019 Bandyer. All rights reserved.
// See LICENSE.txt for licensing information
//

#ifndef __SUPPRESS_WARNINGS_FOR_TEST_BEGIN
 #define __SUPPRESS_WARNINGS_FOR_TEST_BEGIN \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wimplicit-retain-self\"") \
    _Pragma("clang diagnostic ignored \"-Wunused-value\"") \
    _Pragma("clang diagnostic ignored \"-Wnonnull\"")
#endif

#ifndef __SUPPRESS_WARNINGS_FOR_TEST_END
 #define __SUPPRESS_WARNINGS_FOR_TEST_END \
    _Pragma("clang diagnostic pop")
#endif
