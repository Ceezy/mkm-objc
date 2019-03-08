//
//  MKMID.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/24.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"

@interface MKMID ()

@property (strong, nonatomic, nonnull) NSString *name;
@property (strong, nonatomic, nonnull) const MKMAddress *address;

@property (strong, nonatomic, nullable) NSString *terminal;

@property (nonatomic, getter=isValid) BOOL valid;

@end

static inline void parse_id_string(const NSString *string, MKMID *ID) {
    // get terminal
    NSArray *pair = [string componentsSeparatedByString:@"/"];
    if (pair.count > 1) {
        assert(pair.count == 2);
        string = pair.firstObject; // drop the tail
        ID.terminal = pair.lastObject;
    }
    
    pair = [string componentsSeparatedByString:@"@"];
    if (pair.count > 1) {
        assert(pair.count == 2);
        // get name
        ID.name = [pair firstObject];
        assert(ID.name.length > 0);
    }
    
    // get address
    NSString *addr = [pair lastObject];
    assert(addr.length >= 15);
    ID.address = [[MKMAddress alloc] initWithString:addr];
    assert(ID.address.isValid);
    
    // isValid
    ID.valid = ID.address.isValid;
}

@implementation MKMID

+ (instancetype)IDWithID:(id)ID {
    if ([ID isKindOfClass:[MKMID class]]) {
        return ID;
    } else if ([ID isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithString:ID];
    } else {
        NSAssert(!ID, @"unexpected ID: %@", ID);
        return nil;
    }
}

- (instancetype)initWithString:(NSString *)aString {
    if (self = [super initWithString:aString]) {
        // lazy
        _name = nil;
        _address = nil;
        _terminal = nil;
        _valid = NO;
    }
    return self;
}

- (instancetype)initWithName:(const NSString *)seed
                     address:(const MKMAddress *)addr {
    return [self initWithName:seed address:addr terminal:nil];
}

- (instancetype)initWithAddress:(const MKMAddress *)addr {
    return [self initWithName:nil address:addr terminal:nil];
}

- (instancetype)initWithName:(nullable const NSString *)seed
                     address:(const MKMAddress *)addr
                    terminal:(nullable const NSString *)res {
    NSString *string;
    if (seed) {
        string = [NSString stringWithFormat:@"%@@%@", seed, addr];
    } else {
        string = [NSString stringWithFormat:@"%@", addr];
    }
    if (res) {
        string = [string stringByAppendingFormat:@"/%@", res];
    }
    
    if (self = [super initWithString:string]) {
        _name = [seed copy];
        _address = [addr copy];
        _terminal = [res copy];
        _valid = addr.isValid;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MKMID *ID = [super copyWithZone:zone];
    if (ID) {
        ID.name = _name;
        ID.address = _address;
        ID.terminal = _terminal;
        ID.valid = _valid;
    }
    return ID;
}

- (BOOL)isEqual:(id)object {
    MKMID *ID = [MKMID IDWithID:object];
    if (!self.isValid || !ID.isValid) {
        return NO;
    }
    // check name
    if (self.name.length > 0) {
        if (![_name isEqualToString:ID.name]) {
            return NO;
        }
    } else if (ID.name.length > 0) {
        return NO;
    }
    // compare address
    return [self.address isEqual:ID.address];
}

- (NSString *)description {
    return _storeString;
}

- (NSString *)name {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _name;
}

- (const MKMAddress *)address {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _address;
}

- (NSString *)terminal {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _terminal;
}

- (BOOL)isValid {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _valid;
}

- (MKMNetworkType)type {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _address.network;
}

- (UInt32)number {
    if (!_name && !_address && !_terminal && _valid == NO) {
        parse_id_string(_storeString, self);
    }
    return _address.code;
}

- (instancetype)naked {
    if (self.terminal) {
        return [[[self class] alloc] initWithName:self.name
                                          address:self.address];
    } else {
        return self;
    }
}

@end
