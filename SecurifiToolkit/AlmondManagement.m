//
//  AlmondManagement.m
//  SecurifiToolkit
//
//  Created by Masood on 10/17/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SFISecondaryUser.h"
#import "AlmondManagement.h"
#import "SecurifiToolKit.h"
#import "NotificationAccessAndRefreshCommands.h"
#import "AlmondModeRequest.h"
#import "RouterCommandParser.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "LocalNetworkManagement.h"
#import "AlmondPlan.h"

@implementation AlmondManagement

static NSMutableDictionary* almondListData;
static int count = 0;

+ (void)removeCurrentAlmond {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:kPREF_CURRENT_ALMOND];
    [prefs synchronize];
}


+(NSMutableArray*) getOwnedAlmondList {
    NSMutableArray* list = [NSMutableArray new];
    for(SFIAlmondPlus* almond in [self almondList]){
        if(almond.isPrimaryAlmond)
            [list addObject:almond];
    }
    return list;
}


+(NSMutableArray*) getSharedAlmondList{
    NSMutableArray* list = [NSMutableArray new];
    for(SFIAlmondPlus* almond in [self almondList]){
        if(!almond.isPrimaryAlmond)
            [list addObject:almond];
    }
    return list;
}


+ (void)setCurrentAlmond:(SFIAlmondPlus *)almond {
    if (!almond) {
        return;
    }
    [self writeCurrentAlmond:almond];
    [self manageCurrentAlmondChange:almond];
    [[SecurifiToolkit sharedInstance] postNotification:kSFIDidChangeCurrentAlmond data:almond];
}


+ (void)writeCurrentAlmond:(SFIAlmondPlus *)almond {
   if(!almond) {
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:almond];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:kPREF_CURRENT_ALMOND];
    [defaults synchronize];
}


+ (void)manageCurrentAlmondChange:(SFIAlmondPlus *)almond {
    
    if (!almond) {
        return;
    }
    
    NSString *mac = almond.almondplusMAC;
    SecurifiToolkit* toolKit = [SecurifiToolkit sharedInstance];
    
    // reset connections
    if([toolKit currentConnectionMode]==SFIAlmondConnectionMode_local){
        [toolKit tryShutdownAndStartNetworks];
        return; 
    }

    [toolKit cleanUp];
    
    GenericCommand * cmd = [self tryRequestAlmondMode:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestSensorDeviceList:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestAlmondClients:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestSceneList:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestAlmondRules:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestRouterSummary:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestAlmondProperties:mac];
    [toolKit asyncSendToNetwork:cmd];
    
    cmd = [GenericCommand requestScanNow:mac];
    [toolKit asyncSendToNetwork:cmd];
    // refresh notification preferences; currently, we cannot rely on receiving dynamic updates for these values and so always refresh.
    //    [self asyncRequestNotificationPreferenceList:mac]; //mk, currently requesting it on almond list response in device parser
}


+ (SFIAlmondPlus *)currentAlmond {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:kPREF_CURRENT_ALMOND];
    if (data) {
        SFIAlmondPlus *object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return object;
    }
    else {
        return nil;
    }
}

+ (SFIAlmondPlus *)cloudAlmond:(NSString *)almondMac {
    return [[SecurifiToolkit sharedInstance].dataManager readAlmond:almondMac];
}

+ (NSArray *)almondList {
    return [[SecurifiToolkit sharedInstance].dataManager readAlmondList];
}

+ (BOOL)almondExists:(NSString *)almondMac {
    NSArray *list = [self almondList];
    for (SFIAlmondPlus *almond in list) {
        if ([almond.almondplusMAC isEqualToString:almondMac]) {
            return YES;
        }
    }
    return NO;
}


+ (NSString*) getUserIDfromEmail: (NSString*)email andAlmondMAC: (NSString*)almondMAC {
    
    SFIAlmondPlus* almond = [self findAlmondFromAlmondListWithMAC:almondMAC];
    NSArray* secondaryUsers = almond.accessEmailIDs;
    
    for(SFISecondaryUser* user in secondaryUsers){
        if([user.emailId isEqualToString:email]){
            return user.userId;
        }
    }
    
    return nil;
}

