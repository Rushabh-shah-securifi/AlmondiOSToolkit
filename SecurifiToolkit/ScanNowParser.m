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
            if([self checkForValidresponse:dict]  && ![self isToAddHealthyDevices:dict]){
                NSDictionary *iotDeviceObj = [self iotDeviceObj:dict isVulnerable:YES];
                [scanNowArr addObject:iotDeviceObj];
            }
            else{
                NSDictionary *iotDeviceObj = [self iotDeviceObj:dict isVulnerable:NO];
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
    NSString *ssh = deviceDict[@"Ssh"]?:@"0";
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    if([Http isEqualToString:@"1"])
        [arr addObject:@"1"];
    
    if([ssh isEqualToString:@"1"])
        [arr addObject:@"8"];

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

-(NSDictionary *)iotDeviceObj:(NSDictionary *)deviceDict isVulnerable:(BOOL)isVulnerable{
    NSLog(@"deviceDict = = %@",deviceDict);
    
    NSString *telnet = deviceDict[@"Telnet"];
    NSString *Http = deviceDict[@"Http"];
    
    NSArray *ForwardRules = deviceDict[@"ForwardRules"];
    NSArray *UpnpRules = deviceDict[@"UpnpRules"];
   
    
    NSArray *ports;
    NSString *portTag;
    if(isVulnerable){
        ports = [self openPort:deviceDict];
        portTag = @"2";
    }
    else{
        ports = [self openPortHealthy:deviceDict];
        portTag = @"6";
    }
    NSArray *upnpPorts1 = [self getPorts1:UpnpRules];
    NSArray *upnpPorts2 = [self getPorts2:UpnpRules];
    NSArray *ForwardRulesPorts = [self getPorts:ForwardRules];
    
    
    NSDictionary *returnDict = @{@"Telnet":@{@"P":[telnet isEqualToString:@"1"]?@"1":@"0",
                                             @"Tag":@"1",
                                             @"Value":@[]},
                                 @"Ports":@{@"P":ports.count>0?@"1":@"0",
                                            @"Tag":portTag,
                                            @"Value":ports},
                                 @"Http":@{@"P":[Http isEqualToString:@"1"]?@"1":@"0",
                                           @"Tag":@"3"
                                           ,
                                           @"Value":@[]},
                                 @"ForwardRules":@{@"P":ForwardRulesPorts.count>0?@"1":@"0",
                                                   @"Tag":@"4",
                                                   @"Value":ForwardRulesPorts},
                                 @"UpnpRules":@{@"P":upnpPorts1.count>0?@"1":@"0",
                                                @"Tag":@"5",
                                                @"Value":upnpPorts1},
                                 @"UpnpRules1":@{@"P":upnpPorts2.count>0?@"1":@"0",
                                                @"Tag":@"7",
                                                @"Value":upnpPorts2},
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
    
    NSArray *isForwareded = iotDict[@"ForwardRules"];
    
    NSLog(@"iotDict ports = %@",iotDict);
    BOOL addToHealthy;
    for (NSString *port in ports) {
        NSLog(@"port isToAddHealthyDevices %@",port);
        if([port intValue] > 1024){// not add vulnerable list
            addToHealthy = YES;
            if(isForwareded.count > 0){
                    addToHealthy = NO;
                break;
            }
        }
        else{
            addToHealthy = NO;
                break;
        }
    }
    
    return  addToHealthy;
}
-(NSArray *)openPort:(NSDictionary *)iotDict{
    NSArray *portArrVal = iotDict[@"Ports"];
    NSMutableArray *portArr = [NSMutableArray new];
    for (NSString *port in portArrVal) {
        if([port intValue] < 1024)// not add vulnerable list
        {
            [portArr addObject:port];
        }
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:portArr];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    return  arrayWithoutDuplicates;
    
}
-(NSArray * )openPortHealthy:(NSDictionary *)iotDict{
    NSArray *portArrVal = iotDict[@"Ports"];
    NSMutableArray *portArr = [NSMutableArray new];
    for (NSString *port in portArrVal) {
        if([port intValue] > 1024)// not add vulnerable list
        {
            [portArr addObject:port];
        }
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:portArr];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    return  arrayWithoutDuplicates;
}
-(NSArray *)getPorts:(NSArray *)ObjArr{
    NSMutableArray *upnpPortsArr = [[NSMutableArray alloc]init];
    NSLog(@"ObjArr == %@",ObjArr);
    
    for (NSDictionary *upnpObj in ObjArr) {
        NSString *upnpPort = upnpObj[@"Ports"];
        
        NSLog(@" upnpPort  === %@",upnpPort);
        NSString *portForwardedStr = [self handlePortForwarding:upnpPort];
         NSLog(@" portForwardedStr  === %@",upnpPort);
        [upnpPortsArr addObject:portForwardedStr];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:upnpPortsArr];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    return  arrayWithoutDuplicates;
}
-(NSString *)handlePortForwarding:(NSString *)portforwarding{
    NSString *returnString ;
    NSArray *portForwArr;
    if([self doesString:portforwarding containCharacter:':'])
    {
        NSArray* arrayOfStrings = [portforwarding componentsSeparatedByString:@":"];
        NSString *port = [NSString stringWithFormat:@"%@ to %@",[arrayOfStrings objectAtIndex:0],[arrayOfStrings objectAtIndex:1]];
        returnString = port;
    }
    else if([self doesString:portforwarding containCharacter:',']){
        returnString = portforwarding;
    }
    else{
        returnString = portforwarding;
    }
return returnString;
}
-(BOOL)doesString:(NSString *)string containCharacter:(char)character
{
    if ([string rangeOfString:[NSString stringWithFormat:@"%c",character]].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}
-(NSArray *)getPorts1:(NSArray *)ObjArr{
    NSMutableArray *upnpPortsArr = [[NSMutableArray alloc]init];
    for (NSDictionary *upnpObj in ObjArr) {
        NSString *upnpPort = upnpObj[@"Ports"];
        if([upnpPort intValue] <= 1024)
        [upnpPortsArr addObject:upnpPort];
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:upnpPortsArr];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    return  arrayWithoutDuplicates;
}
-(NSArray *)getPorts2:(NSArray *)ObjArr{
    NSMutableArray *upnpPortsArr = [[NSMutableArray alloc]init];
    for (NSDictionary *upnpObj in ObjArr) {
        NSString *upnpPort = upnpObj[@"Ports"];
        if([upnpPort intValue] > 1024)
            [upnpPortsArr addObject:upnpPort];
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:upnpPortsArr];
    NSArray *arrayWithoutDuplicates = [orderedSet array];
    return  arrayWithoutDuplicates;
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
