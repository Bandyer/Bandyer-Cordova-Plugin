// Copyright © 2021 Bandyer S.r.l. All rights reserved.
// See LICENSE.txt for licensing information

#import <Foundation/Foundation.h>

#if !defined(BCP_INLINE)
# if defined(__cplusplus)
#  define BCP_INLINE static inline
# elif defined(__GNUC__)
#  define BCP_INLINE static __inline__
# else
#  define BCP_INLINE static
# endif
#endif /* !defined(BCP_INLINE) */

BCP_INLINE void BCPSetObjectPointer(__autoreleasing _Nullable id * _Nullable objPtr, id _Nullable value){
    if (objPtr) {
        *objPtr = value;
    }
}