+(SFIAlmondPlus*)findAlmondFromAlmondListWithMAC: (NSString*)almondPlusMAC {
    NSArray* almondList = [self almondList];
    for(SFIAlmondPlus* almond in almondList){
        if([almond.almondplusMAC isEqualToString:almondPlusMAC]){
            return almond;
        }
    }
}

+ (void)onAlmondDynamicResponse:(NSData*)responseData{
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData
                                                               options:kNilOptions
                                                                 error:nil];
    NSString* commandType = [response objectForKey:COMMAND_TYPE];
    
    if([[response objectForKey:@"Success"] isEqualToString:@"false"])
        return;
    
    if([commandType isEqualToString:@"DynamicAlmondAdd"]){
        
        SFIAlmondPlus* almond = [SFIAlmondPlus new];
        almond.almondplusName = [response objectForKey:@"AlmondName"];
        almond.almondplusMAC = [response objectForKey:@"AlmondMAC"];
        almond.firmware = [response objectForKey:@"FirmwareVersion"];
        almond.ownerEmailID = [response objectForKey:@"OwnerEmailID"];
        
        if([[response objectForKey:@"Ownership"] isEqualToString:@"P"]){
            almond.isPrimaryAlmond = true;
        }
        
        [self addAlmondToList:almond];
        
    }else if([commandType isEqualToString:@"DynamicAlmondDelete"]){
        
        [self removeAlmondFromList:[response objectForKey:@"AlmondMAC"]];
        
    }else if([commandType isEqualToString:@"DynamicUserDelete"]){
        
        [self removeSecondaryUserFromAlmondWithMAC:[response objectForKey:@"AlmondMAC"] withUserID:[response objectForKey:@"UserID"]];
        
    }else if([commandType isEqualToString:@"DynamicUserAdd"]){
        
        NSString* userID = ![[response objectForKey:@"UserID"] isKindOfClass:[NSString class]]?[[response objectForKey:@"UserID"] stringValue]:[response objectForKey:@"UserID"];
        [self addSecondaryUserToAlmondWithMAC:[response objectForKey:@"AlmondMAC"] withUserID:userID andEmailID:[response objectForKey:@"EmailID"]];
    }
}


+(void)removeSecondaryUserFromAlmondWithMAC:(NSString*)almondMAC withUserID:(NSString*)userID {
    NSArray* almondList = [self almondList];
    NSMutableArray* newAlmondList = [NSMutableArray new];
    for(SFIAlmondPlus* almond in almondList){
        if([almond.almondplusMAC isEqualToString:almondMAC]){
            NSArray* accessibleEmailIDs = almond.accessEmailIDs;
            NSMutableArray* newAcessibleEmailIDs = [NSMutableArray new];
            
            for(SFISecondaryUser* user in accessibleEmailIDs){
                if(![user.userId isEqualToString:userID]){
                    [newAcessibleEmailIDs addObject:user];
                }
            }
            almond.accessEmailIDs = newAcessibleEmailIDs;
        }
        
        [newAlmondList addObject:almond];
    }
    
    [[SecurifiToolkit sharedInstance].dataManager writeAlmondList:newAlmondList];
    [[SecurifiToolkit sharedInstance] postNotification:RELOAD_ACCOUNTS_PAGE data:nil];
}


+(void) addSecondaryUserToAlmondWithMAC :(NSString*)almondMAC withUserID:(NSString*) userID andEmailID:(NSString*)emailID {
    
    NSArray* almondList = [self almondList];
    NSMutableArray* newAlmondList = [NSMutableArray new];
    for(SFIAlmondPlus* almond in almondList){
        if([almond.almondplusMAC isEqualToString:almondMAC]){
            
            NSArray* accessibleEmailIDs = almond.accessEmailIDs;
            NSMutableArray* newAccessibleEmailIDs = [NSMutableArray new];
            
            for(SFISecondaryUser* user in accessibleEmailIDs ){
                [newAccessibleEmailIDs addObject:user];
            }
            
            SFISecondaryUser* user = [SFISecondaryUser new];
            user.userId = userID;
            user.emailId = emailID;
            
            [newAccessibleEmailIDs addObject:user];
            almond.accessEmailIDs = newAccessibleEmailIDs;
        }
        
        [newAlmondList addObject:almond];
    }
    
    [[SecurifiToolkit sharedInstance].dataManager writeAlmondList:newAlmondList];
    [[SecurifiToolkit sharedInstance] postNotification:RELOAD_ACCOUNTS_PAGE data:nil];
}


