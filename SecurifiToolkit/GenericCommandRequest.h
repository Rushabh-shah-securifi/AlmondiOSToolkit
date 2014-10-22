//
//  GenericCommandRequest.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//


//<AlmondplusMAC>251176214925585</AlmondplusMAC>
//<ApplicationID></ApplicationID>
//<MobileInternalIndex>1</MobileInternalIndex>
//<Data>
//[Base64Encoded]
//<root><Reboot>1</Reboot></root>[Base64Encoded]
//</Data>

#import <Foundation/Foundation.h>
#import "SecurifiCommand.h"
#import "BaseCommandRequest.h"

@interface GenericCommandRequest : BaseCommandRequest <SecurifiCommand>

@property NSString *almondMAC;
@property NSString *applicationID;
@property NSString *data;

@end
