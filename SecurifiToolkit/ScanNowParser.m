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
    toolkit.iotScanResults = nil;
    toolkit.iotScanResults = [[NSMutableDictionary alloc]init];
     NSMutableArray *scanNowArr = [[NSMutableArray alloc]init];
    NSMutableArray *helthyDeviceArr = [[NSMutableArray alloc]init];
    if([mainDict[@"Reason"] isEqualToString:@"No Data Found"]){
       
        NSDictionary *resData = nil;
        if (mainDict) {
            resData = @{
                        @"data" : mainDict
               };
        }
        [toolkit.iotScanResults setObject:@"NoDataFound" forKey:@"NoDataFound"];
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER object:nil userInfo:resData];
        return;
}
    NSLog(@"[AlmondManagement currentAlmond].almondplusMAC %@",[AlmondManagement currentAlmond].almondplusMAC);
   
    //if(![mainDict[@"AlmondMAC"] isEqualToString:[AlmondManagement currentAlmond].almondplusMAC])
   
    NSLog(@"iot device response %@",mainDict);
    if(mainDict == NULL)
        return;
    if(mainDict[@"Devices"] == NULL)
        return;
    
    NSArray *deviceRespArr = mainDict[@"Devices"];
    for (NSDictionary *dict in deviceRespArr) {
        if([self checkForClientPresent:toolkit.clients mac:dict[@"MAC"]]){
            if([self checkForValidresponse:dict] && ![self isToAddHealthyDevices:dict]){
                NSDictionary *iotDeviceObj = [self iotDeviceObj:dict];
                [scanNowArr addObject:iotDeviceObj];
            }
            else{
                NSDictionary *iotDeviceObj = [self iotDeviceObj:dict];
                [helthyDeviceArr addObject:iotDeviceObj];
                
            }
        }
    }
    NSLog(@"scanNowArr  == %@",scanNowArr);
    NSLog(@"helthyDeviceArr  == %@",helthyDeviceArr);
    
    NSMutableArray *excludedArr = [[NSMutableArray alloc]init];
    for(NSString *mac in mainDict[@"ExcludedMAC"]){
        if([self checkForClientPresent:toolkit.clients mac:mac])
            [excludedArr addObject:mac];
    }
    [toolkit.iotScanResults setObject:scanNowArr forKey:@"scanDevice"];
   
    [toolkit.iotScanResults setObject:helthyDeviceArr forKey:@"HealthyDevice"];
    [toolkit.iotScanResults setObject:mainDict[@"ScanTime"] forKey:@"scanTime"];
    
    [toolkit.iotScanResults setObject:excludedArr forKey:@"scanExclude"];
    [toolkit.iotScanResults setObject:mainDict[@"Count"]?mainDict[@"Count"]:@"0" forKey:@"scanCount"];
    
    NSDictionary *resData = nil;
    if (mainDict) {
        resData = @{
                    @"data" : mainDict
                    };
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IOT_SCAN_RESULT_CONTROLLER_NOTIFIER object:nil userInfo:resData];
    
    
}
-(BOOL)checkForClientPresent:(NSArray *)clientList mac:(NSString *)mac{
    for(Client *client in clientList){
        if([client.deviceMAC isEqualToString:mac]){
            NSLog(@"client.name in excluded %@",client.name);
            return YES;
        }
    }
    return NO;
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
    if(UpnpRules.count > 0)
        [arr addObject:@"5"];
    NSLog(@"deviceDict = %@",deviceDict);
    NSLog(@"arr count %ld",arr.count);
    
    if(arr.count > 0)
        return YES;
    else
        return NO;
        
}

-(NSDictionary *)iotDeviceObj:(NSDictionary *)deviceDict{
    NSLog(@"deviceDict = = %@",deviceDict);
    
    NSString *telnet = deviceDict[@"Telnet"];
    NSString *Http = deviceDict[@"Http"];
    
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
    NSArray *ports =deviceDict[@"Ports"];
    NSArray *upnpPorts = [self getPorts:UpnpRules];
    NSArray *ForwardRulesPorts = [self getPorts:ForwardRules];
    
    NSString *opnPorttag = [self getPortTag:ports];
    NSString *upnptag = [self getUpnpTag:upnpPorts];
    
    NSDictionary *returnDict = @{@"Telnet":@{@"P":[telnet isEqualToString:@"1"]?@"1":@"0",
                                             @"Tag":@"1",
                                             @"Value":@[]},
                                 @"Ports":@{@"P":ports.count>0?@"1":@"0",
                                            @"Tag":opnPorttag,
                                            @"Value":ports},
                                 @"Http":@{@"P":[Http isEqualToString:@"1"]?@"1":@"0",
                                           @"Tag":@"3"
                                           ,
                                           @"Value":@[]},
                                 @"ForwardRules":@{@"P":ForwardRules.count>0?@"1":@"0",
                                                   @"Tag":@"4",
                                                   @"Value":ForwardRules},
                                 @"UpnpRules":@{@"P":UpnpRules.count>0?@"1":@"0",
                                                @"Tag":upnptag,
                                                @"Value":upnpPorts},
                                 @"MAC":deviceDict[@"MAC"]
                                 };
    
    NSLog(@"return dict %@",returnDict);
    
    return  returnDict;
}
-(NSString *)getPortTag:(NSArray *)ports{
    for (NSString *port in ports) {
        if([port intValue] > 1024)// not add vulnerable list
            return @"6";
    }
    return  @"2";
}
-(NSString *)getUpnpTag:(NSArray *)ports{
    for (NSString *port in ports) {
        if([port intValue] > 1024)// not add vulnerable list
            return @"7";
    }
    return  @"5";
}

-(BOOL)isToAddHealthyDevices:(NSDictionary *)iotDict{
    NSArray *ports = iotDict[@"Ports"];
    BOOL addToHealthy;
    for (NSString *port in ports) {
        if([port intValue] > 1024)// not add vulnerable list
            addToHealthy = YES;
        else{
            addToHealthy = NO;
            break;
        }
    }
    return  addToHealthy;
}
-(BOOL )openPort:(NSDictionary *)iotDict{
    NSDictionary *portDict = iotDict[@"Ports"];
    NSArray *values = portDict[@"Value"];
    BOOL allPortOn;
    for (NSString *port in values) {
        if([port intValue] > 1024)// not add vulnerable list
            allPortOn = NO;
        else{
            allPortOn = YES;
            break;
        }
    }
    return  allPortOn;
}
-(BOOL )openPortHealthy:(NSDictionary *)iotDict{
    NSDictionary *portDict = iotDict[@"Ports"];
    NSArray *values = portDict[@"Value"];
    BOOL allPortOn;
    for (NSString *port in values) {
        if([port intValue] < 1024)
            allPortOn = NO;
        else{
            allPortOn = YES;
            break;
        }
    }
    
    return allPortOn;
}
-(NSArray *)getPorts:(NSArray *)ObjArr{
    NSMutableArray *upnpPortsArr = [[NSMutableArray alloc]init];
    for (NSDictionary *upnpObj in ObjArr) {
        NSString *upnpPort = upnpObj[@"Ports"];
        [upnpPortsArr addObject:upnpPort];
    }
    return  upnpPortsArr;
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
