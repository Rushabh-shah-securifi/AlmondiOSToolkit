//
//  CommandMapping.m
//  SecurifiToolkit
//
//  Created by Masood on 28/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "CommandMapping.h"
@interface CommandMapping()

@property(nonatomic) NSString* str; //private to class

@end

@implementation CommandMapping

-(void) mapCommand: (GenericCommand *)cmd{
    NSLog(@"********** Inside Command Mapping *************");
    NSLog(@"cmd.command: %@", cmd.command);
    NSLog(@"cmd.commandType: %d", cmd.commandType);
    unsigned int command_type = cmd.commandType;
    CommandObject *commandObj = [CommandObject sharedInstance]; //singleton class
    if(!commandObj.isTrueDictInitialized){
        [commandObj initializeTrueResponseDictionary];
        commandObj.isTrueDictInitialized = YES;
        NSLog(@"true resp dict: %@", commandObj.trueResponseDict);
    }
    dummyCloudEndpoint *dc = [[dummyCloudEndpoint alloc] init];
    Network *network = [[Network alloc] init];
    dc.delegate = network;
    switch (command_type) {
            
        case CommandType_LOGIN_COMMAND:{
            NSLog(@"login command");
            Class class = cmd.command;
            LoginResponse *loginResponse;
            if([class isKindOfClass:[LoginTempPass class]]){
                LoginTempPass *logintemp = cmd.command;
                
                if([[commandObj.trueResponseDict valueForKey:@"LOGIN_COMMAND_TempPass"] intValue]){
                    NSLog(@"login-true");
                    loginResponse = [commandObj createLoginResponseWithUserID:logintemp.UserID tempPass:logintemp.TempPass reason:@"success" reasonCode:0 isSuccessful:YES];
                }
                else{
                    NSLog(@"login-false");
                    loginResponse = [commandObj createLoginResponseWithUserID:logintemp.UserID tempPass:logintemp.TempPass reason:@"failed" reasonCode:1 isSuccessful:NO];
                }
            }
            else{
                NSLog(@"login response");
                Login *loginCommand = cmd.command;
                if([[commandObj.trueResponseDict valueForKey:@"LOGIN_COMMAND_Login"] intValue]){
                    loginResponse = [commandObj createLoginResponseWithUserID:loginCommand.UserID tempPass:loginCommand.Password reason:@"success" reasonCode:0 isSuccessful:YES];
                }
                else{
                    loginResponse = [commandObj createLoginResponseWithUserID:loginCommand.UserID tempPass:loginCommand.Password reason:@"failed" reasonCode:1 isSuccessful:NO];
                }
                // there are two more properties, already initialized in loginresponse constructor
            }
            [dc callDummyCloud:loginResponse commandType:CommandType_LOGIN_RESPONSE];
            break;
        }
        case CommandType_LOGOUT_COMMAND:{
            LoginResponse *logoutresp;
            if([[commandObj.trueResponseDict valueForKey:@"LOGOUT_COMMAND"] intValue]){
                logoutresp=[commandObj createLoginResponseWithUserID:@"masood.pathan@securifi.com" tempPass:@"123456" reason:@"success" reasonCode:0 isSuccessful:YES];
            }else{
                logoutresp=[commandObj createLoginResponseWithUserID:@"masood.pathan@securifi.com" tempPass:@"123456" reason:@"failure" reasonCode:0 isSuccessful:YES];
            }
            [dc callDummyCloud:logoutresp commandType:CommandType_LOGOUT_RESPONSE];
            break;
        }
        case CommandType_LOGOUT_ALL_COMMAND:{
            NSLog(@"in logout command case");
            LogoutAllResponse *logoutresponse;
            if([[commandObj.trueResponseDict valueForKey:@"LOGOUT_ALL_COMMAND"] intValue]){
                logoutresponse = [commandObj logoutAllResponseWithReason:@"success" reasonCode:0 isSuccessful:YES];
            }else{
                logoutresponse = [commandObj logoutAllResponseWithReason:@"failure" reasonCode:1 isSuccessful:NO];
            }
            [dc callDummyCloud:logoutresponse commandType:CommandType_LOGOUT_ALL_RESPONSE];
            break;
        }
        case CommandType_SIGNUP_COMMAND:{
            NSLog(@"sign up");
            SignupResponse *signupResponse;
            if([[commandObj.trueResponseDict valueForKey:@"SIGNUP_COMMAND"] intValue]){
                signupResponse=[commandObj signupResponseWithReason:@"success" reasonCode:0 isSuccessful:YES];
            }else{
                signupResponse=[commandObj signupResponseWithReason:@"failed" reasonCode:1 isSuccessful:NO];
            }
            [dc callDummyCloud:signupResponse commandType:CommandType_SIGNUP_RESPONSE];
            break;
        }
        case CommandType_VALIDATE_REQUEST:{
            NSLog(@"validate request");
            ValidateAccountResponse *validate;
            if([[commandObj.trueResponseDict valueForKey:@"VALIDATE_REQUEST"] intValue]){
                validate = [commandObj validateAccountResponseWithReason:@"success" reasonCode:0 isSuccessful:YES];
            }else{
                validate = [commandObj validateAccountResponseWithReason:@"failed" reasonCode:1  isSuccessful:NO];
            }
            [dc callDummyCloud:validate commandType:CommandType_VALIDATE_RESPONSE];
            break;
        }
        case CommandType_RESET_PASSWORD_REQUEST:{
            NSLog(@"reset password");
            ResetPasswordResponse *reset;
            if([[commandObj.trueResponseDict valueForKey:@"RESET_PASSWORD_REQUEST"] intValue]){
                reset = [commandObj resetPasswordResponseWithReason:@"success" reasonCode:0 isSuccessful:YES];
            }else{
                reset = [commandObj resetPasswordResponseWithReason:@"failed" reasonCode:1 isSuccessful:NO];
            }
            [dc callDummyCloud:reset commandType:CommandType_RESET_PASSWORD_RESPONSE];
            break;
        }
        case CommandType_AFFILIATION_CODE_REQUEST:{
            NSLog(@"CommandType_AFFILIATION_CODE_REQUEST");
            AffiliationUserComplete *usercomplete;
            if([[commandObj.trueResponseDict valueForKey:@"AFFILIATION_CODE_REQUEST"] intValue]){
                usercomplete=[commandObj AffiliationUserCompleteWithAlmondPlusName:@"almondplus affiliation" almondPlusMAC:@"251176217041064" reason:@"success" reasonCode:0 isSuccessful:YES wifiSSID:@"ssid1,ssid2" wifiPassword:@"password"];
            }else{
                usercomplete=[commandObj AffiliationUserCompleteWithAlmondPlusName:@"almondplus affiliation" almondPlusMAC:@"251176217041064" reason:@"failed" reasonCode:1 isSuccessful:NO wifiSSID:@"ssid1,ssid2" wifiPassword:@"password"];
            }
            [dc callDummyCloud:usercomplete commandType:CommandType_AFFILIATION_USER_COMPLETE];
            break;
        }
        case CommandType_ALMOND_LIST: {
            NSLog(@"************* mockcloud.m -> CommandType_ALMOND_LIST: () ***************");
            NSMutableArray* accessEmailIDs_1 = [NSMutableArray arrayWithObjects:@"masood.pathan@securifi.com", @"masood@securifi.com", nil];
            SFIAlmondPlus *plus1 = [commandObj createAlmondPlusWithAlmondPlusName:@"almondplus_1" almondPlusMAC:@"251176217041064" index:1 colorCodeIndex:1 userCount:2 accessEmailIDs:accessEmailIDs_1 isExpanded:YES ownerEmailID:@"masood.pathan@securifi.com" linkType:0];
            
            NSMutableArray* accessEmailIDs_2 = [NSMutableArray arrayWithObjects:@"masood.pathan@securifi.com", @"masood@securifi.com", nil];
            SFIAlmondPlus *plus2 = [commandObj createAlmondPlusWithAlmondPlusName:@"almondplus_2" almondPlusMAC:@"123456789123456" index:2 colorCodeIndex:2 userCount:2 accessEmailIDs:accessEmailIDs_2 isExpanded:NO ownerEmailID:@"masood.pathan@securifi.com" linkType:0];
            NSMutableArray *list=[[NSMutableArray alloc]initWithObjects:plus1,plus2, nil];
            AlmondListResponse *almondListResponse;
            if([[commandObj.trueResponseDict valueForKey:@"ALMOND_LIST"] intValue]){
                almondListResponse = [commandObj almondListResponseWithAction:@"add" deviceCount:(int)[list count] almondPlusMACList:list isSuccessful:YES reason:@"success"];
            }else{
                almondListResponse = [commandObj almondListResponseWithAction:@"add" deviceCount:(int)[list count] almondPlusMACList:list isSuccessful:NO reason:@"failed"];
            }
            [dc callDummyCloud:almondListResponse commandType:CommandType_ALMOND_LIST_RESPONSE];
            break;
        }
        case CommandType_DEVICE_DATA_HASH:{
            NSLog(@"device data hash");
            DeviceDataHashResponse *response;
            if([[commandObj.trueResponseDict valueForKey:@"DEVICE_DATA_HASH"] intValue]){
                response =[commandObj deviceDataHashResponseWithAlmondHash:@"" isSuccessful:YES reason:@"success"];
            }else{
                response =[commandObj deviceDataHashResponseWithAlmondHash:@"" isSuccessful:NO reason:@"failed"];
            }
            [dc callDummyCloud:response commandType:CommandType_DEVICE_DATA_HASH_RESPONSE];
            break;
        }
        case CommandType_DEVICE_DATA:{
            NSLog(@" mockcloud.m -> CommandType_DEVICE_DATA ");
            
            NSMutableArray *Listarray = [commandObj addDeviceData];
            DeviceListResponse *devicelist;
            if([[commandObj.trueResponseDict valueForKey:@"DEVICE_DATA"] intValue]){
                devicelist = [commandObj deviceListResponseWithAlmondMAC:@"251176217041064" deviceCount:(unsigned int)[Listarray count] deviceList:Listarray isSuccessful:YES reason:@"success"];
            }else{
                devicelist = [commandObj deviceListResponseWithAlmondMAC:@"251176217041064" deviceCount:(unsigned int)[Listarray count] deviceList:Listarray isSuccessful:NO reason:@"failed"];
            }
            [dc callDummyCloud:devicelist commandType:CommandType_DEVICE_DATA_RESPONSE];
            break;
        }
        case CommandType_DEVICE_VALUE:{
            NSLog(@"CommandType_DEVICE_VALUE");
            NSMutableArray *deviceValueArray = [commandObj addDeviceValues];
            //device response
            DeviceValueResponse *devicevalueresponse;
            if([[commandObj.trueResponseDict valueForKey:@"DEVICE_VALUE"] intValue]){
                devicevalueresponse = [commandObj deviceValueResponseWithAlmondMAC:@"251176217041064" deviceCount:(int)[deviceValueArray count] deviceValueList:deviceValueArray isSuccessful:YES reason:@"success"];
            }else{
                devicevalueresponse = [commandObj deviceValueResponseWithAlmondMAC:@"251176217041064" deviceCount:(int)[deviceValueArray count] deviceValueList:deviceValueArray isSuccessful:NO reason:@"failed"];
            }
            [dc callDummyCloud:devicevalueresponse commandType:CommandType_DEVICE_VALUE_LIST_RESPONSE];
            break;
        }
        case CommandType_MOBILE_COMMAND:{
            NSLog(@"mockcloud.m -> CommandType_MOBILE_COMMAND");
            Class class = cmd.command;
            //mobilecommandrequest + dynamic value
            if([class isKindOfClass:[MobileCommandRequest class]]){
                NSLog(@"MobileCommandRequest");
                MobileCommandRequest *mobilerequest=cmd.command;

                MobileCommandResponse *mobileresponse;
                if([[commandObj.trueResponseDict valueForKey:@"MOBILE_COMMAND"] intValue]){
                    mobileresponse=[commandObj mobileCommandRespWithisSuccessful:YES reason:@"success" mobileInternalIndex:mobilerequest.correlationId];
                }else{
                    mobileresponse=[commandObj mobileCommandRespWithisSuccessful:NO reason:@"failed" mobileInternalIndex:mobilerequest.correlationId];
                }
                [dc callDummyCloud:mobileresponse commandType:CommandType_MOBILE_COMMAND_RESPONSE];
                
                NSMutableArray *arr = [commandObj dynamicDeviceValueUpdate:mobilerequest];
                
                DeviceValueResponse *devicevalueresponse;
                if([[commandObj.trueResponseDict valueForKey:@"MOBILE_COMMAND_Dynamic"] intValue]){
                    devicevalueresponse = [commandObj deviceValueResponseWithAlmondMAC:@"251176217041064" deviceCount:(int)[arr count] deviceValueList:arr isSuccessful:YES reason:@"success"];
                }else{
                    devicevalueresponse = [commandObj deviceValueResponseWithAlmondMAC:@"251176217041064" deviceCount:(int)[arr count] deviceValueList:arr isSuccessful:NO reason:@"failed"];
                }
                [dc callDummyCloud:devicevalueresponse commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
            }
            //almond name change
            if([class isKindOfClass:[AlmondNameChange class]]){
                NSLog(@"AlmondNameChange");
                AlmondNameChange *namechange=cmd.command;
                AlmondNameChangeResponse *namechangeresp;
                if([[commandObj.trueResponseDict valueForKey:@"MOBILE_COMMAND_AlmondNameChange"] intValue]){
                    namechangeresp=[commandObj almondNameChangeResponseWithinternalIndex:[NSString stringWithFormat:@"%d",namechange.correlationId] isSuccessful:YES];
                }else{
                    namechangeresp=[commandObj almondNameChangeResponseWithinternalIndex:[NSString stringWithFormat:@"%d",namechange.correlationId] isSuccessful:NO];
                }

                [dc callDummyCloud:namechangeresp commandType:CommandType_ALMOND_NAME_CHANGE_RESPONSE];
            }
            //sensor name and location change request
            if([class isKindOfClass:[SensorChangeRequest class]]){
                NSLog(@"SensorChangeRequest");
                SensorChangeRequest *sensorRequest = cmd.command;
                unsigned int mii = sensorRequest.correlationId;
                SensorChangeResponse *sensorResponse;
                if([[commandObj.trueResponseDict valueForKey:@"MOBILE_COMMAND_SensorChangeRequest"] intValue]){
                    sensorResponse = [commandObj sensorChangeResponseWithinternalIndex:mii isSuccessful:YES];
                }else{
                    sensorResponse = [commandObj sensorChangeResponseWithinternalIndex:mii isSuccessful:NO];
                }

                [dc callDummyCloud:sensorResponse commandType:CommandType_SENSOR_CHANGE_RESPONSE];
            }
            if([class isKindOfClass:[AlmondModeChangeRequest class]]){
                AlmondModeChangeResponse *modechange;
                if([[commandObj.trueResponseDict valueForKey:@"MOBILE_COMMAND_AlmondModeChangeRequest"] intValue]){
                    modechange=[commandObj almondModeChangeResponseWithReason:@"success" reasonCode:0 isSuccessful:YES];
                }else{
                    modechange=[commandObj almondModeChangeResponseWithReason:@"failed" reasonCode:1 isSuccessful:NO];
                }
                [dc callDummyCloud:modechange commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
            }
            
            NSLog(@"Mobile_Command break");
            break;
        } // mobile command end
            
        case CommandType_CLOUD_SANITY:{
            NSLog(@"cloud_sanity");
            GenericCommandResponse *genericResp=[[GenericCommandResponse alloc]init];
            if([[commandObj.trueResponseDict valueForKey:@"CLOUD_SANITY"] intValue]){
                genericResp.isSuccessful=YES;
            }else{
                genericResp.isSuccessful=NO;
            }

            break;
        }
        case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:{
            NSLog(@"notification preference list");
            SFINotificationDevice *notificaitonDev = [commandObj notificationDeviceWithDeviceID:1 valueIndex:1 notificationMode:SFINotificationMode_always];
            
            NSMutableArray *notificationDeviceArray =[[NSMutableArray alloc]init];
            [notificationDeviceArray addObject:notificaitonDev];
            SFINotificationUser *notificationUser = [commandObj notificationUserWithUserID:@"1234" preferenceCount:2 notificationDeviceList:notificationDeviceArray];
            
            NotificationPreferenceListResponse *notificationPreferenceResponse;
            if([[commandObj.trueResponseDict valueForKey:@"NOTIFICATION_PREFERENCE_LIST_REQUEST"] intValue]){
                notificationPreferenceResponse = [commandObj notificationPreferenceListResponseWithAlmondMAC:@"251176217041064" reason:@"success" reasonCode:0 isSuccessful:YES preferenceCount:2 notificationUser:notificationUser notificationDeviceList:notificationDeviceArray];
            }else{
                notificationPreferenceResponse = [commandObj notificationPreferenceListResponseWithAlmondMAC:@"251176217041064" reason:@"failed" reasonCode:1 isSuccessful:NO preferenceCount:2 notificationUser:notificationUser notificationDeviceList:notificationDeviceArray];
            }

            [dc callDummyCloud:notificationPreferenceResponse commandType:CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE];
            break;
        }
        case CommandType_GENERIC_COMMAND_REQUEST:{
            NSLog(@"generic command request");
            GenericCommandRequest *genericcommand=cmd.command;
            NSString *dataIncomming = genericcommand.data;
  
            NSString *base64String = [commandObj encodeGenericData:dataIncomming];
            GenericCommandResponse *genericcommandresponse;
            if([[commandObj.trueResponseDict valueForKey:@"GENERIC_COMMAND_REQUEST"] intValue]){
                genericcommandresponse=[commandObj genericCommandResponseWithAlmondMAC:@"251176217041064" reason:@"success" mobileInternalIndex:genericcommand.correlationId isSuccessful:YES applicationID:genericcommand.applicationID genericData:base64String];
            }else{
                genericcommandresponse=[commandObj genericCommandResponseWithAlmondMAC:@"251176217041064" reason:@"failed" mobileInternalIndex:genericcommand.correlationId isSuccessful:NO applicationID:genericcommand.applicationID genericData:base64String];
            }

            [dc callDummyCloud:genericcommandresponse commandType:CommandType_GENERIC_COMMAND_RESPONSE];
            break;
        }
        //not for now
        case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:{
            NSLog(@"mockcloud.m -> CommandType_NOTIFICATION_PREF_CHANGE_REQUEST");
            break;
        }

        case CommandType_NOTIFICATION_REGISTRATION:{
            NSLog(@"notification reg req");
            NotificationRegistrationResponse *notifiregistration;
            if([[commandObj.trueResponseDict valueForKey:@"NOTIFICATION_REGISTRATION"] intValue]){
                notifiregistration = [commandObj notificationRegistrationResponseWithisSuccessful:YES reasonCode:0 reason:@"success"];
            }else{
                notifiregistration = [commandObj notificationRegistrationResponseWithisSuccessful:NO reasonCode:1 reason:@"failed"];
            }
            [dc callDummyCloud:notifiregistration commandType:CommandType_NOTIFICATION_REGISTRATION_RESPONSE];
            break;
        }
        case CommandType_NOTIFICATION_DEREGISTRATION:{
            NotificationDeleteRegistrationResponse *notifideregi;
            if([[commandObj.trueResponseDict valueForKey:@"NOTIFICATION_DEREGISTRATION"] intValue]){
                notifideregi = [commandObj notificationDeleteRegistrationResponseWithisSuccessful:YES reasonCode:0 reason:@"success"];
            }else{
                notifideregi = [commandObj notificationDeleteRegistrationResponseWithisSuccessful:NO reasonCode:1 reason:@"failed"];
            }
            [dc callDummyCloud:notifideregi commandType:CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE];
            break;
        }
            
        case CommandType_ALMOND_MODE_REQUEST:{
            NSLog(@"Almond mode request ");
            AlmondModeResponse *almond;
            if([[commandObj.trueResponseDict valueForKey:@"ALMOND_MODE_REQUEST"] intValue]){
                almond=[commandObj almondModeResponseForUserId:@"masood.pathan@securifi.com" AlmondMAC:@"251176217041064" success:YES reasonCode:0 reason:@"success" mode:2];
            }else{
                almond=[commandObj almondModeResponseForUserId:@"masood.pathan@securifi.com" AlmondMAC:@"251176217041064" success:NO reasonCode:1 reason:@"failed" mode:2];
            }

            [dc callDummyCloud:almond commandType:CommandType_ALMOND_MODE_RESPONSE];
            break;
        }
        case CommandType_NOTIFICATIONS_SYNC_REQUEST:{
            break;
        }
        case CommandType_DEVICELOG_REQUEST:{
            NSLog(@"CommandType_DEVICELOG_REQUEST");
            NSData *data = [NSData new];
            data = cmd.command;

            // not receiving root element;
            NSString *jsonInput = @"{\"pageState\":\"000000260008\",\"requestId\":\"251176217041064\",\"logs\":[{\"mac\":\"251176217041064\",\"pk\":\"e6180b90-4741-11e5-bfa4-79e91b0c3501\",\"device_id\":\"1\",\"device_name\":\"SWITCH MULTILEVEL\",\"device_type\":2,\"index_id\":1,\"index_name\":\"AWAY_MODE\",\"time\":\"1440078765705\",\"value\":\"home\"},{\"mac\":\"251176217041064\",\"pk\":\"ef7f3f30-4739-11e5-bfa4-79e91b0c3501\",\"device_id\":\"1\",\"device_name\":\"SWITCH MULTILEVEL\",\"device_type\":2,\"index_id\":2,\"index_name\":\"AWAY_MODE\",\"time\":\"1440075345446\",\"value\":\"away\"}]}";
            NSData *logsData = [jsonInput dataUsingEncoding:NSUTF8StringEncoding];
            NotificationListResponse *notificationListResponse = [[NotificationListResponse alloc] init];
            notificationListResponse = [NotificationListResponse parseDeviceLogsJson:logsData];
            [dc callDummyCloud:notificationListResponse commandType:CommandType_DEVICELOG_RESPONSE];
            break;
        }
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:{
            NSLog(@"CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST");
            
            break;
        }
        case CommandType_UPDATE_REQUEST:{
            NSLog(@"update request");
    
            NSData *jsondata = [cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary * mainDict = [jsondata objectFromJSONData];
            NSString *requestType =  [mainDict valueForKey:@"CommandType"];
            NSInteger mii = [[mainDict valueForKey:@"MobileInternalIndex"] integerValue];
            
            NSLog(@"main dict update: %@", mainDict);
            NSData *DynamicSceneResponseData;
            if([requestType isEqualToString:@"SetScene"]){
                NSLog(@"set scene cloud");
                NSString *setSceneResponse;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_SetScene"] intValue]){
                    setSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"SET_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\" ,\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    setSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"SET_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"false\" ,\"ReasonCode\":\"1\"}", (long)mii];
                }
                NSData *setSceneResponseData = [setSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:setSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                NSLog(@"dynamic set update scene");
                DynamicSceneResponseData = [commandObj encodeDynamicUpdateSceneWithDict:mainDict];
                
            }
            
            else if([requestType isEqualToString:@"CreateScene"]){
                NSLog(@"cloud create scene");
                NSString *createSceneResponse;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_CreateScene"] intValue]){
                    createSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"CREATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    createSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"CREATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"false\",\"ReasonCode\":\"1\"}", (long)mii];
                }
                NSData *createSceneResponseData = [createSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:createSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                NSLog(@"dynamic create update scene");
                DynamicSceneResponseData = [commandObj encodeDynamicCreateSceneWithDict:mainDict];
            }
            
            else if([requestType isEqualToString:@"DeleteScene"]){
                NSLog(@"delete scene");
                NSString *deleteSceneResponse;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_DeleteScene"] intValue]){
                    deleteSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"DELETE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    deleteSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"DELETE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"false\",\"ReasonCode\":\"1\"}", (long)mii];
                }
                NSData *deleteSceneResponseData = [deleteSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:deleteSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                NSLog(@"dynamic delete");
                DynamicSceneResponseData = [commandObj encodeDynamicDeleteSceneWithDict:mainDict];
                

            }
            
            else if([requestType isEqualToString:@"ActivateScene"]){
                NSLog(@"activate scene");
                NSString *activateSceneResponse;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_ActivateScene"] intValue]){
                    activateSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"ACTIVATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    activateSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"ACTIVATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"false\",\"ReasonCode\":\"1\"}", (long)mii];
                }
                NSData *activateSceneResponseData = [activateSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:activateSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                NSLog(@"dynamic activate scene");
                DynamicSceneResponseData = [commandObj encodeDynamicActivateSceneWithDict:mainDict];
            }
            if([[commandObj.trueResponseDict valueForKey:@"DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE"] intValue]){
                [dc callDummyCloud:DynamicSceneResponseData commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
            }else{
                //do nothing, dynamic update does not have success param.
            }
            
            //add wifi update requests
            if ([requestType isEqualToString:@"UpdateClient"]){
                NSLog(@"wifi update client");
                NSString *updateClient;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_UpdateClient"] intValue]){
                    updateClient = [NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileCommandResponse\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    updateClient = [NSString stringWithFormat:@"{\"Success\":\"false\",\"MobileCommandResponse\":\"false\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"1\"}", (long)mii];
                }

                NSData *updateClientResponseData = [updateClient dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:updateClientResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                //dynamic update
                NSData *dynamicData = [commandObj encodeUpdateClientWithDict:mainDict];
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_UpdateClient_Dynamic"] intValue]){
                    [dc callDummyCloud:dynamicData commandType:CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST];
                }else{
                    //do nothing
                }
            }
            
            else if ([requestType isEqualToString:@"RemoveClient"]){
                //
                NSLog(@"wifi remove client");
                NSString *removeClient;
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_RemoveClient"] intValue]){
                    removeClient = [NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileCommandResponse\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}", (long)mii];
                }else{
                    removeClient = [NSString stringWithFormat:@"{\"Success\":\"false\",\"MobileCommandResponse\":\"false\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"1\"}", (long)mii];
                }
                NSData *removeClientResponseData = [removeClient dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:removeClientResponseData commandType:CommandType_COMMAND_RESPONSE];
                
                NSLog(@"dynamic client remove");
                // Main dict would send only one client to remove
                NSData *dynamicData = [commandObj encodeRemoveClientWithDict:mainDict];
                if([[commandObj.trueResponseDict valueForKey:@"UPDATE_REQUEST_RemoveClient_Dynamic"] intValue]){
                    [dc callDummyCloud:dynamicData commandType:CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST];
                }else{
                    //do nothing
                }
            }
            break;
        }
            
        case CommandType_GET_ALL_SCENES:{
            NSLog(@"get all scenes");
            NSLog(@"command: %@", cmd.command);
            NSString *getAllSceneRequestJSON;
            if([[commandObj.trueResponseDict valueForKey:@"GET_ALL_SCENES"] intValue]){
                getAllSceneRequestJSON = @"{\"AlmondplusMAC\":\"251176217041064\",\"MobileCommand\":\"LIST_SCENE_RESPONSE\",\"Success\":\"true\",\"Scenes\":[{\"Active\":\"false\",\"ID\":\"1\",\"SceneName\":\"First Scene\",\"SceneEntryList\":[]},{\"Active\":\"true\",\"ID\":\"10\",\"SceneName\":\"Scene10\",\"SceneEntryList\":[]},{\"ID\":\"1022\",\"Active\":\"true\",\"SceneName\":\"Scene1022\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\"}]}]}";
            }else{
                getAllSceneRequestJSON = @"{\"AlmondplusMAC\":\"251176217041064\",\"MobileCommand\":\"LIST_SCENE_RESPONSE\",\"Success\":\"false\",\"Scenes\":[{\"Active\":\"false\",\"ID\":\"1\",\"SceneName\":\"First Scene\",\"SceneEntryList\":[]},{\"Active\":\"true\",\"ID\":\"10\",\"SceneName\":\"Scene10\",\"SceneEntryList\":[]},{\"ID\":\"1022\",\"Active\":\"true\",\"SceneName\":\"Scene1022\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\"}]}]}";
            }
            NSData *jsondata = [getAllSceneRequestJSON dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:jsondata commandType:CommandType_LIST_SCENE_RESPONSE];
            break;
        }
            
        case CommandType_WIFI_CLIENTS_LIST_REQUEST:{
            NSLog(@"wifi client list request");
            NSData *da1=[cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict1=[da1 objectFromJSONData];
            NSInteger mii=[[dict1 valueForKey:@"MobileInternalIndex"]integerValue];
            NSLog(@"MobileInternalIndex %ld",(long)mii);
            NSString *wificlientdata;
            if([[commandObj.trueResponseDict valueForKey:@"WIFI_CLIENTS_LIST_REQUEST"] intValue]){
                wificlientdata=[NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\",\"Clients\":[{\"ID\":\"1\",\"Name\":\"device1\",\"Connection\":\"wired\",\"MAC\":\"mac1\",\"Type\":\"TV\",\"LastKnownIP\":\"10.2.2.11\",\"Active\":\"true\",\"UseAsPresence\":\"false\"}]}",(long)mii];
            }else{
                wificlientdata=[NSString stringWithFormat:@"{\"Success\":\"false\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\",\"Clients\":[{\"ID\":\"1\",\"Name\":\"device1\",\"Connection\":\"wired\",\"MAC\":\"mac1\",\"Type\":\"TV\",\"LastKnownIP\":\"10.2.2.11\",\"Active\":\"true\",\"UseAsPresence\":\"false\"}]}",(long)mii];
            }
            NSData *wificlientdarta=[wificlientdata dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:wificlientdarta commandType:CommandType_WIFI_CLIENTS_LIST_RESPONSE];
            break;
        }
            
        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:{
            NSData *da1=[cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict1=[da1 objectFromJSONData];
            NSInteger internalIndex=[[dict1 valueForKey:@"MobileInternalIndex"]integerValue];
            
            NSString *wificlientupdate;
            if([[commandObj.trueResponseDict valueForKey:@"WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST"] intValue]){
                wificlientupdate=[NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}",(long)internalIndex];
            }else{
                wificlientupdate=[NSString stringWithFormat:@"{\"Success\":\"false\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"1\"}",(long)internalIndex];
            }
            NSData *wificlientupdate_data=[wificlientupdate dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:wificlientupdate_data commandType:CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST];
  
            break;
        }
            
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:{
            NSString *getwifi_prefernce;
            if([[commandObj.trueResponseDict valueForKey:@"WIFI_CLIENT_GET_PREFERENCE_REQUEST"] intValue]){
                getwifi_prefernce=@"{\"Success\":\"true\",\"ReasonCode\":\"0\",\"ClientPreferences\":[{\"ClientID\":1,\"NotificationType\":2}]}";
            }else{
                getwifi_prefernce=@"{\"Success\":\"false\",\"ReasonCode\":\"1\",\"ClientPreferences\":[{\"ClientID\":1,\"NotificationType\":2}]}";
            }
            NSData *getwifipreference=[getwifi_prefernce dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:getwifipreference commandType:CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST];
            

            break;
        }
        default:
            break;
    }
    
}
@end
