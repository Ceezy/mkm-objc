//
//  MKMEntity.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/9/26.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "MKMAddress.h"

NS_ASSUME_NONNULL_BEGIN

@class MKMID;
@class MKMMeta;

@interface MKMEntity : NSObject <NSCopying> {
    
    // convenience for instance accessing
    MKMID *_ID;
    NSString *_name;
}

@property (readonly, strong, nonatomic) MKMID *ID;   // name@address

@property (readonly, nonatomic) MKMNetworkType type; // Network ID
@property (readonly, nonatomic) UInt32 number;       // search number

@property (strong, nonatomic) NSString *name;        // name or seed

- (instancetype)initWithID:(const MKMID *)ID NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - Entity Delegate

@protocol MKMEntityDataSource <NSObject>

/**
 Get meta to create entity

 @param ID - entity ID
 @return meta data(dictionary)
 */
- (MKMMeta *)metaForEntityID:(const MKMID *)ID;

@end

NS_ASSUME_NONNULL_END
