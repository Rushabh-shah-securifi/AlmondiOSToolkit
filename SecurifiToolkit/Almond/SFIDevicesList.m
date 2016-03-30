//
//  SFIConnectedDevices.m
//  Securifi Cloud
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi. All rights reserved.
//

#import "SFIDevicesList.h"
#import "ClientDevice.h"

@implementation SFIDevicesList

/*
{
  "MobileInternalIndex":"<random key>",
  "CommandType":"ClientsList",
  "Clients":[
    {
      "ID":"1",
      "Name":"iphone_4s",
      "Connection":"wireless",
      "MAC":"other",
      "Type":"other",
      "LastKnownIP":"10.2.2.11",
      "Active":"false",
      "UseAsPresence":"true",
      "LastActiveEpoch":"1433920922"
    },

 */
+ (instancetype)parseJson:(NSDictionary *)payload {
    NSArray *clients_payloads = payload[@"Clients"];

    NSMutableArray *clients = [NSMutableArray new];
    for (NSDictionary *client_payload in clients_payloads) {
        ClientDevice *device = [self parseClientJson:client_payload];
        [clients addObject:device];
    }

    SFIDevicesList *ls = [SFIDevicesList new];
    ls.deviceList = clients;

    return ls;
}

+ (ClientDevice *)parseClientJson:(NSDictionary *)payload {
    ClientDevice *cd = [ClientDevice new];

    cd.name = payload[@"Name"];
    cd.deviceIP = payload[@"LastKnownIP"];
    cd.deviceMAC = payload[@"MAC"];

    return cd;
}


@end
