//
//  NotificationPreferences.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 27/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "NotificationPreferences.h"
#import "SFIXmlWriter.h"
#import "SFINotificationDevice.h"

@implementation NotificationPreferences

- (NSString *)toXml{
    SFIXmlWriter *writer = [SFIXmlWriter new];
    
    [writer startElement:@"root"];
    [writer startElement:@"NotificationPreferences"];
    [writer addAttribute:@"action" value:self.action];
    
    [writer addElement:@"AlmondplusMAC" text:self.almondMAC];
    [writer addElement:@"UserID" text:self.userID];
    [writer startElement:@"Preference"];
    [writer addAttribute:@"count" intValue:self.preferenceCount];
    

    //Iterate Array
    for(SFINotificationDevice *currentDevice in self.notificationDeviceList){
        [writer startElement:@"Device"];
        [writer addAttribute:@"ID" intValue:currentDevice.deviceID];
        [writer addAttribute:@"Index" intValue:currentDevice.valueIndex];
        // close Device
        [writer addText:@""];
        [writer endElement];
    }
    
    // close Preference
    [writer endElement];
    [self addMobileInternalIndexElement:writer];
    
    // close NotificationPreferences
    [writer endElement];
    // close root
    [writer endElement];
    
    return writer.toString;
}
@end
