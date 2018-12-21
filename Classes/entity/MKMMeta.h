//
//  MKMMeta.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

#import "MKMAddress.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMPublicKey;
@class MKMPrivateKey;

@class MKMID;

/**
 *  Account/Group Meta data
 *
 *      data format: {
 *          version: 1,          // algorithm version
 *          seed: "moKy",        // user/group name
 *          key: "{public key}", // PK = secp256k1(SK);
 *          fingerprint: "..."   // CT = sign(seed, SK);
 *      }
 *
 *      algorithm:
 *          CT      = sign(seed, SK);
 *          hash    = ripemd160(sha256(CT));
 *          code    = sha256(sha256(network + hash)).prefix(4);
 *          address = base58_encode(network + hash + code);
 *          number  = uint(code);
 */
@interface MKMMeta : MKMDictionary

/**
 *  Algorithm version
 *
 *      0x01 - address algorithm like BitCoin
 */
@property (readonly, nonatomic) NSUInteger version;

/**
 *  Seed to generate fingerprint
 *
 *      Username / Group-X
 */
@property (readonly, strong, nonatomic) NSString *seed;

/**
 *  Public key
 *
 *      RSA / ECC
 */
@property (readonly, strong, nonatomic) MKMPublicKey *key;

/**
 *  Fingerprint to verify ID and public key
 *
 *      Build: fingerprint = sign(seed, privateKey)
 *      Check: verify(seed, fingerprint, publicKey)
 */
@property (readonly, strong, nonatomic) NSData *fingerprint;

@property (readonly, nonatomic, getter=isValid) BOOL valid;

+ (instancetype)metaWithMeta:(id)meta;

/**
 *  Copy meta data
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(const NSData *)CT
                     version:(NSUInteger)version;

/**
 Generate fingerprint, initialize meta data
 
 @param name - seed for fingerprint
 @param PK - public key, which must match the private key
 @param SK - private key
 @return Meta object
 */
- (instancetype)initWithSeed:(const NSString *)name
                  privateKey:(const MKMPrivateKey *)SK
                   publicKey:(nullable const MKMPublicKey *)PK;

#pragma mark - ID & address

- (BOOL)matchID:(const MKMID *)ID;
- (BOOL)matchAddress:(const MKMAddress *)address;

- (MKMID *)buildIDWithNetworkID:(MKMNetworkType)type;
- (MKMAddress *)buildAddressWithNetworkID:(MKMNetworkType)type;

@end

NS_ASSUME_NONNULL_END
