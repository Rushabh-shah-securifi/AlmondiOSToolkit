//
//  UserInviteResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 22/09/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInviteResponse : NSObject
@property BOOL isSuccessful;
@property NSString *reason;
@property int reasonCode;
@property(nonatomic) NSString *internalIndex;
@end
