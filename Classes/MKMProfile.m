//
//  MKMProfile.m
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMID.h"
#import "MKMAddress.h"
#import "MKMMeta.h"

#import "MKMProfile.h"

@interface MKMProfile ()

@property (strong, nonatomic) MKMID *ID;

@end

@implementation MKMProfile

+ (instancetype)profileWithProfile:(id)profile {
    if ([profile isKindOfClass:[MKMProfile class]]) {
        return profile;
    } else if ([profile isKindOfClass:[NSDictionary class]]) {
        return [[self alloc] initWithDictionary:profile];
    } else if ([profile isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithJSONString:profile];
    } else {
        NSAssert(!profile, @"unexpected profile: %@", profile);
        return nil;
    }
}

- (instancetype)initWithID:(const MKMID *)ID {
    NSAssert(MKMNetwork_IsCommunicator(ID.type), @"profile ID error");
    if (self = [self init]) {
        // account ID
        if (ID.isValid) {
            [_storeDictionary setObject:ID forKey:@"ID"];
            _ID = [ID copy];
        }
        
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        dict = _storeDictionary;
        // account ID
        MKMID *ID = [dict objectForKey:@"ID"];
        ID = [MKMID IDWithID:ID];
        if (ID.isValid) {
            _ID = ID;
        }
        
        _publicFields = [[NSMutableArray alloc] init];
        _protectedFields = [[NSMutableArray alloc] init];
        _privateFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setArrayValue:(NSString *)value forKey:(const NSString *)arrName {
    NSMutableArray *mArray = [_storeDictionary objectForKey:arrName];
    if (mArray) {
        NSUInteger index = [mArray indexOfObject:value];
        if (index == 0) {
            // already exists at the first place
            return;
        }
        if (![mArray isKindOfClass:[NSMutableArray class]]) {
            NSAssert([mArray isKindOfClass:[NSArray class]],
                     @"unexpected array: %@", mArray);
            // mutable it
            mArray = [mArray mutableCopy];
            [_storeDictionary setObject:mArray forKey:arrName];
        }
        if (index == NSNotFound) {
            // add to first
            [mArray insertObject:value atIndex:0];
        } else {
            // exists but not the first one
            [mArray removeObjectAtIndex:index];
            [mArray insertObject:value atIndex:0];
        }
    } else {
        // array not exists yet
        mArray = [[NSMutableArray alloc] initWithCapacity:1];
        [mArray addObject:value];
        [_storeDictionary setObject:mArray forKey:arrName];
    }
}

- (NSString *)name {
    NSString *value = [_storeDictionary objectForKey:@"name"];
    if (value) {
        return value;
    }
    NSArray *array = [_storeDictionary objectForKey:@"names"];
    return [array firstObject];
}

- (void)setName:(NSString *)name {
    if (name) {
        [self setArrayValue:name forKey:@"names"];
    }
}

@end

#pragma mark - Account profile

@implementation MKMProfile (Account)

- (MKMGender)gender {
    NSString *sex = [_storeDictionary objectForKey:@"gender"];
    if (!sex) {
        sex = [_storeDictionary objectForKey:@"sex"];
    }
    
    if ([sex isEqualToString:MKMMale]) {
        return MKMGender_Male;
    } else if ([sex isEqualToString:MKMFemale]) {
        return MKMGender_Female;
    } else {
        return MKMGender_Unknown;
    }
}

- (void)setGender:(MKMGender)gender {
    if (gender == MKMGender_Male) {
        [_storeDictionary setObject:MKMMale forKey:@"gender"];
    } else if (gender == MKMGender_Female) {
        [_storeDictionary setObject:MKMFemale forKey:@"gender"];
    } else {
        [_storeDictionary removeObjectForKey:@"gender"];
    }
    
    if ([_storeDictionary objectForKey:@"sex"]) {
        [_storeDictionary removeObjectForKey:@"sex"];
    }
}

- (NSString *)avatar {
    NSString *value = [_storeDictionary objectForKey:@"avatar"];
    if (value) {
        return value;
    }
    NSArray *array = [_storeDictionary objectForKey:@"photos"];
    return array.firstObject;
}

- (void)setAvatar:(NSString *)avatar {
    //[self setArrayValue:avatar forKey:@"photos"];
    if (avatar) {
        [_storeDictionary setObject:avatar forKey:@"avatar"];
    } else {
        [_storeDictionary removeObjectForKey:@"avatar"];
    }
}

- (NSString *)biography {
    NSString *bio = [_storeDictionary objectForKey:@"biography"];
    if (!bio) {
        bio = [_storeDictionary objectForKey:@"bio"];
    }
    
    return bio;
}

- (void)setBiography:(NSString *)biography {
    if (biography) {
        [_storeDictionary setObject:biography forKey:@"biography"];
    } else {
        [_storeDictionary removeObjectForKey:@"biography"];
    }
    
    if ([_storeDictionary objectForKey:@"bio"]) {
        [_storeDictionary removeObjectForKey:@"bio"];
    }
}

@end

#pragma mark - Group profile

@implementation MKMProfile (Group)

- (NSString *)logo {
    NSArray *array = [_storeDictionary objectForKey:@"photos"];
    return array.firstObject;
}

- (void)setLogo:(NSString *)logo {
    [self setArrayValue:logo forKey:@"photos"];
}

@end
