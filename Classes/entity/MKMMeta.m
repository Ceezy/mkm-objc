//
//  MKMMeta.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "NSObject+JsON.h"
#import "NSString+Crypto.h"
#import "NSData+Crypto.h"

#import "MKMPublicKey.h"
#import "MKMPrivateKey.h"

#import "MKMID.h"

#import "MKMMeta.h"

@interface MKMMeta ()

@property (nonatomic) NSUInteger version;

@property (strong, nonatomic) NSString *seed;
@property (strong, nonatomic) MKMPublicKey *key;
@property (strong, nonatomic) NSData *fingerprint;

@property (nonatomic, getter=isValid) BOOL valid;

@end

@implementation MKMMeta

+ (instancetype)metaWithMeta:(id)meta {
    if ([meta isKindOfClass:[MKMMeta class]]) {
        return meta;
    } else if ([meta isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:meta];
    } else if ([meta isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:meta];
    } else {
        NSAssert(!meta, @"unexpected meta: %@", meta);
        return nil;
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _version = 0;
        _seed = nil;
        _key = nil;
        _fingerprint = nil;
        _valid = NO;
    }
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                   publicKey:(const MKMPublicKey *)PK
                 fingerprint:(const NSData *)CT
                     version:(NSUInteger)ver {
    NSAssert(ver == MKMAddressDefaultVersion, @"unknown version");
    NSDictionary *dict = @{@"version"    :@(ver),
                           @"seed"       :name,
                           @"key"        :PK,
                           @"fingerprint":[CT base64Encode],
                           };
    if (self = [super initWithDictionary:dict]) {
        _version = ver;
        _seed = [_storeDictionary objectForKey:@"seed"];
        _key = [_storeDictionary objectForKey:@"key"];
        _fingerprint = [CT copy];
        _valid = [PK verify:[name data] withSignature:CT];
        NSAssert(_valid, @"meta invalid");
    }
    return self;
}

- (instancetype)initWithSeed:(const NSString *)name
                  privateKey:(const MKMPrivateKey *)SK
                   publicKey:(nullable const MKMPublicKey *)PK {
    if (PK) {
        NSAssert([PK isMatch:SK], @"PK must match SK");
    } else {
        PK = [SK publicKey];
    }
    NSData *CT = [SK sign:[name data]];
    self = [self initWithSeed:name
                    publicKey:PK
                  fingerprint:CT
                      version:MKMAddressDefaultVersion];
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMMeta *meta = [super copyWithZone:zone];
    if (meta) {
        meta.version = _version;
        meta.seed = _seed;
        meta.key = _key;
        meta.fingerprint = _fingerprint;
        meta.valid = _valid;
    }
    return meta;
}

- (NSUInteger)version {
    if (_version == 0) {
        NSNumber *ver = [_storeDictionary objectForKey:@"version"];
        _version = [ver unsignedIntegerValue];
        NSAssert(_version == MKMAddressDefaultVersion, @"error");
    }
    return _version;
}

- (NSString *)seed {
    if (!_seed) {
        _seed = [_storeDictionary objectForKey:@"seed"];
        NSAssert(_seed.length > 0, @"error");
        // check valid
        if (_key && _fingerprint) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _seed;
}

- (MKMPublicKey *)key {
    if (!_key) {
        id key = [_storeDictionary objectForKey:@"key"];
        _key = [MKMPublicKey keyWithKey:key];
        NSAssert([_key isKindOfClass:[MKMPublicKey class]], @"error");
        // check valid
        if (_seed && _fingerprint) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _key;
}

- (NSData *)fingerprint {
    if (!_fingerprint) {
        NSString *CT = [_storeDictionary objectForKey:@"fingerprint"];
        _fingerprint = [CT base64Decode];
        NSAssert(_fingerprint.length > 0, @"error");
        // check valid
        if (_seed && _key) {
            _valid = [_key verify:[_seed data] withSignature:_fingerprint];
        }
    }
    return _fingerprint;
}

- (BOOL)isValid {
    if (!_valid) {
        if (self.version != MKMAddressDefaultVersion) {
            NSAssert(false, @"version error");
            return NO;
        }
        if (!self.seed || !self.key || !self.fingerprint) {
            NSAssert(false, @"meta error");
            return NO;
        }
        //NSAssert(_valid, @"meta invalid");
    }
    return _valid;
}

#pragma mark - ID & address

- (BOOL)matchID:(const MKMID *)ID {
    NSAssert(ID.isValid, @"Invalid ID");
    if (![self matchAddress:ID.address]) {
        return NO;
    }
    return [self.seed isEqualToString:ID.name];
}

// check: address == btc_address(network, CT)
- (BOOL)matchAddress:(const MKMAddress *)address {
    NSAssert(address.isValid, @"Invalid address");
    MKMAddress *addr = [self buildAddressWithNetworkID:address.network];
    return [address isEqualToString:addr];
}

- (MKMID *)buildIDWithNetworkID:(MKMNetworkType)type {
    MKMAddress *addr = [self buildAddressWithNetworkID:type];
    if (!addr) {
        NSAssert(false, @"failed to build ID");
        return nil;
    }
    return [[MKMID alloc] initWithName:self.seed address:addr];
}

- (MKMAddress *)buildAddressWithNetworkID:(MKMNetworkType)type {
    if (!self.isValid) {
        NSAssert(false, @"meta not valid");
        return nil;
    }
    return [[MKMAddress alloc] initWithFingerprint:self.fingerprint
                                           network:type
                                           version:self.version];
}

@end
