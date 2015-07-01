//
//  DeleteMeAsSecondaryUserResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 24/09/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteMeAsSecondaryUserResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *internalIndex;
@property(nonatomic, copy) NSString *reason;
@property(nonatomic) int reasonCode;
@end
