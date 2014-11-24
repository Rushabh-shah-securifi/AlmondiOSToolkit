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
@property(nonatomic, copy) NSString *reason;
@property(nonatomic, copy) NSString *almondMAC;
@property(nonatomic, copy) NSString *applicationID;
@property(nonatomic, copy) NSString *genericData;
@property(nonatomic, copy) NSData *decodedData;
@end
