//
//  GenericCommandResponse.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GenericCommandResponse : NSObject
@property BOOL isSuccessful;
@property unsigned int mobileInternalIndex;
@property NSString *reason;
@property NSString *almondMAC;
@property NSString *applicationID;
@property NSString *genericData;
@property NSData *decodedData;
@end
