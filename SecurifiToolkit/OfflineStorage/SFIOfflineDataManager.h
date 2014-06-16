//
//  SFIOfflineDataManager.h
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 20/09/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFIOfflineDataManager : NSObject
+(BOOL) writeAlmondList:(NSArray *)arrayAlmondList;
+(NSArray*) readAlmondList;

+(BOOL) writeHashList:(NSString*)strHashValue currentMAC:(NSString*)strCurrentMAC;
+(NSString*) readHashList:(NSString*)strCurrentMAC;

+(BOOL) writeDeviceList:(NSArray *)deviceList currentMAC:(NSString*)strCurrentMAC;
+(NSMutableArray*) readDeviceList:(NSString*)strCurrentMAC;

+(BOOL) writeDeviceValueList:(NSArray *)deviceValueList currentMAC:(NSString*)strCurrentMAC;
+(NSArray*) readDeviceValueList:(NSString*)strCurrentMAC;
+(BOOL)deleteFile:(NSString*)fileName;

+(void) deleteHashForAlmond:(NSString*)strCurrentMAC;
+(void) deleteDeviceDataForAlmond:(NSString*)strCurrentMAC;
+(void) deleteDeviceValueForAlmond:(NSString*)strCurrentMAC;
@end
