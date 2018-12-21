//
//  MKMAESKey.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMSymmetricKey.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  AES Key
 *
 *      keyInfo format: {
 *          algorithm: "AES",
 *          keySize  : 32,   // optional
 *          data     : "..." // base64_encode(password)
 *      }
 */
@interface MKMAESKey : MKMSymmetricKey

@end

NS_ASSUME_NONNULL_END
