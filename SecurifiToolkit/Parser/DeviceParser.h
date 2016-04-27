//
//  DeviceParser.h
//  SecurifiToolkit
//
//  Created by Masood on 23/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceParser : NSObject
-(void)parseDeviceListAndDynamicDeviceResponse:(id)sender;

+ (NSDictionary*)parseGenericDevicesDict:(NSDictionary*)genericDevicesDict;

+ (NSDictionary*)parseGenericIndexesDict:(NSDictionary*)genericIndexesDict;

+ (NSDictionary*)parseJson:(NSString*)fileName;
@end