+(void)addAlmondToList:(SFIAlmondPlus*)almond {
    
    NSMutableArray* almondList = [NSMutableArray new];
    
    for(SFIAlmondPlus* currentAlmond in [self almondList]){
        [almondList addObject:currentAlmond];
    }
    
    [almondList addObject:almond];
    
    [self wrietAlmondListToDataManager:almondList];
}


+(void)removeAlmondFromList:(NSString*)almondMAC {
    NSMutableArray* almondList = [NSMutableArray new];
    for(SFIAlmondPlus* almond in [self almondList]){
        if(![almond.almondplusMAC isEqualToString:almondMAC]){
            [almondList addObject:almond];
        }
    }
    
    [self wrietAlmondListToDataManager:almondList];
}


+(void) wrietAlmondListToDataManager:(NSMutableArray*)almondList {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    [toolkit.dataManager writeAlmondList:almondList];
    // Ensure Current Almond is consistent with new list
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:YES];
    
    // Tell the world that this happened
    [toolkit postNotification:kSFIDidUpdateAlmondList data:plus];
}


#pragma mark - Almond List Management
+ (NSArray *)localLinkedAlmondList {
    
    if (![SecurifiToolkit sharedInstance].config.enableLocalNetworking) {
        return nil;
    }
    
    // Below is an important filtering process:
    // in effect, we choose to use the Cloud Almond representation for matching
    // local network configs, because the Almond#linkType property will indicate
    // the almond supports both local and cloud network connections. This will ensure the
    // UI can do the right thing and show the right message to the user when connection modes
    // are switched.

    // Note for large lists of almonds, the way the data manger internally manages cloud almond lists
    // is inefficient for these sorts of operations, and a dictionary data structure would allow for
    // fast look up, instead of iteration.
    NSMutableSet *cloud_set = [NSMutableSet setWithArray:[self almondList]];
    
    NSDictionary *local_settings = [[SecurifiToolkit sharedInstance].dataManager readAllAlmondLocalNetworkSettings];
    NSMutableArray *local_almonds = [NSMutableArray array];
    
    for (NSString *mac in local_settings.allKeys) {
        SFIAlmondPlus *localAlmond;
        
        for (SFIAlmondPlus *cloud in cloud_set) {
            if ([cloud.almondplusMAC isEqualToString:mac]) {
                localAlmond = cloud;
                [cloud_set removeObject:cloud];
                break;
            }
        }
        
        if (!localAlmond) {
            SFIAlmondLocalNetworkSettings *setting = local_settings[mac];
            localAlmond = setting.asLocalLinkAlmondPlus;
        }
        
        if (localAlmond) {
            [local_almonds addObject:localAlmond];
        }
    }
    
    if (local_almonds.count == 0) {
        return nil;
    }
    
    // Sort the local Almonds alphabetically
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"almondplusName" ascending:YES];
    [local_almonds sortUsingDescriptors:@[sort]];
    return local_almonds;
}


/*
//When we request for almondList we get both almondList and Affiliation Data response
//This function handles both AlmondListResponse and AffiliationData response to create almondlist
*/
+ (void)processTheAlmondManagementCommand: (NSDictionary*)response withNetwork:(Network*)network {
    if([response[COMMAND_TYPE] isEqualToString:ALMOND_LIST_RESPONSE]||[response[COMMAND_TYPE] isEqualToString:ALMOND_AFFILIATION_DATA]){
        [self onAlmondListAndAffiliationDataResponse:response network:network];
    }
}

+ (void)onAlmondListAndAffiliationDataResponse:(NSDictionary*)response network:(Network *)network {
    
    count++;
    
    if(count == 1){
        almondListData = [NSMutableDictionary new];
    }
    
    NSArray* almondsDataResponse = response[@"Almond"];
    
    if([response[COMMAND_TYPE] isEqualToString:ALMOND_LIST_RESPONSE]){
        
        [self fillAlmondListWithAlmondListDataResponse:almondsDataResponse intoDictionary:almondListData];
        
    }else if([response[COMMAND_TYPE] isEqualToString:ALMOND_AFFILIATION_DATA] ){
        
        [self fillAlmondListWithAffiliationDataResponse:almondsDataResponse intoDictionary:almondListData];
    }
    
    if(count==2){
        [self updateAlmondList:almondListData withNetwork:network];
        count = 0;
    }
}


