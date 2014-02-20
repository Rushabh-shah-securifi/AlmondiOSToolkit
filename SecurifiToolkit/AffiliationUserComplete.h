//
//  AffiliationResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Nirav Uchat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AffiliationUserComplete : NSObject
@property BOOL isSuccessful;
@property NSString *almondplusName;
//8 bytes
@property NSString *almondplusMAC;
@property NSString *reason;
@property NSString *wifiSSID;
@property NSString *wifiPassword;
@property int reasonCode;
@end
