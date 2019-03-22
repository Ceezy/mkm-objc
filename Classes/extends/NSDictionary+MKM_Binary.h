//
//  NSDictionary+MKM_Binary.h
//  MingKeMing
//
//  Created by Albert Moky on 2018/11/8.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MKM_Binary)

- (BOOL)mkm_writeToBinaryFile:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