+(void) fillAlmondListWithAlmondListDataResponse: (NSArray*)almondAffiliationResponse intoDictionary:(NSMutableDictionary*)almondListData{
    
    for(NSDictionary *almond in almondAffiliationResponse){
        
        SFIAlmondPlus *newAlmond = almondListData[almond[@"AlmondMAC"]];
        
        if(newAlmond == nil){
            newAlmond = [SFIAlmondPlus new];
        }
        
        newAlmond.almondplusMAC = almond[@"AlmondMAC"];
        newAlmond.almondplusName = almond[@"AlmondName"];
        newAlmond.firmware = almond[@"FirmwareVersion"];
        
        if([almond[@"Ownership"] isEqualToString:@"P"]){
            newAlmond.isPrimaryAlmond = true;
        }
        
        [almondListData setObject:newAlmond forKey:almond[@"AlmondMAC"]];
    }
}


+(void) fillAlmondListWithAffiliationDataResponse:(NSArray*)almondListResponse intoDictionary:(NSMutableDictionary*)almondListData{
    
    for(NSDictionary *almond in almondListResponse){
        
        SFIAlmondPlus *newAlmond;
        newAlmond = [almondListData objectForKey:almond[@"AlmondMAC"]];
        
        if(newAlmond==nil){
            newAlmond = [SFIAlmondPlus new];
        }
        
        if(almond[@"EmailID"]){
            
            NSArray* users = almond[@"EmailID"];
            NSMutableArray* secondaryEmails = [NSMutableArray new];
            
            for(NSDictionary* user in users){
                SFISecondaryUser* secondaryUser = [SFISecondaryUser new];
                secondaryUser.emailId = user[@"SecondaryEmail"];
                secondaryUser.userId = user[@"UserID"];
                [secondaryEmails addObject:secondaryUser];
            }
            
            newAlmond.accessEmailIDs = secondaryEmails;
            
        }else if(almond[@"OwnerEmailID"]){
            newAlmond.ownerEmailID = almond[@"OwnerEmailID"];
        }
        
        [almondListData setObject:newAlmond forKey:almond[@"AlmondMAC"]];
    }
}


