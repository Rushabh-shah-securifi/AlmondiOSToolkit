//
//  AffiliationResponse.h
//  SecurifiToolkit
//
//  Created by Nirav Uchat on 7/13/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, AffiliationUserCompleteFailureCode) {
    AffiliationUserCompleteFailureCode_systemDown = 1,
    AffiliationUserCompleteFailureCode_invalidCode = 2,
    AffiliationUserCompleteFailureCode_invalidCode2 = 3,
    AffiliationUserCompleteFailureCode_alreadyLinked = 4,
    AffiliationUserCompleteFailureCode_loginAgain = 5,
    AffiliationUserCompleteFailureCode_loginAgain2 = 6,
    AffiliationUserCompleteFailureCode_loginAgain3 = 7,
};

@interface AffiliationUserComplete : NSObject
@property(nonatomic) BOOL isSuccessful;
@property(nonatomic, copy) NSString *almondplusName;

//8 bytes; use formattedAlmondPlusMac for human friendly string
@property(nonatomic, copy) NSString *almondplusMAC;

@property(nonatomic, copy) NSString *reason;
@property(nonatomic, copy) NSString *wifiSSID;
@property(nonatomic, copy) NSString *wifiPassword;
@property(nonatomic) enum AffiliationUserCompleteFailureCode reasonCode;

- (NSString *)formattedAlmondPlusMac;

@end
