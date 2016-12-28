//
//  SFIAlmondPlus.h
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// Indicates whether the Almond can be linked with the cloud or by local connection only.
// The default is "cloud_local" indicating any of those connection methods is possible.
// "local only" is reserved for Almonds that bypass Cloud registration.
// See asAlmondPlus in SFIAlmondLocalNetworkSettings for factory that makes local-only Almonds.
//

typedef NS_ENUM(unsigned int, SFIAlmondPlusLinkType) {
    SFIAlmondPlusLinkType_cloud_local   = 0,
    SFIAlmondPlusLinkType_local_only    = 1,
};


//@interface SecondaryUser : NSObject
//@property NSString* emailID;
//@property int userid;
//@end

@interface SFIAlmondPlus : NSObject <NSCoding, NSCopying>

+(NSString*)convertDecimalToMacHex:(NSString*)macDecimal;
+(NSString*)convertMacHexToDecimal:(NSString*)macHex;

@property(nonatomic, copy) NSString *almondplusMAC;// mac decimal value
@property(nonatomic, copy) NSString *almondplusName;
@property(nonatomic) NSString *firmware;
@property(nonatomic) int index;
@property(nonatomic) int colorCodeIndex;
@property(nonatomic) int isPrimaryAlmond;
@property(nonatomic) NSString* userID;
@property(nonatomic) int userCount;
@property(nonatomic) NSArray *accessEmailIDs;
@property(nonatomic) BOOL isExpanded;
@property(nonatomic, copy) NSString *ownerEmailID;
@property(nonatomic) NSString *routerMode;
@property(nonatomic) enum SFIAlmondPlusLinkType linkType;

- (id)initWithCoder:(NSCoder *)coder;

- (void)encodeWithCoder:(NSCoder *)coder;

- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

// indicates whether the Almond router supports the "send logs to the cloud" functionality.
// the version string is attained dynamically from the almond, and this method tests whether it is a
// current enough version.
- (BOOL)supportsSendLogs:(NSString *)almondVersion;

- (BOOL)supportsGenericIndexes:(NSString *)almondVersion;

- (BOOL)isEqualAlmondPlus:(SFIAlmondPlus *)other;

+ (BOOL)checkIfFirmwareIsCompatible:(SFIAlmondPlus *)almond;

-(BOOL)siteMapSupportFirmware:(NSString *)almondFiemware;

-(BOOL)iotSupportFirmwareVersion:(NSString *)almondFiemware;
@end
