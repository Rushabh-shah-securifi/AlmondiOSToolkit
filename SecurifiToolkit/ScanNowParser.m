//
//  ScanNowParser.m
//  SecurifiToolkit
//
//  Created by Securifi-Mac2 on 22/12/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "ScanNowParser.h"
#import "MDJSON.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "KeyChainWrapper.h"
#import "AlmondManagement.h"
@implementation ScanNowParser
- (instancetype)init {
    self = [super init];
    [self initNotification];
    return self;
}
-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(iotScanresultsCallBack:)
                   name:NOTIFICATION_COMMAND_TYPE_IOT_SCAN_RESULT
                 object:nil];
    
    
}
-(void)iotScanresultsCallBack:(id)sender{
    if(![self validateResponse:sender])
        return;
    SecurifiToolkit *toolkit=[SecurifiToolkit sharedInstance];
    BOOL local = [toolkit useLocalNetwork:[AlmondManagement currentAlmond].almondplusMAC];
    NSDictionary *mainDict=[[(NSNotification *) sender userInfo] valueForKey:@"data"];
    if(!local){
        if(![[[(NSNotification *) sender userInfo] valueForKey:@"data"] isKindOfClass:[NSData class]])
            return;
        
        mainDict = [[[(NSNotification *) sender userInfo] valueForKey:@"data"] objectFromJSONData];
    }
    if([mainDict isKindOfClass:[NSDictionary class]] == NO)
        return;
    
    if(![mainDict[@"CommandType"] isEqualToString:@"IOTScanResponse"])
        return;
     NSMutableArray *scanNowArr = [[NSMutableArray alloc]init];
    if([mainDict[@"Reason"] isEqualToString:@"No Data Found"]){
        toolkit.iotScanResults = nil;
        toolkit.iotScanResults = [[NSMutableDictionary alloc]init];
        NSDictionary *resData = nil;
        if (mainDict) {
            resData = @{
                        @"data" : mainDict
                        };
        }
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER object:nil userInfo:resData];
}
    NSLog(@"[AlmondManagement currentAlmond].almondplusMAC %@",[AlmondManagement currentAlmond].almondplusMAC);
   
    //if(![mainDict[@"AlmondMAC"] isEqualToString:[AlmondManagement currentAlmond].almondplusMAC])
   
    
    if(mainDict == NULL)
        return;
    if(mainDict[@"Devices"] == NULL)
        return;
    
    NSLog(@"maind dict devices %@",mainDict[@"Devices"]);
    NSArray *deviceRespArr = mainDict[@"Devices"];
    for (NSDictionary *dict in deviceRespArr) {
        if([self checkForValidresponse:dict]){
            NSDictionary *iotDeviceObj = [self iotDeviceObj:dict];
            [scanNowArr addObject:iotDeviceObj];
        }
    }
    [toolkit.iotScanResults setObject:scanNowArr forKey:@"scanDevice"];
    [toolkit.iotScanResults setObject:mainDict[@"ScanTime"] forKey:@"scanTime"];
    [toolkit.iotScanResults setObject:mainDict[@"ExcludedMAC"] forKey:@"scanExclude"];
    [toolkit.iotScanResults setObject:mainDict[@"Count"] forKey:@"scanCount"];
    NSLog(@"final toolkit.iotScanResults %@",toolkit.iotScanResults);
    
    
    NSDictionary *resData = nil;
    if (mainDict) {
        resData = @{
                    @"data" : mainDict
                    };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER object:nil userInfo:resData];
    
    
}
//
//
//{
//    "AlmondMAC": 251176220295940,
//    "ScanTime": "1482404209",
//    "Devices": [{
//        "Ports": [80, 443, 554, 5000, 37777, 49152],
//        "MAC": "4c:11:bf:79:f1:27",
//        "Telnet": "0",
//        "Http": "1",
//        "ForwardRules": [],
//        "UpnpRules": [{
//            "IP": "10.5.6.102",
//            "Ports": "80",
//            "Protocol": "tcp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "37777",
//            "Protocol": "tcp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "37778",
//            "Protocol": "udp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "554",
//            "Protocol": "udp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "554",
//            "Protocol": "tcp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "161",
//            "Protocol": "udp",
//            "Target": "DNAT"
//        }, {
//            "IP": "10.5.6.102",
//            "Ports": "443",
//            "Protocol": "tcp",
//            "Target": "DNAT"
//        }]
//    }, {
//        "Ports": [],
//        "MAC": "50:cc:f8:8e:51:74",
//        "Telnet": "0",
//        "Http": "0",
//        "ForwardRules": [],
//        "UpnpRules": []
//    }],
//    "ExcludedMAC": ["10:c3:7b:dd:ad:76"],
//    "CommandType": "IOTScanResponse",
//    "Success": "true"
//

-(BOOL)checkForValidresponse:(NSDictionary *)deviceDict{
    NSArray *ports = deviceDict[@"Ports"];
    NSString *telnet = deviceDict[@"Telnet"];
    NSString *Http = deviceDict[@"Http"];
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if([Http isEqualToString:@"1"])
        [arr addObject:@"1"];
    if([telnet isEqualToString:@"1"])
        [arr addObject:@"3"];
    if(ports.count> 0)
        [arr addObject:@"2"];
    if(ForwardRules.count> 0)
        [arr addObject:@"4"];
    if(UpnpRules > 0)
        [arr addObject:@"5"];
    
    if(arr.count > 0)
        return YES;
    else
        return NO;
        
}

-(NSDictionary *)iotDeviceObj:(NSDictionary *)deviceDict{
    NSArray *ports = deviceDict[@"Ports"];
    NSString *telnet = deviceDict[@"Telnet"];
    NSString *Http = deviceDict[@"Http"];
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
    NSDictionary *returnDict = @{@"Telnet":@{@"P":[telnet isEqualToString:@"0"]?@"0":@"1",
                                             @"Tag":@"1"},
                                 @"Ports":@{@"P":ports.count?@"0":@"1",
                                            @"Tag":@"2"},
                                 @"Http":@{@"P":[Http isEqualToString:@"0"]?@"0":@"1",
                                           @"Tag":@"3"},
                                 @"ForwardRules":@{@"P":ForwardRules.count?@"0":@"1",
                                                   @"Tag":@"4"},
                                 @"UpnpRules":@{@"P":UpnpRules.count?@"0":@"1",
                                                @"Tag":@"5"},
                                 @"MAC":deviceDict[@"MAC"]
                                 };
    
    NSLog(@"return dict %@",returnDict);
    
    return  returnDict;
}
-(BOOL)validateResponse:(id)sender{
    if(sender==nil)
        return NO;
    NSDictionary *data = [(NSNotification *) sender userInfo];
    if (data == nil)
        return NO;
    NSDictionary *mainDict = data[@"data"];
    if(mainDict==nil)
        return NO;
    return YES;
}
@end
