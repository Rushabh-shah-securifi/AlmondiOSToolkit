//
//  SceneParser.m
//  SecurifiToolkit
//
//  Created by Masood on 30/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "SceneParser.h"
#import "SecurifiToolkit.h"

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
                   name:NOTIFICATION_GET_ALL_SCENES_NOTIFIER//
                 object:nil];
    
    [center addObserver:self
               selector:@selector(onScenesListChange:)
                   name:NOTIFICATION_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE_NOTIFIER
                 object:nil];
//    
//    [center addObserver:self
//               selector:@selector(getAllScenesCallback:)
//                   name:NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER
//                 object:nil];//NOTIFICATION_SCENE_LIST_AND_DYNAMIC_RESPONSES_NOTIFIER
}



- (void)getAllScenesCallback:(id)sender {
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    
    NSDictionary *mainDict;
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL local = [self isLocal];
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        //till cloud changes are integrated
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }// required for switching local<=>cloud

    NSLog(@" scene list dict %@",mainDict);
    [toolkit.scenesArray removeAllObjects];
    
    NSDictionary *scenesPayload = [mainDict valueForKey:@"Scenes"];
    NSArray *sceneKeys = scenesPayload.allKeys;

    for (NSString *key in sceneKeys) {
        NSMutableArray *mutableEntryList = [self getMutableSceneEntryList:scenesPayload[key]];
        NSMutableDictionary *mutableScene = [scenesPayload[key] mutableCopy];
        [mutableScene setValue:mutableEntryList forKey:@"SceneEntryList"];
        [toolkit.scenesArray addObject:mutableScene];
    }

    for(NSMutableDictionary *scenes in toolkit.scenesArray){
        for(NSMutableDictionary *sceneEntryList in [scenes valueForKey:@"SceneEntryList"]){
            [sceneEntryList removeObjectForKey:@"Valid"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SCENE_TABLEVIEW object:nil userInfo:data];
}

- (void)onScenesListChange:(id)sender{
    
    NSNotification *notifier = (NSNotification *) sender;
    NSDictionary *data = [notifier userInfo];
    
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    BOOL local = [self isLocal];
    NSDictionary *mainDict;
    if(local){
        mainDict = [data valueForKey:@"data"];
    }else{
        //till cloud changes are integrated
        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    NSLog(@"main scene dict %@",mainDict);
    NSDictionary *dict;
    NSString * commandType = [mainDict valueForKey:@"CommandType"];
    
    if ([commandType isEqualToString:@"DynamicSceneAdded"]){
        NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == [updatedID intValue]) {
                dict = sceneDict;
                break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
        NSMutableDictionary *newScene = [[mainDict valueForKey:@"Scenes"] mutableCopy];
        [newScene setValue:[self getMutableSceneEntryList:[newScene valueForKey:updatedID]] forKey:@"SceneEntryList"];
        
        for(NSMutableDictionary *sceneEntryList in [newScene  valueForKey:@"SceneEntryList"]){
            [sceneEntryList removeObjectForKey:@"Valid"];
        }
        NSLog(@" new scene name %@",newScene);
        [toolkit.scenesArray addObject:[newScene valueForKey:updatedID]];
    }
    
    
    else if ([commandType isEqualToString:@"DynamicSceneActivated"]) {
        //scenes has been activated
         NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"]valueForKey:updatedID];
        NSInteger index = 0;
        for (NSDictionary *sceneDict in toolkit.scenesArray) {
            NSLog(@"sceneDict %@",sceneDict);
            if ([[sceneDict valueForKey:@"ID"] intValue] == [updatedID intValue]) {
                index = [toolkit.scenesArray indexOfObject:sceneDict];
                break;
            }
        }
        [toolkit.scenesArray replaceObjectAtIndex:index withObject:newScene];
    }
    
    else if ([commandType isEqualToString:@"DynamicSceneUpdated"]) {
        //scenes parameterers has been updated
         NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
         NSDictionary *newScene = [mainDict[@"Scenes"]valueForKey:updatedID];
        NSInteger index = 0;
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] ==  [updatedID intValue]) {
                
                NSMutableDictionary *newScene = [[mainDict valueForKey:@"Scenes"] mutableCopy];
                [newScene setValue:[self getMutableSceneEntryList:[newScene valueForKey:updatedID]] forKey:@"SceneEntryList"];
                for(NSMutableDictionary *sceneEntryList in [newScene valueForKey:@"SceneEntryList"]){
                    [sceneEntryList removeObjectForKey:@"Valid"];
                }
                index = [toolkit.scenesArray indexOfObject:sceneDict];
                break;
            }
        }
        [toolkit.scenesArray replaceObjectAtIndex:index withObject:newScene];
    }
    
    else if ([commandType isEqualToString:@"DynamicSceneRemoved"]) {
        NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        for (NSDictionary * sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == updatedID.intValue)
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

-(BOOL)isLocal{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    return local;
}

-(NSMutableArray*)getMutableSceneEntryList:(NSDictionary*)sceneDict{
    NSMutableArray *mutableEntryList = [[NSMutableArray alloc]init];
    NSLog(@"scene entry list1 %@",sceneDict );
    NSString *updatedID = [[sceneDict  allKeys] objectAtIndex:0];
    NSArray *sceneEntryListPayload = [sceneDict valueForKey:@"SceneEntryList"];
    
    for(NSDictionary *entryList in sceneEntryListPayload){
        NSMutableDictionary *mutableEntry = [entryList mutableCopy];
        
        if([mutableEntry[@"ID"] isEqualToString:@"0"] &&  [mutableEntry[@"Index"] isEqualToString:@"1"] && ([mutableEntry[@"Value"] isEqualToString:@"home"] ||[mutableEntry[@"Value"] isEqualToString:@"away"])){
            [self changeModeProperties:mutableEntry];
             NSLog(@"mode dict %@",mutableEntry);
        }
       
        [mutableEntryList addObject:mutableEntry];
    }
    return mutableEntryList;
}

-(void)changeModeProperties:(NSMutableDictionary*)modeEntry{
    modeEntry[@"ID"] = @"0";
    modeEntry[@"Index"] = @"0";
    modeEntry[@"EventType"] = @"AlmondModeUpdated";
}

@end