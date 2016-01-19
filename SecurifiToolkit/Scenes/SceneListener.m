//
//  SceneListener.m
//  SecurifiToolkit
//
//  Created by Masood on 30/12/15.
//  Copyright © 2015 Securifi Ltd. All rights reserved.
//

#import "SceneListener.h"
#import "SecurifiToolkit.h"

@implementation SceneListener

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
}

-(BOOL)isLocal{
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *almond = [toolkit currentAlmond];
    BOOL local = [toolkit useLocalNetwork:almond.almondplusMAC];
    return local;
}

-(NSMutableArray*)getMutableSceneEntryList:(NSDictionary*)sceneDict{
    NSMutableArray *mutableEntryList = [[NSMutableArray alloc]init];
    for(NSDictionary *entryList in [sceneDict valueForKey:@"SceneEntryList"]){
        [mutableEntryList addObject:[entryList mutableCopy]];
    }
    return mutableEntryList;
}

- (void)getAllScenesCallback:(id)sender {
    NSLog(@"getAllScenesCallback - scene listener");
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
    NSLog(@"main dict - %@", mainDict);
    [toolkit.scenesArray removeAllObjects];
    for(NSDictionary *sceneDict in [mainDict valueForKey:@"Scenes"]){
        NSMutableArray *mutableEntryList = [self getMutableSceneEntryList:sceneDict];
        
        NSMutableDictionary *mutableScene = [sceneDict mutableCopy];
        [mutableScene setValue:mutableEntryList forKey:@"SceneEntryList"];
        
        [toolkit.scenesArray addObject:mutableScene];
        
    }
    
    
    for(NSMutableDictionary *scenes in toolkit.scenesArray){
        for(NSMutableDictionary *sceneEntryList in [scenes valueForKey:@"SceneEntryList"]){
            [sceneEntryList removeObjectForKey:@"Valid"];
        }
    }
    NSLog(@"mutable scenes array: %@", toolkit.scenesArray);
    
}

- (void)onScenesListChange:(id)sender{
    NSLog(@"listner - onScenesListChange");
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
    NSDictionary *dict;
    NSString * commandType = [mainDict valueForKey:@"CommandType"];
    
    if ([commandType isEqualToString:@"DynamicSceneAdded"]){
        NSLog(@"DynamicSceneAdded: %@", mainDict);
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == [[[mainDict valueForKey:@"Scenes"] valueForKey:@"ID"] intValue]) {
                dict = sceneDict;
                break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
        NSMutableDictionary *newScene = [[mainDict valueForKey:@"Scenes"] mutableCopy];
        [newScene setValue:[self getMutableSceneEntryList:newScene] forKey:@"SceneEntryList"];
        for(NSMutableDictionary *sceneEntryList in [newScene valueForKey:@"SceneEntryList"]){
            [sceneEntryList removeObjectForKey:@"Valid"];
        }
        
        [toolkit.scenesArray addObject:newScene];
    }

    
    else if ([commandType isEqualToString:@"DynamicSceneActivated"]) {
        NSLog(@"before DynamicSceneActivated: %@", toolkit.scenesArray);
        //scenes has been activated
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == [[[mainDict valueForKey:@"Scenes" ] valueForKey:@"ID"] intValue]) {
                
                [sceneDict setValue:[[mainDict valueForKey:@"Scenes" ] valueForKey:@"Active"]  forKey:@"Active"]; //will be updated in toolkit.scensArray
                break;
            }
        }
        NSLog(@"after DynamicSceneActivated: %@", toolkit.scenesArray);
    }
    
    else if ([commandType isEqualToString:@"DynamicSceneUpdated"]) {
        NSLog(@"DynamicSceneUpdated: %@", mainDict);
        //scenes parameterers has been updated
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == [[[mainDict valueForKey:@"Scenes"] valueForKey:@"ID"] intValue]) {
                
                NSMutableDictionary *newScene = [[mainDict valueForKey:@"Scenes"] mutableCopy];
                [newScene setValue:[self getMutableSceneEntryList:newScene] forKey:@"SceneEntryList"];
                for(NSMutableDictionary *sceneEntryList in [newScene valueForKey:@"SceneEntryList"]){
                    [sceneEntryList removeObjectForKey:@"Valid"];
                }
                
                [sceneDict setValue:[newScene valueForKey:@"SceneEntryList"] forKey:@"SceneEntryList"];
                [sceneDict setValue:[[mainDict valueForKey:@"Scenes"] valueForKey:@"Name"] forKey:@"Name"];
                break;
            }
        }
    }

    else if ([commandType isEqualToString:@"DynamicSceneRemoved"]) {
        NSLog(@"before scene removed: %@", toolkit.scenesArray);
        for (NSDictionary * sceneDict in toolkit.scenesArray) {
            if ([[[mainDict valueForKey:@"Scenes"] valueForKey:@"ID"] intValue]==[[sceneDict valueForKey:@"ID"] intValue])
            {
                dict = sceneDict;
                break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
        NSLog(@"after scene removed: %@", toolkit.scenesArray);
    }
    
    else if ([commandType isEqualToString:@"DynamicAllScenesRemoved"]) {
        [toolkit.scenesArray removeAllObjects];
    }
    NSLog(@"listener - before posting notification");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_SCENE_TABLEVIEW object:nil userInfo:data];
//                  );
}



@end
