//
//  MKMProfile.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/30.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMDictionary.h"

NS_ASSUME_NONNULL_BEGIN

#define MKMMale   @"male"
#define MKMFemale @"female"

typedef NS_ENUM(SInt32, MKMGender) {
    MKMGender_Unknown = 0,
    MKMGender_Male = 1,
    MKMGender_Female = 2,
};

@class MKMID;

@interface MKMProfile : MKMDictionary

@property (readonly, strong, nonatomic) const MKMID *ID;

@property (strong, nonatomic) NSString *name;

/**
 Profile fields that anyone can read
 */
@property (strong, nonatomic) NSMutableArray<const NSString *> *publicFields;

/**
 Profile fields only the MKM network can read
 */
@property (strong, nonatomic) NSMutableArray<const NSString *> *protectedFields;

/**
 Extra fields only the user itself can read
 */
@property (strong, nonatomic) NSMutableArray<const NSString *> *privateFields;

+ (instancetype)profileWithProfile:(id)profile;

- (instancetype)initWithID:(const MKMID *)ID;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

#pragma mark Account profile

@interface MKMProfile (Account)

@property (nonatomic) MKMGender gender;
@property (strong, nonatomic) NSString *avatar; // URL

@property (strong, nonatomic) NSString *biography; // 0~280 bytes

// -title
// -birthday
// -resumes
// -phones
// -emails
// -ims

@end

#pragma mark Group Profile

@interface MKMProfile (Group)

@property (strong, nonatomic) NSString *logo; // URL

@end

#pragma mark - Profile Delegate

@protocol MKMProfileDataSource <NSObject>

/**
 Get profile for entity
 */
- (MKMProfile *)profileForID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
