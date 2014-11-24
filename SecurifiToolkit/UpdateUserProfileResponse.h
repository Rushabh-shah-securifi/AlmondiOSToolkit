//
//  UpdateUserProfileResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateUserProfileResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) int reasonCode;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic, copy) NSString *internalIndex;
@end
