//
//  GenericCommandResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GenericCommandResponse : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic) unsigned int mobileInternalIndex;
@property(nonatomic) NSString *reason;
@property(nonatomic) NSString *almondMAC;
@property(nonatomic) NSString *applicationID;
@property(nonatomic) NSString *genericData;
@property(nonatomic) NSData *decodedData;
@end
