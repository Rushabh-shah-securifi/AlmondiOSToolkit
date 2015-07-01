//
//  AffiliationResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AffiliationUserComplete : NSObject
@property (nonatomic) BOOL isSuccessful;
@property (nonatomic, copy) NSString *almondplusName;
//8 bytes
@property (nonatomic, copy)NSString *almondplusMAC;
@property (nonatomic, copy)NSString *reason;
@property (nonatomic, copy)NSString *wifiSSID;
@property (nonatomic, copy)NSString *wifiPassword;
@property int reasonCode;
@end
