//
//  SFIWirelessSettings.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 13/11/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIWirelessSetting : NSObject <NSCopying>

//<AlmondWirelessSettings index="1" enabled="true">
//<SSID>AlmondNetwork</SSID>
//<Password>1234567890</Password>
//<Channel>1</Channel>
//<EncryptionType>AES</EncryptionType>
//<Security>WPA2PSK</Security>
//<WirelessMode>802.11bgn</WirelessMode>
//<CountryRegion>0</CountryRegion>
//</AlmondWirelessSettings>
@property(nonatomic) int index;
@property(nonatomic) BOOL enabled;
@property(nonatomic, copy) NSString *ssid;
@property(nonatomic, copy) NSString *password;
@property(nonatomic) int channel;
@property(nonatomic, copy) NSString *encryptionType;
@property(nonatomic, copy) NSString *security;
@property(nonatomic, copy) NSString *wirelessMode;
@property(nonatomic) int wirelessModeCode;
@property(nonatomic, copy) NSString *countryRegion;
@property(nonatomic, copy) NSString *type;

- (NSString *)toXml;

- (id)copyWithZone:(NSZone *)zone;

@end