+ (void) updateAlmondList:(NSMutableDictionary*)almondListData withNetwork:(Network*) network {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    NSMutableArray* almondList = [NSMutableArray new];
    for(NSString* almondMAC in almondListData.allKeys){
        [almondList addObject:almondListData[almondMAC]];
    }
    // Store the new list
    [toolkit.dataManager writeAlmondList:almondList];
    
    SFIAlmondPlus *plus = [self manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
    
    if(plus!=nil)
        // After requesting the Almond list, we then want to get additional info
        [self asyncInitializeConnection2:network];
    // Tell the world
    [toolkit postNotification:kSFIDidUpdateAlmondList data:plus];
}


+ (void)asyncInitializeConnection2:(Network *)network {
    // After successful login, refresh the Almond list and hash values.
    // This routine is important because the UI will listen for outcomes to these requests.
    // Specifically, the event kSFIDidUpdateAlmondList.
    SecurifiToolkit *toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *plus = [self currentAlmond];
    
    NSLog(@"asyncInitializeConnection plus mac %@",plus.almondplusMAC);
    if (plus != nil) {
        NSString *mac = plus.almondplusMAC;
        GenericCommand *cmd;
        NSLog(@"commandDispatchQueue 1..");
        
        cmd = [GenericCommand requestSensorDeviceList:plus.almondplusMAC];
        
        [toolkit asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestSceneList:plus.almondplusMAC];
        
        [toolkit asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestAlmondClients:plus.almondplusMAC];
        
        [toolkit asyncSendToNetwork:cmd];

        cmd = [GenericCommand requestAlmondRules:plus.almondplusMAC];
        [toolkit asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestAlmondProperties:plus.almondplusMAC];
        [toolkit asyncSendToNetwork:cmd];
        
        cmd = [GenericCommand requestScanNow:plus.almondplusMAC];
         [toolkit asyncSendToNetwork:cmd];
        
        if(toolkit.currentConnectionMode!=SFIAlmondConnectionMode_local){
            cmd = [GenericCommand requestRouterSummary:plus.almondplusMAC];
            [toolkit asyncSendToNetwork:cmd];
        }
        
        cmd = [self tryRequestAlmondMode:mac];
        if(cmd!=nil)
            [toolkit asyncSendToNetwork:cmd];
        
        [NotificationAccessAndRefreshCommands tryRefreshNotifications];
    }
}


+ (GenericCommand* )tryRequestAlmondMode:(NSString *)almondMac {
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (almondMac == nil || toolkit.currentConnectionMode==SFIAlmondConnectionMode_local) {
        return nil;
    }
    
    AlmondModeRequest *req = [AlmondModeRequest new];
    req.almondMAC = almondMac;
    
    GenericCommand *cmd = [GenericCommand new];
    cmd.commandType = CommandType_ALMOND_MODE_REQUEST;
    cmd.command = req;
    
    return cmd;
}


+ (void)onDynamicAlmondNameChange:(DynamicAlmondNameChangeResponse *)obj {
    
    SecurifiToolkit *toolKit = [SecurifiToolkit sharedInstance];
    NSString *almondName = obj.almondplusName;
    
    if (almondName.length == 0) {
        return;
    }
    
    NSLog(@"Came here onDynamicAlmondNameChange %@",almondName);
    SFIAlmondPlus *changed = [toolKit.dataManager changeAlmondName:almondName almondMac:obj.almondplusMAC];
    if (changed) {
        SFIAlmondPlus *current = [self currentAlmond];
        if ([current isEqualAlmondPlus:changed]) {
            changed.colorCodeIndex = current.colorCodeIndex;
            [self writeCurrentAlmond:changed];
        }
        // Tell the world so they can update their view
        [toolKit postNotification:kSFIDidChangeAlmondName data:obj];
    }
}


// When the cloud almond list is changed, ensure the Current Almond setting is consistent with the list.
// This method has side-effects and can change settings.
// Returns the current Almond, which might or might not be the same as the old one. May return nil.
+ (SFIAlmondPlus *)manageCurrentAlmondOnAlmondListUpdate:(NSArray *)almondList manageCurrentAlmondChange:(BOOL)doManage {
    // if current is "local only" then no need to inspect the almond list; just return the current one.
    
    SecurifiToolkit * toolKit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus *current = [self currentAlmond];
//    if (current.linkType == SFIAlmondPlusLinkType_local_only) {
//        NSLog(@"linkType is local_only");
//        return current;
//    }
    // Manage the "Current selected Almond" value
    toolKit.lastScanTime = 0;
    if (almondList.count == 0) {
        [toolKit purgeStoredData];
        return nil;
    }
    else if (almondList.count == 1) {
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            [self setCurrentAlmond:currentAlmond];
        }
        else {
            [self writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
    else {
        if (current) {
            for (SFIAlmondPlus *almond in almondList) {
                if ([almond.almondplusMAC isEqualToString:current.almondplusMAC]) {
                    // Current one is still in list, so leave it as current.
                    [self writeCurrentAlmond:almond];
                    return almond;
                }
            }
        }
        
        // Current one is not in new list.
        // Just pick the first one in this case
        toolKit.lastScanTime = 0;
        SFIAlmondPlus *currentAlmond = almondList[0];
        if (doManage) {
            [self setCurrentAlmond:currentAlmond];
        }
        else {
            [self writeCurrentAlmond:currentAlmond];
        }
        return currentAlmond;
    }
}

#pragma mark - almond mode change response callbacks

+ (void)onAlmondModeChangeCompletion:(NSDictionary*)res network:(Network *)network {
    
    [network.networkState confirmPendingModeForAlmond];
    
    NSString *notification = kSFIDidCompleteAlmondModeChangeRequest;
    [[SecurifiToolkit sharedInstance] postNotification:notification data:nil];
}

+ (void)onAlmondModeResponse:(AlmondModeResponse *)res network:(Network *)network {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (res == nil) {
        return;
    }
    
    if (!res.success) {
        return;
    }
    
    if([res.almondMAC isEqualToString:[self currentAlmond].almondplusMAC]){
        [network.networkState markModeForAlmond:[self currentAlmond].almondplusMAC mode:res.mode];
        NSDictionary *modeNotifyDict =  @{
                                          @"CommandType": @"AlmondModeResponse",
                                          @"Mode" : @(res.mode).stringValue
                                          
                                          };
        toolkit.mode_src = res.mode;
        [toolkit postNotification:kSFIAlmondModeDidChange data:modeNotifyDict];
    }
}


+ (void)onDynamicAlmondModeChange:(DynamicAlmondModeChange *)res network:(Network *)network {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (res == nil) {
        return;
    }
    
    if (!res.success) {
        return;
    }
    
    //    NSString *modeString = res[@"Mode"];
    if([res.almondMAC isEqualToString:[self currentAlmond].almondplusMAC]){
        [network.networkState markModeForAlmond:[self currentAlmond].almondplusMAC mode:res.mode];
        NSDictionary *modeNotifyDict =  @{
                                          @"CommandType": @"DynamicAlmondModeUpdated",
                                          @"Mode" : @(res.mode).stringValue
                                          };
        toolkit.mode_src = res.mode;
        [toolkit postNotification:kSFIAlmondModeDidChange data:modeNotifyDict];
    }
}

#pragma mark - Generic Almond Router commmand callbacks
+ (void)onAlmondRouterGenericNotification:(GenericCommandResponse *)res network:(Network *)network {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    
    if (!res.isSuccessful) {
        SFIGenericRouterCommand *routerCommand = [SFIGenericRouterCommand new];
        routerCommand.almondMAC = mac;
        routerCommand.commandSuccess = NO;
        routerCommand.responseMessage = res.reason;
        
        [toolkit postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
    }
    
    else {
        SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:res];
        routerCommand.almondMAC = mac;
        
        [self internalOnGenericRouterCommandResponse:routerCommand];
    }
}


+ (void)onAlmondRouterGenericCommandResponse:(GenericCommandResponse *)res network:(Network *)network {
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    
    SFIGenericRouterCommand *routerCommand = [RouterCommandParser parseRouterResponse:res];
    routerCommand.almondMAC = mac;
    
    [self internalOnGenericRouterCommandResponse:routerCommand];
}


+ (void)onAlmondRouterCommandResponse:(SFIGenericRouterCommand *)res network:(Network *)network {
    if (!res) {
        return;
    }
    
    NSString *mac = res.almondMAC;
    [network.networkState clearExpirableRequest:ExpirableCommandType_almondStateAndSettingsRequest namespace:mac];
    [self internalOnGenericRouterCommandResponse:res];
}

+ (void)internalOnGenericRouterCommandResponse:(SFIGenericRouterCommand *)routerCommand {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    if (routerCommand == nil) {
        return;
    }
    
    if (routerCommand.commandType == SFIGenericRouterCommandType_WIRELESS_SUMMARY) {
        // after receiving summary, we update the local wireless connection settings with the current login/password
        SFIRouterSummary *summary = (SFIRouterSummary *) routerCommand.command;
        
        [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:routerCommand.almondMAC withRouterSummary:summary];
    }
    
    [toolkit postNotification:kSFIDidReceiveGenericAlmondRouterResponse data:routerCommand];
}

+ (NSArray *)getAL3s:(NSArray *)cloud{
    NSMutableArray *al3Array = [NSMutableArray new];
    for(SFIAlmondPlus *alm in cloud){
        if([alm.firmware.lowercaseString hasPrefix:@"al3-"])
            [al3Array addObject:alm];
    }
    return al3Array;
}

+ (BOOL)hasAtleaseOneAL3{
    NSArray *almonds = [AlmondManagement almondList];
    for(SFIAlmondPlus *alm in almonds){
        if([alm.firmware.lowercaseString hasPrefix:@"al3-"])
            return YES;
    }
    return NO;
}

+ (SFIAlmondPlus *)tryLoadCurrentAL3{
    NSString *currentAlmMac = [AlmondManagement currentAlmond].almondplusMAC;
    NSArray *al3List = [self getAL3s:[AlmondManagement almondList]];
    for(SFIAlmondPlus *alm in al3List){
        if([alm.almondplusMAC isEqualToString:currentAlmMac])
            return alm;
    }
    return [al3List objectAtIndex:0];
}

@end
