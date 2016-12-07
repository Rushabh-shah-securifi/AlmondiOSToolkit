//
//  SceneParser.m
//  SecurifiToolkit
//
//  Created by Masood on 30/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "SceneParser.h"
#import "SecurifiToolkit.h"
#import "AlmondJsonCommandKeyConstants.h"
#import "AlmondPlusSDKConstants.h"
#import "AlmondManagement.h"

@implementation SceneParser

- (instancetype)init {
    self = [super init];
    [self initializeNotifications];
    return self;
}

- (void)initializeNotifications{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(getAllScenesCallback:)
                   name:NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER
                 object:nil];
}


- (void)getAllScenesCallback:(id)sender{
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL local = [self isLocal];
    NSDictionary *mainDict;
    if(local){
        mainDict = data[@"data"];
    }else{
        //till cloud changes are integrated
        if(![data[@"data"] isKindOfClass:[NSData class]])
            return;
        mainDict = [data[@"data"] objectFromJSONData];
    }
    
    if([mainDict isKindOfClass:[NSDictionary class]] == NO)
        return;
    
    BOOL isMatchingAlmondOrLocal = ([mainDict[ALMONDMAC] isEqualToString:[AlmondManagement currentAlmond].almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;

    //NSLog(@"main scene dict %@",mainDict);
    NSDictionary *dict;
    NSString * commandType = mainDict[COMMAND_TYPE];
    
    if([commandType isEqualToString:@"DynamicSceneList"] || [commandType isEqualToString:@"SceneList"]){
        if([mainDict[@"Scenes"] isKindOfClass:[NSArray class]])
            return;
        NSDictionary *scenesPayload = mainDict[@"Scenes"];
//        NSLog(@"scenesPayload sceneList %@",scenesPayload);
        NSArray *scenePosKeys = scenesPayload.allKeys;
        NSArray *sortedPostKeys = [scenePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        
        NSMutableArray *scenesList = [NSMutableArray new];
        for (NSString *key in sortedPostKeys) {
            if([self isValidScene:scenesPayload updatedID:key] == NO)
                continue;
            NSMutableArray *mutableEntryList = [self getMutableSceneEntryList:scenesPayload[key]];
            NSMutableDictionary *mutableScene = [scenesPayload[key] mutableCopy];
            [mutableScene setValue:mutableEntryList forKey:@"SceneEntryList"];
            [mutableScene setValue:key forKey:@"ID"];
            [scenesList addObject:mutableScene];
            NSLog(@"scene list");
        }
        toolkit.scenesArray = scenesList;
    }
    
    else if ([commandType isEqualToString:@"DynamicSceneAdded"]){
        NSString *updatedID = [[mainDict[@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"] objectForKey:updatedID];
        
        if([self isValidScene:mainDict[@"Scenes"] updatedID:updatedID] == NO)
            return;
            
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([sceneDict[@"ID"] intValue] == [updatedID intValue]) {
                dict = sceneDict;
                break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
        
        NSMutableDictionary *mutableScene = [newScene mutableCopy];
        [mutableScene setValue:[self getMutableSceneEntryList:newScene] forKey:@"SceneEntryList"];
        [mutableScene setValue:updatedID forKey:@"ID"];

        [toolkit.scenesArray addObject:mutableScene];
    }
    
    
    else if ([commandType isEqualToString:@"DynamicSceneUpdated"]) {
        //scenes has been activated
        NSString *updatedID = [[mainDict[@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"] objectForKey:updatedID];
        
        if([self isValidScene:mainDict[@"Scenes"] updatedID:updatedID] == NO)
            return;
        
        NSInteger index = -1;
        for (NSDictionary *sceneDict in toolkit.scenesArray) {
            NSLog(@"sceneDict active:: %@",sceneDict);
            if ([sceneDict[@"ID"] intValue] == [updatedID intValue]) {
                index = [toolkit.scenesArray indexOfObject:sceneDict];
                break;
            }
        }
        
        NSMutableDictionary *mutableScene = [newScene mutableCopy];
        [mutableScene setValue:[self getMutableSceneEntryList:newScene] forKey:@"SceneEntryList"];
        [mutableScene setValue:updatedID forKey:@"ID"];
        
        if(index == -1){//if the id is not found, the new scene is just added
            [toolkit.scenesArray addObject:mutableScene];
        }else{
            NSLog(@"index replace %d",index);
            [toolkit.scenesArray replaceObjectAtIndex:index withObject:mutableScene];
        }
    }
    else if ([commandType isEqualToString:@"DynamicSceneActivated"]){
        NSString *updatedID = [[mainDict[@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"] objectForKey:updatedID];
        NSInteger index = 0;
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray){
            if ([sceneDict[@"ID"] intValue] == [updatedID intValue]){
                sceneDict[@"Active"] = newScene[@"Active"];
            }
        }

    }

    else if ([commandType isEqualToString:@"DynamicSceneRemoved"]) {
        NSString *updatedID = [[mainDict[@"Scenes"] allKeys] objectAtIndex:0];
        for (NSDictionary * sceneDict in toolkit.scenesArray) {
            if ([sceneDict[@"ID"] intValue] == updatedID.intValue)
            {
                dict = sceneDict;
                    break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
    }
    
    else if ([commandType isEqualToString:@"DynamicAllScenesRemoved"]) {
        [toolkit.scenesArray removeAllObjects];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SCENE_TABLEVIEW object:nil userInfo:data];
}

-(BOOL)isValidScene:(NSDictionary *)scenesDict updatedID:(NSString *)ID{
    //there were some exceptions that were causing crash
    if([scenesDict[ID] isKindOfClass:[NSDictionary class]] == NO)
        return NO;
    else if([[NSString stringWithFormat:@"%@", [scenesDict[ID] objectForKey:@"SceneEntryList"]] isEqualToString:@""])
        return NO;
    return YES;
}

-(BOOL)isLocal{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [AlmondManagement currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    return local;
}

-(NSMutableArray*)getMutableSceneEntryList:(NSDictionary*)sceneDict{
    NSLog(@"getMutableSceneEntryList sceneDict %@",sceneDict);
    NSMutableArray *mutableEntryList = [[NSMutableArray alloc]init];
    NSString *updatedID = [[sceneDict  allKeys] objectAtIndex:0];
    NSArray *sceneEntryListPayload = sceneDict[@"SceneEntryList"];
    // need to handle empty SceneEntryList
    for(NSDictionary *entryList in sceneEntryListPayload){
        NSMutableDictionary *mutableEntry = [entryList mutableCopy];
        NSInteger deviceID = [mutableEntry[@"ID"] integerValue];
        NSInteger index = [mutableEntry[@"Index"] integerValue];
        NSString *value = mutableEntry[@"Value"];
        if(deviceID == 0 &&  index == 1 && ([value isEqualToString:@"home"] ||[value isEqualToString:@"away"])){
            [self changeModeProperties:mutableEntry];
            NSLog(@"mutableEntry %@",mutableEntry);
        }
       
        [mutableEntryList addObject:mutableEntry];
    }
    return mutableEntryList;
}

-(void)changeModeProperties:(NSMutableDictionary*)modeEntry{
    modeEntry[@"ID"] = @"1";
    modeEntry[@"Index"] = @"1";
    modeEntry[@"EventType"] = @"AlmondModeUpdated";
}


//- (void)getAllScenesCallback:(id)sender {
//    NSNotification *notifier = (NSNotification *) sender;
//    NSDictionary *data = [notifier userInfo];
//    
//    
//    NSDictionary *mainDict;
//    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
//    BOOL local = [self isLocal];
//    if(local){
//        mainDict = [data valueForKey:@"data"];
//    }else{
//        //till cloud changes are integrated
//        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
//    }// required for switching local<=>cloud
//    
//    
//    
//    
//    
//    NSLog(@" scene list dict %@",mainDict);
//    [toolkit.scenesArray removeAllObjects];
//    NSDictionary *scenesPayload = [mainDict valueForKey:@"Scenes"];
//    
//    NSArray *scenePosKeys = scenesPayload.allKeys;
//    NSArray *sortedPostKeys = [scenePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
//    }];
//    
//    for (NSString *key in sortedPostKeys) {
//        NSMutableArray *mutableEntryList = [self getMutableSceneEntryList:scenesPayload[key]];
//        NSMutableDictionary *mutableScene = [scenesPayload[key] mutableCopy];
//        [mutableScene setValue:mutableEntryList forKey:@"SceneEntryList"];
//        NSLog(@" getLaa scene %@",mutableScene);
//        [toolkit.scenesArray addObject:mutableScene];
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SCENE_TABLEVIEW object:nil userInfo:data];
//}

@end
