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
        mainDict = [data valueForKey:@"data"];
    }else{
        //till cloud changes are integrated
        if(![[data valueForKey:@"data"] isKindOfClass:[NSData class]])
            return;

        mainDict = [[data valueForKey:@"data"] objectFromJSONData];
    }
    
    BOOL isMatchingAlmondOrLocal = ([[mainDict valueForKey:ALMONDMAC] isEqualToString:toolkit.currentAlmond.almondplusMAC] || local) ? YES: NO;
    if(!isMatchingAlmondOrLocal) //for cloud
        return;
    
    NSLog(@"main scene dict %@",mainDict);
    NSDictionary *dict;
    NSString * commandType = [mainDict valueForKey:@"CommandType"];
    
    
    if([commandType isEqualToString:@"DynamicSceneList"] || [commandType isEqualToString:@"SceneList"]){
        if([[mainDict valueForKey:@"Scenes"] isKindOfClass:[NSArray class]])
            return;
        NSDictionary *scenesPayload = [mainDict valueForKey:@"Scenes"];
        NSLog(@"scenesPayload sceneList %@",scenesPayload);
        NSArray *scenePosKeys = scenesPayload.allKeys;
        NSArray *sortedPostKeys = [scenePosKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
        
        NSMutableArray *scenesList = [NSMutableArray new];
        for (NSString *key in sortedPostKeys) {
            if([[NSString stringWithFormat:@"%@", [scenesPayload[key] valueForKey:@"SceneEntryList"]] isEqualToString:@""])
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
        NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        NSMutableDictionary *newScene = [[mainDict valueForKey:@"Scenes"] mutableCopy];
        
        if([[NSString stringWithFormat:@"%@", [newScene[updatedID] valueForKey:@"SceneEntryList"]] isEqualToString:@""])
            return;
            
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray) {
            if ([[sceneDict valueForKey:@"ID"] intValue] == [updatedID intValue]) {
                dict = sceneDict;
                break;
            }
        }
        if(dict != nil){
            [toolkit.scenesArray removeObject:dict];
        }
        
//         NSMutableDictionary *mutableScene = [scenesPayload[key] mutableCopy];
        NSLog( @"new scene add updated id %@",[newScene valueForKey:updatedID]);
         NSMutableDictionary *mutableScene = [newScene[updatedID] mutableCopy];
        [mutableScene setValue:[self getMutableSceneEntryList:[newScene valueForKey:updatedID]] forKey:@"SceneEntryList"];
        [mutableScene setValue:updatedID forKey:@"ID"];
         NSLog( @"new scene add after updated id %@",mutableScene);
        

        [newScene setValue:mutableScene forKey:updatedID];
        NSLog(@"final new scene %@",newScene);
        [toolkit.scenesArray addObject:mutableScene];
    }
    
    
    else if ([commandType isEqualToString:@"DynamicSceneUpdated"]) {
        //scenes has been activated
        NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"]valueForKey:updatedID];
        if([[NSString stringWithFormat:@"%@", [newScene[updatedID] valueForKey:@"SceneEntryList"]] isEqualToString:@""])
            return;
        NSInteger index = 0;
        for (NSDictionary *sceneDict in toolkit.scenesArray) {
            NSLog(@"sceneDict active:: %@",sceneDict);
            if ([[sceneDict valueForKey:@"ID"] intValue] == [updatedID intValue]) {
                index = [toolkit.scenesArray indexOfObject:sceneDict];
                break;
            }
        }
        NSMutableDictionary *mutableScene = [newScene mutableCopy];
        [mutableScene setValue:[self getMutableSceneEntryList:newScene] forKey:@"SceneEntryList"];
        [mutableScene setValue:updatedID forKey:@"ID"];

        NSLog(@"index replace %d",index);
        [toolkit.scenesArray replaceObjectAtIndex:index withObject:mutableScene];
    }
    else if ([commandType isEqualToString:@"DynamicSceneActivated"]){
        NSString *updatedID = [[[mainDict valueForKey:@"Scenes"] allKeys] objectAtIndex:0];
        NSDictionary *newScene = [mainDict[@"Scenes"] valueForKey:updatedID];
        NSInteger index = 0;
        for (NSMutableDictionary *sceneDict in toolkit.scenesArray){
            if ([[sceneDict valueForKey:@"ID"] intValue] == [updatedID intValue]){
                sceneDict[@"Active"] = newScene[@"Active"];
            }
        }

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
    NSLog(@"getMutableSceneEntryList sceneDict %@",sceneDict);
    NSMutableArray *mutableEntryList = [[NSMutableArray alloc]init];
    NSString *updatedID = [[sceneDict  allKeys] objectAtIndex:0];
    NSArray *sceneEntryListPayload = [sceneDict valueForKey:@"SceneEntryList"];
    // need to handle empty SceneEntryList
    for(NSDictionary *entryList in sceneEntryListPayload){
        NSMutableDictionary *mutableEntry = [entryList mutableCopy];
        
        if([mutableEntry[@"ID"] isEqualToString:@"0"] &&  [mutableEntry[@"Index"] isEqualToString:@"1"] && ([mutableEntry[@"Value"] isEqualToString:@"home"] ||[mutableEntry[@"Value"] isEqualToString:@"away"])){
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