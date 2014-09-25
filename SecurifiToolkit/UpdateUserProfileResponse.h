//
//  UpdateUserProfileResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 18/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateUserProfileResponse : NSObject
@property BOOL isSuccessful;
@property int reasonCode;
@property NSString *reason;
@property(nonatomic) NSString *internalIndex;
@end
