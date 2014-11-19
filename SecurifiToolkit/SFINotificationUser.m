//
//  SFINotificationUser.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 11/11/14.
//  Copyright (c) 2014 Nirav Uchat. All rights reserved.
//

#import "SFINotificationUser.h"
#import "SFINotificationDevice.h"

@implementation SFINotificationUser

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.userID = [coder decodeObjectForKey:@"self.userID"];
        self.preferenceCount = (unsigned int) [coder decodeIntForKey:@"self.preferenceCount"];
        _notificationDeviceList = [coder decodeObjectForKey:@"self.notificationDeviceList"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userID forKey:@"self.userID"];
    [coder encodeInt:self.preferenceCount forKey:@"self.preferenceCount"];
    [coder encodeObject:self.notificationDeviceList forKey:@"self.notificationDeviceList"];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.userID=%@", self.userID];
    [description appendFormat:@", self.preferenceCount=%u", self.preferenceCount];
    [description appendFormat:@", self.notificationDeviceList=%@", self.notificationDeviceList];
    [description appendString:@">"];
    return description;
}

- (id)copyWithZone:(NSZone *)zone {
    SFINotificationUser *copy = (SFINotificationUser *) [[[self class] allocWithZone:zone] init];
    
    if (copy != nil) {
        copy.userID = self.userID;
        copy.preferenceCount = self.preferenceCount;
        copy.notificationDeviceList =  self.notificationDeviceList;
    }
    
    return copy;
}

- (BOOL)isNotificationEnabled:(NSString*)deviceID{
    //Check if current device ID is in the notification list
    for(SFINotificationDevice *currentDevice in self.notificationDeviceList){
        if(currentDevice.deviceID==[deviceID intValue]){
            return true;
        }
    }
    return false;
}
@end
