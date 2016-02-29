
//
//  MockCloud.m
//  SecurifiApp
//
//  Created by Masood on 06/08/15.
//  Copyright (c) 2015 Securifi Ltd. All rights reserved.
//





#import "MockCloud.h"
//#import "SensorChangeRequest"
#import "SensorChangeResponse.h"
#import "LoginTempPass.h"
#import "Login/Login.h"
#import "LoginResponse.h"
#import "CloudEndpoint.h"
#import "dummyCloudEndpoint.h"
#import "Network.h"
#import "AlmondNameChange.h"
#import "AlmondListResponse.h"
#import "AlmondListRequest.h"
#import "SFIAlmondPlus.h"
#import "DeviceDataHashResponse.h"
#import "DeviceListResponse.m"
#import "DeviceValueResponse.h"
#import "SFIDeviceValue.h"
#import "DeviceListResponse.h"
#import "DeviceListRequest.h"
#import "UserProfileResponse.m"
#import "UnlinkAlmondResponse.h"

#import "NotificationPreferenceListRequest.h"
#import "ChangePasswordResponse.h"
#import "AffiliationUserComplete.h"
#import "LogoutAllResponse.h"
#import "AlmondListResponse.h"
#import "DeviceDataHashResponse.h"
#import "SFIAlmondPlus.h"
#import "ValidateAccountResponse.h"
#import "SensorChangeResponse.h"
#import "AlmondAffiliationDataResponse.h"
#import "NotificationPreferenceListResponse.h"
#import "SFINotificationUser.h"
#import "MobileCommandResponse.h"
#import "GenericCommandResponse.h"
#import "NotificationDeleteRegistrationResponse.h"
#import "NotificationRegistrationResponse.h"
#import "NotificationListResponse.h"
#import "SFINotification.h"
#import "NotificationCountResponse.h"
#import "GenericCommandResponse.h"
#import "NotificationPreferences.h"
#import "NotificationPreferenceResponse.h"
#import "SFIDeviceKnownValues.h"
#import "SFINotificationDevice.h"
#import "SensorChangeRequest.h"
#import "AlmondModeChangeResponse.h"
#import "AlmondModeResponse.h"
#import "AlmondModeRequest.h"
#import "DynamicAlmondModeChange.h"
#import "DeviceValueRequest.h"
#import "AlmondNameChange.h"
#import "AlmondNameChangeResponse.h"
#import "DynamicAlmondNameChangeResponse.h"
#import "ResetPasswordRequest.h"
#import "ResetPasswordResponse.h"
#import "GenericCommandRequest.h"
#import "LogoutResponse.h"
#import "NotificationPreferenceListResponse.h"
#import "NotificationClearCountResponse.h"
#import "NotificationListResponse.h"
#import "MeAsSecondaryUserResponse.h"
#import "UserInviteResponse.h"
#import "UserInviteRequest.h"
#import "DeleteAccountResponse.h"
#import "DeleteMeAsSecondaryUserResponse.h"
#import "DeleteMeAsSecondaryUserRequest.h"
#import "DeleteSecondaryUserResponse.h"
#import "DeleteSecondaryUserRequest.h"
#import "AlmondModeResponse.h"
//#import "DeviceDataForcedUpdateRequest.h"
#import "AlmondModeChangeResponse.h"
#import "AlmondModeChangeRequest.h"
#import "UpdateUserProfileResponse.h"
#import "UpdateUserProfileRequest.h"
#import "NotificationListResponse.h"
#import "MDJSON.h"
@interface MockCloud()

@property(nonatomic,strong)DeviceListResponse *devicelist_p;
@property(nonatomic ,strong)NSArray *devicearr_p;
@property(nonatomic,strong)SFIDevice *device_p;
@property(nonatomic ,strong)SFIDeviceKnownValues *knownvalue_p;
@property(nonatomic,strong)SFIDeviceValue *devicevalue_p;

@end

@implementation MockCloud


SFIDeviceValue *devicevalue;
- (void) sendToMockCloud:(GenericCommand *)cmd{
    unsigned int command_type = cmd.commandType;
    NSLog(@"**** In mock cloud commandtype: %d ***** ", command_type);
    dummyCloudEndpoint *dc = [[dummyCloudEndpoint alloc] init];
    Network *network = [[Network alloc] init];
    dc.delegate = network;

    
    switch (command_type)
    {//switch
            
        case CommandType_LOGIN_COMMAND:{
         
            LoginResponse *loginResponse = [[LoginResponse alloc] init];
            loginResponse.userID = @"shailesh.shah@securifi.com";
            loginResponse.tempPass = @"rushabh@21";
            loginResponse.reason = @"success";
            loginResponse.reasonCode = 1;
            loginResponse.isSuccessful = YES;
            
            LoginTempPass *temp=[[LoginTempPass alloc]init];
            temp.UserID= @"shailesh.shah@securifi.com";
            temp.TempPass=@"rushabh@21";
            // there are two more properties, already initialized in loginresponse constructor

            [dc callDummyCloud:loginResponse commandType:CommandType_LOGIN_RESPONSE];
     
            break;
        }//
            
        case CommandType_ALMOND_MODE_REQUEST:{
            
            
                        AlmondModeResponse *almode=[[AlmondModeResponse alloc]init];
                        almode.success=true;
                        almode.userId=@"shailesh.shah@securifi.com";
                        almode.almondMAC=@"1234543210987890";
                        almode.reasonCode=1;
                        almode.reason=@"success";
                        almode.mode=2;
                       [dc callDummyCloud:almode commandType:CommandType_ALMOND_MODE_RESPONSE];
            
            break;
        }
            
        case CommandType_LOGOUT_COMMAND:{
            
            LoginResponse *logoutresp=[[LoginResponse alloc]init];
            logoutresp.isSuccessful=true;
            logoutresp.userID=@"shailesh.shah@securifi.com";
            logoutresp.tempPass=@"rushabh@21";
            logoutresp.reason=@"logout success";
            logoutresp.reasonCode=1;
            logoutresp.isAccountActivated=true;
            logoutresp.minsRemainingForUnactivatedAccount=2;
           
            [dc callDummyCloud:logoutresp commandType:CommandType_LOGIN_RESPONSE];
            
            break;
        
        }//
        case CommandType_LOGOUT_ALL_COMMAND:{
            
            NSLog(@"in logout command case");
            LogoutAllResponse *logoutresponse=[[LogoutAllResponse alloc]init];
            // loginresponse.isAccessibilityElement=YES;
            logoutresponse.isSuccessful=YES;
            logoutresponse.reason=@"success";
            logoutresponse.reasonCode=1;
                        [dc callDummyCloud:logoutresponse commandType:CommandType_LOGOUT_ALL_RESPONSE];
            break;
        }//
        case CommandType_SIGNUP_COMMAND:{
        
        }//
        case CommandType_VALIDATE_REQUEST:{
            ValidateAccountResponse *validate=[[ValidateAccountResponse alloc]init];
            validate.isSuccessful=YES;
            validate.reasonCode=2;
            validate.reason=@"success";
                        [dc callDummyCloud:validate commandType:CommandType_VALIDATE_RESPONSE];
            
        }//
        case CommandType_RESET_PASSWORD_REQUEST:{
            
            ResetPasswordResponse *reset=[[ResetPasswordResponse alloc]init];
            reset.isSuccessful=YES;
            reset.reason=@"success";
            reset.reasonCode=1;
            [dc callDummyCloud:reset commandType:CommandType_RESET_PASSWORD_RESPONSE];
            break;
            
        }//
        case CommandType_AFFILIATION_CODE_REQUEST:{
            AffiliationUserComplete *usercomplete=[[AffiliationUserComplete alloc]init];
            usercomplete.almondplusName=@"Alm+";
            usercomplete.almondplusMAC=@"1234543210987890";
            usercomplete.reason=@"success";
            usercomplete.isSuccessful=YES;
            usercomplete.wifiSSID=@"www,abc";
            usercomplete.wifiPassword=@"Hyderabad";
            usercomplete.reasonCode=1;
            
            [dc callDummyCloud:usercomplete commandType:CommandType_AFFILIATION_USER_COMPLETE];
            break;
        }//
        case CommandType_ALMOND_LIST: {
           
            AlmondListRequest *ALR = [[AlmondListRequest alloc] init];
            AlmondListResponse *almlistres=[[AlmondListResponse alloc]init];
            SFIAlmondPlus *plus=[[SFIAlmondPlus alloc]init];
            plus.almondplusMAC=@"1234543210987890";
            plus.almondplusName=@"Alm";
            // plus.accessEmailIDs=@"masood.pathan@securifi.com";
            plus.userCount=2;
            NSMutableArray *list=[[NSMutableArray alloc]initWithObjects:plus, nil];
            almlistres.isSuccessful=YES;
            almlistres.deviceCount=1;
            almlistres.reason=@"success";
            almlistres.almondPlusMACList=list;
            almlistres.action=@"add";
            
            [dc callDummyCloud:almlistres commandType:CommandType_ALMOND_LIST_RESPONSE];
            break;
            
        }//
            
            //r
        case CommandType_DEVICE_DATA_HASH:{
            DeviceDataHashResponse *response =[[DeviceDataHashResponse alloc ]init];
            response.isSuccessful=YES;
            response.almondHash=@"almond";
            response.reason=@"success";
            [dc callDummyCloud:response commandType:CommandType_DEVICE_DATA_HASH_RESPONSE];
            break;
        }//
        case CommandType_DEVICE_DATA:{
            DeviceListResponse *devicelist=[[DeviceListResponse alloc]init];
            NSMutableArray *Listarray=[[NSMutableArray alloc]init];
            
            SFIDevice *device=[[SFIDevice alloc]init];
            device.deviceType=SFIDeviceType_MultiLevelSwitch_2;
            device.deviceID=1;
            device.OZWNode=@"abc";
            device.zigBeeEUI64=@"123";
            device.zigBeeShortID=@"32";
            device.deviceTechnology=2;
            device.associationTimestamp=@"21";
            device.deviceTechnology=2;
            device.notificationMode=1;
            device.almondMAC=@"1234543210987890";
            device.allowNotification=@"yes";
            device.location=@"home";
            device.valueCount=1;
            device.deviceFunction=@"switch";
            device.deviceTypeName=@"STATE";
            device.friendlyDeviceType=@"zeewave";
            device.deviceName=@"SWITCH MULTILEVEL";
            
            SFIDevice *device1=[[SFIDevice alloc]init];
            device1.deviceType=SFIDeviceType_BinarySensor_3;
            device1.deviceID=2;
            device1.OZWNode=@"abc";
            device1.zigBeeEUI64=@"123";
            device1.zigBeeShortID=@"32";
            device1.deviceTechnology=1;
            device1.associationTimestamp=@"21";
            //device1.deviceTechnology=2;
            device1.notificationMode=1;
            device1.almondMAC=@"1234543210987890";
            device1.allowNotification=@"yes";
            device1.location=@"home";
            device1.valueCount=2;
            device1.deviceFunction=@"switch";
            device1.deviceTypeName=@"STATE";
            device1.friendlyDeviceType=@"zeewave";
            device1.deviceName=@"Z-wave Door Sensor";
            
            
            SFIDevice *device2=[[SFIDevice alloc]init];
            device2.deviceType=SFIDeviceType_TemperatureSensor_27;
            device2.deviceID=3;
            device2.OZWNode=@"abc";
            device2.zigBeeEUI64=@"123";
            device2.zigBeeShortID=@"32";
            device2.deviceTechnology=2;
            device2.associationTimestamp=@"21";
            device2.deviceTechnology=2;
            device2.notificationMode=1;
            device2.almondMAC=@"1234543210987890";
            device2.allowNotification=@"yes";
            device2.location=@"home";
            device2.valueCount=1;
            device2.deviceFunction=@"switch";
            device2.deviceTypeName=@"STATE";
            device2.friendlyDeviceType=@"zeewave";
            device2.deviceName=@"Temperature Sensor";
            
            
            SFIDevice *device4=[[SFIDevice alloc]init];
            device4.deviceType=SFIDeviceType_ColorControl_29;
            device4.deviceID=5;
            device4.OZWNode=@"abc";
            device4.zigBeeEUI64=@"123";
            device4.zigBeeShortID=@"32";
            device4.deviceTechnology=2;
            device4.associationTimestamp=@"21";
            device4.deviceTechnology=2;
            device4.notificationMode=1;
            device4.almondMAC=@"1234543210987890";
            device4.allowNotification=@"yes";
            device4.location=@"home";
            device4.valueCount=1;
            device4.deviceFunction=@"switch";
            device4.deviceTypeName=@"STATE";
            device4.friendlyDeviceType=@"zeewave";
            device4.deviceName=@"colour control";
            
            
            SFIDevice *device3=[[SFIDevice alloc]init];
            device3.deviceType=SFIDeviceType_Thermostat_7;
            device3.deviceID=4;
            device3.OZWNode=@"abc";
            device3.zigBeeEUI64=@"123";
            device3.zigBeeShortID=@"32";
            device3.deviceTechnology=2;
            device3.associationTimestamp=@"21";
            device3.deviceTechnology=2;
            device3.notificationMode=1;
            device3.almondMAC=@"1234543210987890";
            device3.allowNotification=@"yes";
            device3.location=@"home";
            device3.valueCount=1;
            device3.deviceFunction=@"switch";
            device3.deviceTypeName=@"STATE";
            device3.friendlyDeviceType=@"zeewave";
            device3.deviceName=@"Tharmosat";
            
            
            SFIDevice *device_zigbeedoor=[[SFIDevice alloc]init];
            device_zigbeedoor.deviceType=SFIDeviceType_ZigbeeDoorLock_28;
            device_zigbeedoor.deviceID=6;
            device_zigbeedoor.OZWNode=@"abc";
            device_zigbeedoor.zigBeeEUI64=@"123";
            device_zigbeedoor.zigBeeShortID=@"32";
            device_zigbeedoor.deviceTechnology=2;
            device_zigbeedoor.associationTimestamp=@"21";
            device_zigbeedoor.deviceTechnology=2;
            device_zigbeedoor.notificationMode=1;
            device_zigbeedoor.almondMAC=@"1234543210987890";
            device_zigbeedoor.allowNotification=@"yes";
            device_zigbeedoor.location=@"home";
            device_zigbeedoor.valueCount=1;
            device_zigbeedoor.deviceFunction=@"switch";
            device_zigbeedoor.deviceTypeName=@"STATE";
            device_zigbeedoor.friendlyDeviceType=@"zeewave";
            device_zigbeedoor.deviceName=@"Zigbee door lock";

            
            
            SFIDevice *device_lightsensor=[[SFIDevice alloc]init];
            device_lightsensor.deviceType=SFIDevicePropertyType_ILLUMINANCE;
            device_lightsensor.deviceID=7;
            device_lightsensor.OZWNode=@"abc";
            device_lightsensor.zigBeeEUI64=@"123";
            device_lightsensor.zigBeeShortID=@"32";
            device_lightsensor.deviceTechnology=2;
            device_lightsensor.associationTimestamp=@"21";
            device_lightsensor.deviceTechnology=2;
            device_lightsensor.notificationMode=1;
            device_lightsensor.almondMAC=@"1234543210987890";
            device_lightsensor.allowNotification=@"yes";
            device_lightsensor.location=@"home";
            device_lightsensor.valueCount=1;
            device_lightsensor.deviceFunction=@"switch";
            device_lightsensor.deviceTypeName=@"STATE";
            device_lightsensor.friendlyDeviceType=@"zeewave";
            device_lightsensor.deviceName=@"Light sensor";

            
            
            SFIDevice *device_keyboard=[[SFIDevice alloc]init];
            device_keyboard.deviceType=SFIDeviceType_Keypad_20;
            device_keyboard.deviceID=8;
            device_keyboard.OZWNode=@"abc";
            device_keyboard.zigBeeEUI64=@"123";
            device_keyboard.zigBeeShortID=@"32";
            device_keyboard.deviceTechnology=2;
            device_keyboard.associationTimestamp=@"21";
            device_keyboard.deviceTechnology=2;
            device_keyboard.notificationMode=1;
            device_keyboard.almondMAC=@"1234543210987890";
            device_keyboard.allowNotification=@"yes";
            device_keyboard.location=@"home";
            device_keyboard.valueCount=1;
            device_keyboard.deviceFunction=@"switch";
            device_keyboard.deviceTypeName=@"STATE";
            device_keyboard.friendlyDeviceType=@"zeewave";
            device_keyboard.deviceName=@"UnKnown Sensor";

            
            
            [Listarray addObject:device];
            [Listarray addObject:device1];
            [Listarray addObject:device2];
            [Listarray addObject:device3];
            [Listarray addObject:device4];
            [Listarray addObject:device_zigbeedoor];
            [Listarray addObject:device_lightsensor];
            [Listarray addObject:device_keyboard];
            
            devicelist.isSuccessful=YES;
            devicelist.deviceCount=8;
            devicelist.deviceList=Listarray;
            devicelist.reason=@"success";
            devicelist.almondMAC=@"1234543210987890";
            [dc callDummyCloud:devicelist commandType:CommandType_DEVICE_DATA_RESPONSE];
            
            break;
            
        }//
            
        case CommandType_DEVICE_VALUE:{
            
            SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
            knownvalues1=[self settingknownvalues:1 propertytypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetypea:@"STATE" valuea:@"true" valuenamea:@"notification_switch_off"];
            
            SFIDeviceKnownValues *knownvalues2=[[SFIDeviceKnownValues alloc]init];
            knownvalues2=[self settingknownvalues:1 propertytypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuetypea:@"STATE" valuea:[NSString stringWithFormat:@"%d",15] valuenamea:@"notification_switch_on"];
        
            NSArray *knownvaluearray=[[NSArray alloc]initWithObjects:knownvalues1 ,knownvalues2,nil];
            
            NSDictionary *table=[self buildLookupTable:knownvaluearray];
            
            //*-device 1 index 1
            SFIDeviceValue *devicevalue=[[SFIDeviceValue alloc]init];
            devicevalue.valueCount=2;
            devicevalue.deviceID=1;
            devicevalue.isPresent=YES;
            devicevalue.lookupTable=table;
            devicevalue.knownValues=knownvaluearray;
       
            //device 2 index 1
            
            SFIDeviceKnownValues *knownvalues12=[[SFIDeviceKnownValues alloc]init];
            knownvalues12.index=1;
            knownvalues12.propertyType=SFIDevicePropertyType_SENSOR_BINARY;
            knownvalues12.valueType=@"STATE";
            knownvalues12.value=@"true";
            knownvalues12.valueName=@"SENSOR BINARY";
            
            SFIDeviceKnownValues *knownvalues22=[[SFIDeviceKnownValues alloc]init];
            knownvalues22.index=1;
            knownvalues22.propertyType=SFIDevicePropertyType_SENSOR_BINARY;
            knownvalues22.valueType=@"STATE";
            knownvalues22.value=@"false";
            knownvalues22.valueName=@"SENSOR BINARY";
            //
            NSArray *knownvaluearray1=[[NSArray alloc]initWithObjects:knownvalues12 ,knownvalues22,nil];
            
            NSDictionary *table1=[self buildLookupTable:knownvaluearray1];

            SFIDeviceValue *devicevalue2=[[SFIDeviceValue alloc]init];
            devicevalue2.valueCount=2;
            devicevalue2.deviceID=2;
            devicevalue2.isPresent=YES;
            devicevalue2.lookupTable=table1;
            devicevalue2.knownValues=knownvaluearray1;

            //device 3 index 2
          
            SFIDeviceKnownValues *knownvalues13=[[SFIDeviceKnownValues alloc]init];
            knownvalues13.index=2;
            knownvalues13.propertyType=SFIDevicePropertyType_HUMIDITY;
            knownvalues13.valueType=@"STATE";
            knownvalues13.value=[NSString stringWithFormat:@"%d",50];
            knownvalues13.valueName=@"HUMIDITY";
            
            
            //index 2
            SFIDeviceKnownValues *knownvalues23=[[SFIDeviceKnownValues alloc]init];
            knownvalues23.index=1;
            knownvalues23.propertyType=SFIDevicePropertyType_TEMPERATURE;
            knownvalues23.valueType=@"PRIMARY ATTRIBUTE";
            knownvalues23.value=[NSString stringWithFormat:@"%d",15];
            knownvalues23.valueName=@"TEMPERATURE";
            //
            NSArray *knownvaluearray3=[[NSArray alloc]initWithObjects:knownvalues13 ,knownvalues23,nil];
            
            NSDictionary *table3=[self buildLookupTable:knownvaluearray3];
            
            
            
            SFIDeviceValue *devicevalue3=[[SFIDeviceValue alloc]init];
            devicevalue3.valueCount=2;
            devicevalue3.deviceID=3;
            devicevalue3.isPresent=YES;
            devicevalue3.lookupTable=table3;
            devicevalue3.knownValues=knownvaluearray3;
            
            //device id 4 index 5 tharmosat
            
            SFIDeviceKnownValues *knownvalues_tharmosat=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat.index=6;
            knownvalues_tharmosat.propertyType=SFIDevicePropertyType_THERMOSTAT_FAN_MODE;
            knownvalues_tharmosat.valueType=@"DETAIL INDEX";
            knownvalues_tharmosat.value=@"Auto";
            knownvalues_tharmosat.valueName=@"THERMOSTAT FAN MODE";

            SFIDeviceKnownValues *knownvalues_tharmosat1=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat1.index=1;
            knownvalues_tharmosat1.propertyType=SFIDevicePropertyType_SENSOR_MULTILEVEL;
            knownvalues_tharmosat1.valueType=@"STATE";
            knownvalues_tharmosat1.value=[NSString stringWithFormat:@"%d",0];
            knownvalues_tharmosat1.valueName=@"SENSOR MULTILEVEL";

            SFIDeviceKnownValues *knownvalues_tharmosat2=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat2.index=2;
            knownvalues_tharmosat2.propertyType=SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE;
            knownvalues_tharmosat2.valueType=@"PRIMARY ATTRIBUTE";
            knownvalues_tharmosat2.value=@"Heating";
            knownvalues_tharmosat2.valueName=@"THERMOSTAT OPERATING STATE";

            SFIDeviceKnownValues *knownvalues_tharmosat3=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat3.index=3;
            knownvalues_tharmosat3.propertyType=SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING;
            knownvalues_tharmosat3.valueType=@"DETAIL INDEX";
            knownvalues_tharmosat3.value=[NSString stringWithFormat:@"%d",0];
            knownvalues_tharmosat3.valueName=@"THERMOSTAT SETPOINT COOLING";

            SFIDeviceKnownValues *knownvalues_tharmosat4=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat4.index=4;
            knownvalues_tharmosat4.propertyType=SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING;
            knownvalues_tharmosat4.valueType=@"DETAIL INDEX";
            knownvalues_tharmosat4.value=[NSString stringWithFormat:@"%d",0];
            knownvalues_tharmosat4.valueName=@"THERMOSTAT SETPOINT HEATING";

            SFIDeviceKnownValues *knownvalues_tharmosat5=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat5.index=5;
            knownvalues_tharmosat5.propertyType=SFIDevicePropertyType_THERMOSTAT_MODE;
            knownvalues_tharmosat5.valueType=@"DETAIL INDEX";
            knownvalues_tharmosat5.value=@"Auto";
            knownvalues_tharmosat5.valueName=@"THERMOSTAT MODE";
            
            
            SFIDeviceKnownValues *knownvalues_tharmosat6=[[SFIDeviceKnownValues alloc]init];
            knownvalues_tharmosat6.index=7;
            knownvalues_tharmosat6.propertyType=SFIDevicePropertyType_THERMOSTAT_FAN_STATE;
            knownvalues_tharmosat6.valueType=@"DETAIL INDEX";
            knownvalues_tharmosat6.value=@"on";
            knownvalues_tharmosat6.valueName=@"THERMOSTAT FAN STATE";

            
            NSArray *knownvaluearray_tharmosat=[[NSArray alloc]initWithObjects:knownvalues_tharmosat,knownvalues_tharmosat1,knownvalues_tharmosat2,knownvalues_tharmosat3,knownvalues_tharmosat4,knownvalues_tharmosat5,knownvalues_tharmosat6,nil];
            
            NSDictionary *table_tharmosat=[self buildLookupTable:knownvaluearray_tharmosat];
            SFIDeviceValue *devicevalue_tharmosat=[[SFIDeviceValue alloc]init];
            devicevalue3.valueCount=1;
            devicevalue3.deviceID=4;
            devicevalue3.isPresent=YES;
            devicevalue3.lookupTable=table_tharmosat;
            devicevalue3.knownValues=knownvaluearray_tharmosat;
            //device id 5
            
            SFIDeviceKnownValues *knownvalues_colour=[[SFIDeviceKnownValues alloc]init];
            knownvalues_colour.index=1;
            knownvalues_colour.propertyType=SFIDevicePropertyType_SWITCH_BINARY;
            knownvalues_colour.valueType=@"PRIMARY ATTRIBUTE";
            knownvalues_colour.value=@"false";
            knownvalues_colour.valueName=@"THERMOSTAT OPERATING STATE";
            
            
            NSArray *knownvaluearray_colour=[[NSArray alloc]initWithObjects:knownvalues_tharmosat,nil];
            
            NSDictionary *table_colour=[self buildLookupTable:knownvaluearray_colour];
            SFIDeviceValue *devicevalue_colour=[[SFIDeviceValue alloc]init];
            devicevalue_colour.valueCount=1;
            devicevalue_colour.deviceID=5;
            devicevalue_colour.isPresent=YES;
            devicevalue_colour.lookupTable=table_colour;
            devicevalue_colour.knownValues=knownvaluearray_colour;

            // zegbee door lock
            
            SFIDeviceKnownValues *knownvalues_zegbeedoor=[[SFIDeviceKnownValues alloc]init];
            knownvalues_zegbeedoor.index=1;
            knownvalues_zegbeedoor.propertyType=SFIDevicePropertyType_LOCK_STATE;
            knownvalues_zegbeedoor.valueType=@"STATE";
            knownvalues_zegbeedoor.value=@"0";
            knownvalues_zegbeedoor.valueName=@"LOCK_STATE";
            
            
            NSArray *knownvaluearray_zegbeedoor=[[NSArray alloc]initWithObjects:knownvalues_zegbeedoor,nil];
            
            NSDictionary *table_zegbeedoor=[self buildLookupTable:knownvaluearray_zegbeedoor];
            SFIDeviceValue *devicevalue_zegbeedoor=[[SFIDeviceValue alloc]init];
            devicevalue_zegbeedoor.valueCount=3;
            devicevalue_zegbeedoor.deviceID=6;
            devicevalue_zegbeedoor.isPresent=YES;
            devicevalue_zegbeedoor.lookupTable=table_zegbeedoor;
            devicevalue_zegbeedoor.knownValues=knownvaluearray_zegbeedoor;

            
            
            //knownvalues lightsensor
            SFIDeviceKnownValues *knownvalues_lightsensor=[[SFIDeviceKnownValues alloc]init];
            knownvalues_lightsensor.index=1;
            knownvalues_lightsensor.propertyType=SFIDevicePropertyType_ILLUMINANCE;
            knownvalues_lightsensor.valueType=@"STATE";
            knownvalues_lightsensor.value=@"0 lux";
            knownvalues_lightsensor.valueName=@"ILLUMINANCE";
            
            NSArray *knownvaluearray_lightsensor=[[NSArray alloc]initWithObjects:knownvalues_lightsensor,nil];
            
            NSDictionary *table_lightsensor=[self buildLookupTable:knownvaluearray_lightsensor];
            SFIDeviceValue *devicevalue_lightsensor=[[SFIDeviceValue alloc]init];
            devicevalue_lightsensor.valueCount=1;
            devicevalue_lightsensor.deviceID=7;
            devicevalue_lightsensor.isPresent=YES;
            devicevalue_lightsensor.lookupTable=table_lightsensor;
            devicevalue_lightsensor.knownValues=knownvaluearray_lightsensor;
            

            SFIDeviceKnownValues *knownvalues_keyboard=[[SFIDeviceKnownValues alloc]init];
            knownvalues_keyboard.index=1;
            knownvalues_keyboard.propertyType=SFIDevicePropertyType_STATE;
            knownvalues_keyboard.valueType=@"STATE";
            knownvalues_keyboard.value=@"false";
            knownvalues_keyboard.valueName=@"STATE";
            
            
            NSArray *knownvaluearray_keyboard=[[NSArray alloc]initWithObjects:knownvalues_keyboard,nil];
            
            NSDictionary *table_keyboard=[self buildLookupTable:knownvaluearray_keyboard];
            SFIDeviceValue *devicevalue_keyboard=[[SFIDeviceValue alloc]init];
            devicevalue_keyboard.valueCount=1;
            devicevalue_keyboard.deviceID=8;
            devicevalue_keyboard.isPresent=YES;
            devicevalue_keyboard.lookupTable=table_keyboard;
            devicevalue_keyboard.knownValues=knownvaluearray_keyboard;

            
            
            NSMutableArray *arr=[[NSMutableArray alloc]initWithObjects:devicevalue,devicevalue2 ,devicevalue3,devicevalue_tharmosat,devicevalue_colour,devicevalue_zegbeedoor,devicevalue_lightsensor,devicevalue_keyboard,nil];
            DeviceValueResponse *devicevaluelist=[[DeviceValueResponse alloc]init];
            
            devicevaluelist.deviceCount=8;
            devicevaluelist.isSuccessful=YES;
            devicevaluelist.reason=@"success";
            devicevaluelist.almondMAC=@"1234543210987890";
            // devicevaluelist.deviceValueList=[[NSMutableArray alloc]initWithArray:arr];
            devicevaluelist.deviceValueList=arr;
            [dc callDummyCloud:devicevaluelist commandType:CommandType_DEVICE_VALUE_LIST_RESPONSE];
    
            break;
        }//
            
            
            
            
        case CommandType_CHANGE_PASSWORD_REQUEST:{
 
            ChangePasswordResponse *chngpassword=[[ChangePasswordResponse alloc]init];
            chngpassword.isSuccessful=YES;
            chngpassword.reasonCode=1;
            chngpassword.reason=@"success";
            [dc callDummyCloud:chngpassword commandType:CommandType_CHANGE_PASSWORD_RESPONSE];
 
            break;
            
        }//
       
        case CommandType_MOBILE_COMMAND:{
           
            Class class = cmd.command;
//mobilecommandrequest + dynamic value
            
            if([class isKindOfClass:[MobileCommandRequest class]]){
                NSLog(@"MobileCommandRequest");
                MobileCommandRequest *mobilerequest=cmd.command;
                NSLog(@"Mobilecommand request %@ ",mobilerequest);
                NSLog(@"changed value: %@, indexid: %@", mobilerequest.changedValue, mobilerequest.indexID);
             MobileCommandResponse *mobileresponse=[[MobileCommandResponse alloc]init];
                mobileresponse.isSuccessful=YES;
                mobileresponse.reason=@"success";
                mobileresponse.mobileInternalIndex=mobilerequest.correlationId;
                NSLog(@"mockcloud.m -> mii: %d", mobilerequest.correlationId);
    [dc callDummyCloud:mobileresponse commandType:CommandType_MOBILE_COMMAND_RESPONSE];
                NSLog(@"mockcloud.m -> cmd.class: %@, cmd.command: %@", cmd.class, cmd.command);
                NSLog(@"mockcloud going to sleep");
                sleep(1);
                NSLog(@"device id %@ and device type %d",mobilerequest.deviceID,mobilerequest.deviceType);
                if(mobilerequest.deviceType==SFIDeviceType_MultiLevelSwitch_2)
                {
                NSLog(@"mockcloud.m -> dynamic update is being sent");
                SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
                knownvalues1.index=1;
                knownvalues1.propertyType=SFIDevicePropertyType_SWITCH_MULTILEVEL;
                knownvalues1.valueType=@"STATE";
                knownvalues1.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues1.valueName=@"SWITCH MULTILEVEL";
                NSArray *knownvaluearray=[[NSArray alloc]initWithObjects:knownvalues1 ,nil];
                //it internally builds lookup table
                SFIDeviceValue *devicevalue=[[SFIDeviceValue alloc]init];
                devicevalue.valueCount=1;
                devicevalue.deviceID=1;
                devicevalue.isPresent=YES;
                [devicevalue replaceKnownDeviceValues:knownvaluearray];
                    NSMutableArray *alldevicearray=[[NSMutableArray alloc]initWithObjects:devicevalue, nil];
                    DeviceValueResponse *devicevalueresponse_all=[[DeviceValueResponse alloc]init];
                    devicevalueresponse_all.isSuccessful=YES;
                    devicevalueresponse_all.reason=@"success";
                    devicevalueresponse_all.almondMAC=mobilerequest.almondMAC;
                    devicevalueresponse_all.deviceValueList=alldevicearray;
                    devicevalueresponse_all.deviceCount=1;
                    dc.delegate = network;
                    [dc callDummyCloud:devicevalueresponse_all commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
      
                }//if
                
                if(mobilerequest.deviceType==SFIDeviceType_TemperatureSensor_27){
                SFIDeviceKnownValues *knownvalues3=[[SFIDeviceKnownValues alloc]init];
                knownvalues3.index=2;
                knownvalues3.propertyType=SFIDevicePropertyType_TEMPERATURE;
                knownvalues3.valueType=@"STATE";
                knownvalues3.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues3.valueName=@"SWITCH MULTILEVEL";
                NSArray *knownvaluearray3=[[NSArray alloc]initWithObjects:knownvalues3 ,nil];
                //it internally builds lookup table
                SFIDeviceValue *devicevalue3=[[SFIDeviceValue alloc]init];
                devicevalue3.valueCount=1;
                devicevalue3.deviceID=3;
                devicevalue3.isPresent=YES;
                [devicevalue3 replaceKnownDeviceValues:knownvaluearray3];
              
                    NSMutableArray *alldevicearray=[[NSMutableArray alloc]initWithObjects:devicevalue3, nil];
                    DeviceValueResponse *devicevalueresponse_all=[[DeviceValueResponse alloc]init];
                    devicevalueresponse_all.isSuccessful=YES;
                    devicevalueresponse_all.reason=@"success";
                    devicevalueresponse_all.almondMAC=mobilerequest.almondMAC;
                    devicevalueresponse_all.deviceValueList=alldevicearray;
                    devicevalueresponse_all.deviceCount=1;
                    dc.delegate = network;
                    [dc callDummyCloud:devicevalueresponse_all commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
                }
                if(mobilerequest.deviceType==SFIDeviceType_Thermostat_7){
                SFIDeviceKnownValues *knownvalues_tharmosat=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat.index=6;
                knownvalues_tharmosat.propertyType=SFIDevicePropertyType_THERMOSTAT_FAN_MODE;
                knownvalues_tharmosat.valueType=@"DETAIL INDEX";
                knownvalues_tharmosat.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat.valueName=@"THERMOSTAT FAN MODE";
                    SFIDeviceKnownValues *knownvalues_tharmosat1=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat1.index=1;
                knownvalues_tharmosat1.propertyType=SFIDevicePropertyType_SENSOR_MULTILEVEL;
                knownvalues_tharmosat1.valueType=@"STATE";
                knownvalues_tharmosat1.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat1.valueName=@"SENSOR MULTILEVEL";
                
                SFIDeviceKnownValues *knownvalues_tharmosat2=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat2.index=2;
                knownvalues_tharmosat2.propertyType=SFIDevicePropertyType_THERMOSTAT_OPERATING_STATE;
                knownvalues_tharmosat2.valueType=@"PRIMARY ATTRIBUTE";
                knownvalues_tharmosat2.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat2.valueName=@"THERMOSTAT OPERATING STATE";
                
                SFIDeviceKnownValues *knownvalues_tharmosat3=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat3.index=3;
                knownvalues_tharmosat3.propertyType=SFIDevicePropertyType_THERMOSTAT_SETPOINT_COOLING;
                knownvalues_tharmosat3.valueType=@"DETAIL INDEX";
                knownvalues_tharmosat3.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];                knownvalues_tharmosat3.valueName=@"THERMOSTAT SETPOINT COOLING";
                
                SFIDeviceKnownValues *knownvalues_tharmosat4=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat4.index=4;
                knownvalues_tharmosat4.propertyType=SFIDevicePropertyType_THERMOSTAT_SETPOINT_HEATING;
                knownvalues_tharmosat4.valueType=@"DETAIL INDEX";
                knownvalues_tharmosat4.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat4.valueName=@"THERMOSTAT SETPOINT HEATING";
                
                SFIDeviceKnownValues *knownvalues_tharmosat5=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat5.index=5;
                knownvalues_tharmosat5.propertyType=SFIDevicePropertyType_THERMOSTAT_MODE;
                knownvalues_tharmosat5.valueType=@"DETAIL INDEX";
                knownvalues_tharmosat5.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat5.valueName=@"THERMOSTAT MODE";
                
                
                SFIDeviceKnownValues *knownvalues_tharmosat6=[[SFIDeviceKnownValues alloc]init];
                knownvalues_tharmosat6.index=7;
                knownvalues_tharmosat6.propertyType=SFIDevicePropertyType_THERMOSTAT_FAN_STATE;
                knownvalues_tharmosat6.valueType=@"DETAIL INDEX";
                knownvalues_tharmosat6.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_tharmosat6.valueName=@"THERMOSTAT FAN STATE";
                
                
                NSArray *knownvaluearray_tharmosat=[[NSArray alloc]initWithObjects:knownvalues_tharmosat,knownvalues_tharmosat1,knownvalues_tharmosat2,knownvalues_tharmosat3,knownvalues_tharmosat4,knownvalues_tharmosat5,knownvalues_tharmosat6,nil];
                
                //it internally builds lookup table
                SFIDeviceValue *devicevalue_tharmosat=[[SFIDeviceValue alloc]init];
                devicevalue_tharmosat.valueCount=6;
                devicevalue_tharmosat.deviceID=4;
                devicevalue_tharmosat.isPresent=YES;
               [devicevalue_tharmosat replaceKnownDeviceValues:knownvaluearray_tharmosat];
                    NSMutableArray *alldevicearray=[[NSMutableArray alloc]initWithObjects:devicevalue_tharmosat, nil];
                    DeviceValueResponse *devicevalueresponse_all=[[DeviceValueResponse alloc]init];
                    devicevalueresponse_all.isSuccessful=YES;
                    devicevalueresponse_all.reason=@"success";
                    devicevalueresponse_all.almondMAC=mobilerequest.almondMAC;
                    devicevalueresponse_all.deviceValueList=alldevicearray;
                    devicevalueresponse_all.deviceCount=1;
                    [dc callDummyCloud:devicevalueresponse_all commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];

                }
                
                if(mobilerequest.deviceType==SFIDeviceType_ZigbeeDoorLock_28){
                //device id 6 door lock
                SFIDeviceKnownValues *knownvalues_zegbeedoor=[[SFIDeviceKnownValues alloc]init];
                knownvalues_zegbeedoor.index=1;
                knownvalues_zegbeedoor.propertyType=SFIDevicePropertyType_LOCK_STATE;
                knownvalues_zegbeedoor.valueType=@"STATE";
                knownvalues_zegbeedoor.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                knownvalues_zegbeedoor.valueName=@"LOCK_STATE";
                
                
                NSArray *knownvaluearray_zegbeedoor=[[NSArray alloc]initWithObjects:knownvalues_zegbeedoor,nil];
                
                NSDictionary *table_zegbeedoor=[self buildLookupTable:knownvaluearray_zegbeedoor];
                SFIDeviceValue *devicevalue_zegbeedoor=[[SFIDeviceValue alloc]init];
                devicevalue_zegbeedoor.valueCount=3;
                devicevalue_zegbeedoor.deviceID=6;
                devicevalue_zegbeedoor.isPresent=YES;
                devicevalue_zegbeedoor.lookupTable=table_zegbeedoor;
                devicevalue_zegbeedoor.knownValues=knownvaluearray_zegbeedoor;
                NSMutableArray *alldevicearray=[[NSMutableArray alloc]initWithObjects:devicevalue_zegbeedoor, nil];
                DeviceValueResponse *devicevalueresponse_all=[[DeviceValueResponse alloc]init];
                devicevalueresponse_all.isSuccessful=YES;
                devicevalueresponse_all.reason=@"success";
                devicevalueresponse_all.almondMAC=mobilerequest.almondMAC;
                devicevalueresponse_all.deviceValueList=alldevicearray;
                devicevalueresponse_all.deviceCount=1;
                [dc callDummyCloud:devicevalueresponse_all commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
                NSLog(@"dynamic update sent");
                }//if
//                }
                
                if(mobilerequest.deviceType==SFIDeviceType_BinarySensor_3){
                    
                     SFIDeviceKnownValues *knownvalues_door=[[SFIDeviceKnownValues alloc]init];
                    knownvalues_door.index=1;
                    knownvalues_door.propertyType=SFIDevicePropertyType_SENSOR_BINARY;
                    knownvalues_door.valueType=@"STATE";
                    knownvalues_door.value=[NSString stringWithFormat:@"%@",mobilerequest.changedValue];
                    knownvalues_door.valueName=@"SENSOR BINARY";
                    
                    
                    
                    NSArray *knownvaluearray_door=[[NSArray alloc]initWithObjects:knownvalues_door,nil];
                    
                    NSDictionary *table_door=[self buildLookupTable:knownvaluearray_door];
                    SFIDeviceValue *devicevalue_door=[[SFIDeviceValue alloc]init];
                    devicevalue_door.valueCount=2;
                    devicevalue_door.deviceID=2;
                    devicevalue_door.isPresent=YES;
                    devicevalue_door.lookupTable=table_door;
                    devicevalue_door.knownValues=knownvaluearray_door;
                    NSMutableArray *alldevicearray=[[NSMutableArray alloc]initWithObjects:devicevalue_door, nil];
                    DeviceValueResponse *devicevalueresponse_all=[[DeviceValueResponse alloc]init];
                    devicevalueresponse_all.isSuccessful=YES;
                    devicevalueresponse_all.reason=@"success";
                    devicevalueresponse_all.almondMAC=mobilerequest.almondMAC;
                    devicevalueresponse_all.deviceValueList=alldevicearray;
                    devicevalueresponse_all.deviceCount=1;
                     [dc callDummyCloud:devicevalueresponse_all commandType:CommandType_DYNAMIC_DEVICE_VALUE_LIST];
                }
            }
       
            //almond name change
            
            if([class isKindOfClass:[AlmondNameChange class]]){
            }
            //sensor name change request
            
            if([class isKindOfClass:[SensorChangeRequest class]]){
                NSLog(@"SensorChangeRequest");
                SensorChangeRequest *sensorRequest = cmd.command;
                unsigned int mii = sensorRequest.correlationId;
                SensorChangeResponse *sensorResponse = [[SensorChangeResponse alloc] init];
                sensorResponse.isSuccessful = YES;
                sensorResponse.mobileInternalIndex = mii;
                [dc callDummyCloud:sensorResponse commandType:CommandType_SENSOR_CHANGE_RESPONSE];
            }
            if([class isKindOfClass:[DeviceValueRequest class]]){
                
                NSLog(@"DeviceValueRequest");
            }
            if([class isKindOfClass:[AlmondModeChangeRequest class]]){
                
                AlmondModeChangeResponse *modechange=[[AlmondModeChangeResponse alloc]init];
                modechange.success=true;
                modechange.reason=@"Almondmode change successfully";
                modechange.reasonCode=1;
                [dc callDummyCloud:modechange commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
            }
           
            break;
            
        }
        case CommandType_CLOUD_SANITY:{
            GenericCommandResponse *genericResp=[[GenericCommandResponse alloc]init];
            genericResp.isSuccessful=YES;
            [dc callDummyCloud:genericResp commandType:CommandType_CLOUD_SANITY_RESPONSE];
            break;
            
        }
        case CommandType_NOTIFICATION_PREFERENCE_LIST_REQUEST:{
 
            NotificationPreferenceListRequest *notificationlistreq=cmd.command;
            //notification for device 1
            SFINotificationDevice *notifidevice=[[SFINotificationDevice alloc]init];
            notifidevice.deviceID=1;
            notifidevice.valueIndex=1;
            notifidevice.notificationMode=1;//always
            //notification for device 2
            SFINotificationDevice *notifidevice2=[[SFINotificationDevice alloc]init];
            notifidevice2.deviceID=2;
            notifidevice2.valueIndex=1;
            
            notifidevice2.notificationMode=1;//always
            SFINotificationUser *notificationuser=[[SFINotificationUser alloc]init];
            notificationuser.userID=@"shailesh.shah@securifi.com";
            notificationuser.preferenceCount=1;
            
            notificationuser.notificationDeviceList=[[NSArray alloc]initWithObjects:notifidevice, notifidevice2,nil];
            
            NotificationPreferenceListResponse *notificationpreferance=[[NotificationPreferenceListResponse alloc]init];
            notificationpreferance.isSuccessful=YES;
            notificationpreferance.reason=@"success";
            notificationpreferance.almondMAC=@"1234543210987890";
            notificationpreferance.preferenceCount=1;
            notificationpreferance.notificationUser=notificationuser;
            notificationpreferance.notificationDeviceList=[[NSMutableArray alloc]initWithArray:notificationuser.notificationDeviceList];

            [dc callDummyCloud:notificationpreferance commandType:CommandType_NOTIFICATION_PREFERENCE_LIST_RESPONSE];
            break;
            
        }
            
        case CommandType_GENERIC_COMMAND_REQUEST:{
            
            GenericCommandRequest *genericcommand=cmd.command;
            NSString *almondroutersummery=@"<root><AlmondRouterSummary action=\"get\">1</AlmondRouterSummary></root>";
            NSString *wirelessstting=@"<root><AlmondWirelessSettings action=\"get\">1</AlmondWirelessSettings></root>";
            NSString *connecteddevices=@"<root><AlmondConnectedDevices action=\"get\">1</AlmondConnectedDevices></root>";
            NSString *AlmondBlockedMACs=@"<root><AlmondBlockedMACs action=\"get\">1</AlmondBlockedMACs></root>";
            NSString *reboot=@"<root><Reboot>1</Reboot></root>";
            NSLog(@"genericcommand.data =%@",genericcommand.data);
            
            
            GenericCommandResponse *genericcommandresponse=[[GenericCommandResponse alloc]init];
            genericcommandresponse.genericData=nil;
            if(genericcommand.data==almondroutersummery)
            {
                NSLog(@"almondroutersummery");
                NSString *str_almondroutersummery=[[NSString alloc]init];
                str_almondroutersummery=@"<root><AlmondRouterSummary><AlmondWirelessSettingsSummary count=\"2\"><WirelessSetting index=\"1\" enabled=\"true\"><SSID>Main2.4GHz</SSID></WirelessSetting><WirelessSetting index=\"2\" enabled=\"false\"><SSID>Guest2.4GHz</SSID></WirelessSetting></AlmondWirelessSettingsSummary><AlmondConnectedDevicesSummary count=\"5\"></AlmondConnectedDevicesSummary><AlmondBlockedMACSummary count=\"2\"></<AlmondBlockedMACSummary><AlmondBlockedContentSummary count=\"2\"></<AlmondBlockedContentSummary><RouterUptime>5days, 6:15hrs</RouterUptime><FirmwareVersion>AP2-R054bi-L008-W011-ZW011-ZB003</FirmwareVersion></AlmondRouterSummary></root>";
                
                
                str_almondroutersummery=@"<root><AlmondRouterSummary><AlmondWirelessSettingsSummary count='2'><WirelessSetting index='1' enabled='true'><SSID>Main2.4GHz</SSID></WirelessSetting><WirelessSetting index='2' enabled='false'><SSID>Guest2.4GHz</SSID></WirelessSetting></AlmondWirelessSettingsSummary><AlmondConnectedDevicesSummary count='5'></AlmondConnectedDevicesSummary><AlmondBlockedMACSummary count='2'></AlmondBlockedMACSummary><AlmondBlockedContentSummary count='2'></AlmondBlockedContentSummary><RouterUptime>5days, 6:15hrs</RouterUptime><FirmwareVersion>AP2-R054bi-L008-W011-ZW011-ZB003</FirmwareVersion></AlmondRouterSummary></root>";
                
                NSInteger length=[str_almondroutersummery length];
                NSInteger commndtype=sizeof(CommandType_GENERIC_COMMAND_REQUEST);
                NSData *data_almondroutersummery=[str_almondroutersummery dataUsingEncoding:NSUTF8StringEncoding];
                
                NSMutableData *entiredata=[[NSMutableData alloc ]init];
                [entiredata appendBytes:&length length:4];
                
                [entiredata appendBytes:&commndtype length:4];
                [entiredata appendData:data_almondroutersummery];
                
                data_almondroutersummery=[entiredata base64EncodedDataWithOptions:0];
                NSString *str1_almondroutersummery=[[NSString alloc]initWithData:data_almondroutersummery encoding:0];
                
                NSLog(@"data  str ==%@  %@",data_almondroutersummery,str1_almondroutersummery);
                
                genericcommandresponse.genericData=str1_almondroutersummery;
                
            }
            if(genericcommand.data==wirelessstting){
                NSLog(@"wirelessstting");
                NSString *str_wirelessstting=@"<root><AlmondWirelessSettings count='2'><WirelessSetting index='1' enabled='true'><SSID>AlmondNetwork</SSID><Password>1234567890</Password><Channel>1</Channel><EncryptionType>AES</EncryptionType><Security>WPA2PSK</Security><WirelessMode>802.11bgn</WirelessMode><CountryRegion>0</CountryRegion></WirelessSetting><WirelessSetting index='2' enabled='true'><SSID>Guest</SSID><Password>1111222200</Password><Channel>1</Channel><EncryptionType>AES</EncryptionType><Security>WPA2PSK</Security><WirelessMode>802.11bgn</WirelessMode><CountryRegion>0</CountryRegion></WirelessSetting></AlmondWirelessSettings></root>";
                NSData *data_wirelessstting=[str_wirelessstting dataUsingEncoding:NSUTF8StringEncoding];
                
                data_wirelessstting=[data_wirelessstting base64EncodedDataWithOptions:0];
                NSString *str1_wirelessstting=[[NSString alloc]initWithData:data_wirelessstting encoding:0];
                NSLog(@"data  str ==%@  %@",data_wirelessstting,str1_wirelessstting);

               // NSLog(@"data  str ==%@  %@",data,str1);
                genericcommandresponse.genericData=str1_wirelessstting;
               
            }
            if(genericcommand.data==connecteddevices){
                NSLog(@"connecteddevices");
                
                NSString *str_connecteddevices=@"<root><AlmondConnectedDevices count=\"5\"><ConnectedDevice><Name>ashutosh</Name><IP>1678379540</IP><MAC>10:60:4b:d9:60:84</MAC></ConnectedDevice><ConnectedDevice><Name></Name><IP>1695156756</IP><MAC>00:00:00:00:00:00</MAC></ConnectedDevice><ConnectedDevice><Name>GT-S5253</Name><IP>1711933972</IP><MAC>00:07:ab:c2:57:98</MAC></ConnectedDevice><ConnectedDevice><Name>android-c95b260</Name><IP>1728711188</IP><MAC>a0:f4:50:ef:a1:71</MAC></ConnectedDevice><ConnectedDevice><Name>android-a3a41ac</Name><IP>1745488404</IP><MAC>3c:43:8e:b2:1a:9b</MAC></ConnectedDevice></AlmondConnectedDevices></root>";
                NSData *data_connecteddevices=[str_connecteddevices dataUsingEncoding:NSUTF8StringEncoding];
                
                data_connecteddevices=[data_connecteddevices base64EncodedDataWithOptions:0];
                NSString *str1_connecteddevices=[[NSString alloc]initWithData:data_connecteddevices encoding:0];
                NSLog(@"data  str ==%@  %@",data_connecteddevices,str1_connecteddevices);
                genericcommandresponse.genericData=str1_connecteddevices;

            }
            NSLog(@"AlmondBlockedMACs");
            if(genericcommand.data==AlmondBlockedMACs){
                NSString *str_AlmondBlockedMACs=@"<root><AlmondBlockedMACs count=\"2\"><BlockedMAC>10:60:4b:d9:60:84</BlockedMAC><BlockedMAC>00:07:ab:c2:57:98</BlockedMAC></AlmondBlockedMACs></root>";
                NSData *data_AlmondBlockedMACs=[str_AlmondBlockedMACs dataUsingEncoding:NSUTF8StringEncoding];
                
                data_AlmondBlockedMACs=[data_AlmondBlockedMACs base64EncodedDataWithOptions:0];
                NSString *str1_AlmondBlockedMACs=[[NSString alloc]initWithData:data_AlmondBlockedMACs encoding:0];
                NSLog(@"data  str ==%@  %@",data_AlmondBlockedMACs,str1_AlmondBlockedMACs);
                genericcommandresponse.genericData=str1_AlmondBlockedMACs;
            }
            
            if(genericcommand.data==reboot){
                NSString *Str_reboot=@"<root><GenericCommandResponse success=\"true\"> <AlmondplusMAC>251176214925585</AlmondplusMAC> <ApplicationID>1001</ApplicationID> <MobileInternalIndex>1</MobileInternalIndex> <MoreFragments>1|0</MoreFragments>​ ​<!-- Later Discussion --> <Data>[Base64Encoded]<Reboot>1</Reboot>​[Base64Encoded]</Data></GenericCommandResponse></root>";
                NSData *data_reboot=[Str_reboot dataUsingEncoding:NSUTF8StringEncoding];
                
                data_reboot=[data_reboot base64EncodedDataWithOptions:0];
                NSString *Str1_reboot=[[NSString alloc]initWithData:data_reboot encoding:0];
                NSLog(@"data  str ==%@  %@",data_reboot,Str1_reboot);
                genericcommandresponse.genericData=Str1_reboot;
            }
            genericcommandresponse.isSuccessful=YES;
            genericcommandresponse.reason=@"success";
            genericcommandresponse.mobileInternalIndex=genericcommand.correlationId;
            genericcommandresponse.almondMAC=genericcommand.almondMAC;
            genericcommandresponse.applicationID=genericcommand.applicationID;
            [dc callDummyCloud:genericcommandresponse commandType:CommandType_GENERIC_COMMAND_RESPONSE];
            break;
            
        }
            
        case CommandType_NOTIFICATION_PREF_CHANGE_REQUEST:{
            
            
            NotificationPreferences *notipreferancereq=(NotificationPreferences *)cmd.command;
            NSLog(@"notipreferancereq %@",notipreferancereq.internalIndex);
            NotificationPreferenceResponse *notipreferance=[[NotificationPreferenceResponse alloc]init];
            notipreferance.isSuccessful=YES;
            notipreferance.reason=@"success";
            notipreferance.reasonCode=2;
            NSLog(@"sssss1 notidication preferance chng");
            int index=notipreferancereq.correlationId;
            NSLog(@"%d infed",index);
            notipreferance.internalIndex = [NSString stringWithFormat:@"%d",index];

            [dc callDummyCloud:notipreferance commandType:CommandType_NOTIFICATION_PREF_CHANGE_RESPONSE];
            break;
        }
        case CommandType_DELETE_ACCOUNT_REQUEST:{
            
            DeleteAccountResponse *delAcc=[[DeleteAccountResponse alloc]init];
            delAcc.isSuccessful=YES;
            delAcc.reason=@"success";
            delAcc.reasonCode=1;

            [dc callDummyCloud:delAcc commandType:CommandType_DELETE_ACCOUNT_RESPONSE];
            break;
        }
            
        case CommandType_USER_INVITE_REQUEST:{
            
            UserInviteRequest *req=cmd.command;
            UserInviteResponse *invite=[[UserInviteResponse alloc]init];
            invite.isSuccessful=true;
            invite.reasonCode=2;
            invite.reason=@"success";
            invite.internalIndex=[NSString stringWithFormat:@"%d" ,req.correlationId];

            [dc callDummyCloud:invite commandType:CommandType_USER_INVITE_RESPONSE];
            break;
            
        }
            
        case CommandType_ALMOND_AFFILIATION_DATA_REQUEST:{
            
            AlmondAffiliationDataResponse *almondaffiliation=[[AlmondAffiliationDataResponse alloc]init];
            AlmondListResponse *almlistres=[[AlmondListResponse alloc]init];
            
            SFIAlmondPlus *plus=[[SFIAlmondPlus alloc]init];
            plus.almondplusMAC=@"1234543210987890";
            plus.almondplusName=@"Alm";
            // plus.accessEmailIDs=@"masood.pathan@securifi.com";
            plus.userCount=2;
            NSMutableArray *list=[[NSMutableArray alloc]initWithObjects:plus, nil];
            
            almlistres.isSuccessful=YES;
            almlistres.deviceCount=1;
            almlistres.reason=@"success";
            almlistres.almondPlusMACList=list;
            almlistres.action=@"add";
            
            
            almondaffiliation.isSuccessful=true;
            almondaffiliation.almondCount=1;
            almondaffiliation.reason=@"almond affiliation success";
            almondaffiliation.almondList=list;
 
            [dc callDummyCloud:almondaffiliation commandType:CommandType_ALMOND_AFFILIATION_DATA_RESPONSE];
            break;
        }
      
        case CommandType_USER_PROFILE_REQUEST:{
            
            NSLog(@"IN USERPROFILE REQUEST...");
            
            UserProfileResponse *userResponse=[[UserProfileResponse alloc]init];
            userResponse.isSuccessful=YES;
            userResponse.firstName=@"xyz";
            userResponse.lastName=@"abc";
            userResponse.addressLine1=@"add1";
            userResponse.addressLine2=@"add3";
            userResponse.addressLine3=@"add2";
            userResponse.country=@"India";
            userResponse.zipCode=@"1234455";
            userResponse.reason=@"success";
            userResponse.reasonCode=1;

            [dc callDummyCloud:userResponse commandType:CommandType_USER_PROFILE_RESPONSE];
            break;
            
        }
            
        case CommandType_UPDATE_USER_PROFILE_REQUEST:{
            UpdateUserProfileRequest *updatere=cmd.command;
            
            UpdateUserProfileResponse *updateres=[[UpdateUserProfileResponse alloc]init];
            updateres.isSuccessful=true;
            updateres.reasonCode=1;
            updateres.reason=@"success";
            updateres.internalIndex=[NSString stringWithFormat:@"%d", updatere.correlationId];

            [dc callDummyCloud:updateres commandType:CommandType_UPDATE_USER_PROFILE_RESPONSE];
            break;
        }
            
        case CommandType_ME_AS_SECONDARY_USER_REQUEST:{
            
            MeAsSecondaryUserResponse *secondaryuser=[[MeAsSecondaryUserResponse alloc]init];
            secondaryuser.isSuccessful=true;
            secondaryuser.almondCount=1;
            secondaryuser.reason=@"secondary user success";
            secondaryuser.reasonCode=1;
       
            SFIAlmondPlus *plus=[[SFIAlmondPlus alloc]init];
            plus.almondplusMAC=@"1234543210987890";
            plus.almondplusName=@"Alm";
            // plus.accessEmailIDs=@"masood.pathan@securifi.com";
            plus.userCount=2;
            NSMutableArray *list=[[NSMutableArray alloc]initWithObjects:plus, nil];
            
            secondaryuser.almondList=list;
          
            [dc callDummyCloud:secondaryuser commandType:CommandType_ME_AS_SECONDARY_USER_RESPONSE];
            break;
        }
            
        case CommandType_DELETE_ME_AS_SECONDARY_USER_REQUEST:{
            DeleteMeAsSecondaryUserRequest *delmereq=cmd.command;
            DeleteMeAsSecondaryUserResponse *delme=[[DeleteMeAsSecondaryUserResponse alloc]init];
            delme.isSuccessful=true;
            delme.reasonCode=1;
            delme.reason=@"success";
            delme.internalIndex=[NSString stringWithFormat:@"%d", delmereq.correlationId];

            NSLog(@"me as secondary request delete");
            [dc callDummyCloud:delme commandType:CommandType_DELETE_ME_AS_SECONDARY_USER_RESPONSE];
            break;
        }
            
        case CommandType_UNLINK_ALMOND_REQUEST:{
            
            UnlinkAlmondResponse *obj =[[UnlinkAlmondResponse alloc]init];
            obj.isSuccessful=YES;
            obj.reasonCode=1;
            obj.reason=@"success";

            [dc callDummyCloud:obj commandType:CommandType_UNLINK_ALMOND_RESPONSE];
            break;
            
        }
        case CommandType_DELETE_SECONDARY_USER_REQUEST:{
            
            DeleteSecondaryUserRequest *delsecreq=cmd.command;
            
            DeleteSecondaryUserResponse *delsecond=[[DeleteSecondaryUserResponse alloc]init];
            delsecond.isSuccessful=true;
            delsecond.reason=@"success";
            delsecond.reasonCode=1;
            delsecond.internalIndex=[NSString stringWithFormat:@"%d",delsecreq.correlationId];

            NSLog(@"secondary user delete req");
            [dc callDummyCloud:delsecond commandType:CommandType_DELETE_SECONDARY_USER_RESPONSE];
            break;
        }
  
        case CommandType_NOTIFICATION_REGISTRATION:{
            
            NSLog(@"notification reg req");
            NotificationRegistrationResponse *notifiregistration=[[NotificationRegistrationResponse alloc]init];
            notifiregistration.isSuccessful=true;
            notifiregistration.reason=@"success";
            notifiregistration.reasonCode=0;

            [dc callDummyCloud:notifiregistration commandType:CommandType_NOTIFICATION_REGISTRATION_RESPONSE];
            break;
        }
        case CommandType_NOTIFICATION_DEREGISTRATION:{
            
            NotificationDeleteRegistrationResponse *notifideregi=[[NotificationDeleteRegistrationResponse alloc]init];
            
            notifideregi.isSuccessful=true;
            notifideregi.reason=@"success";
            notifideregi.reasonCode=0;

            [dc callDummyCloud:notifideregi commandType:CommandType_NOTIFICATION_DEREGISTRATION_RESPONSE];
            break;
        }
        case CommandType_ALMOND_MODE_CHANGE_REQUEST:{
            AlmondModeChangeResponse *modechange=[[AlmondModeChangeResponse alloc]init];
            modechange.success=true;
            modechange.reason=@"Almondmode change successfully";
            modechange.reasonCode=1;
            [dc callDummyCloud:modechange commandType:CommandType_ALMOND_MODE_CHANGE_RESPONSE];
            break;
        }
        case CommandType_NOTIFICATIONS_SYNC_REQUEST:{
            
            NSLog(@"in notification list sync req");
            SFINotification *notification=[[SFINotification alloc]init];
            notification.notificationId=2;
            notification.externalId=@"1";
            
            notification.almondMAC=@"1234543210987890";
            notification.time=1;
            notification.deviceName=@"SWITCH MULTILEVEL";
            notification.deviceId=1;
            notification.deviceType=SFIDeviceType_MultiLevelSwitch_2;
            notification.valueIndex=1;
            
            notification.valueType=SFIDevicePropertyType_SWITCH_MULTILEVEL;//propertytype
            notification.value=[NSString stringWithFormat:@"%d",0];
            notification.debugCounter=1;
            notification.viewed=YES;
            
            NSArray *notificationarray=[[NSArray alloc]init];
            NotificationListResponse *listResponse=[[NotificationListResponse alloc]init];
//            listResponse.pageState=@"2";
//            listResponse.requestId=@"3";
//            listResponse.notifications=notificationarray;

            
            [dc callDummyCloud:listResponse commandType:CommandType_NOTIFICATIONS_SYNC_RESPONSE];
            break;
            
            
        }
        case CommandType_DEVICELOG_REQUEST:{
            NSLog(@"in device log req command");
            SFINotification *notification=[[SFINotification alloc]init];
            notification=[self createnotification:2 externalIDa:@"3" almondMACa:@"1234543210987890" timea:2 devicenamea:@"SWITCH MULTILEVEL" deviceida:1 devicetypea:SFIDeviceType_MultiLevelSwitch_2 valueindexa:1 valuetypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuea:[NSString stringWithFormat:@"%d",4] vieweda:NO debugcountera:2231];
            
            SFINotification *notification_1=[[SFINotification alloc]init];
            notification_1=[self createnotification:1234 externalIDa:@"4321" almondMACa:@"1234543210987890" timea:1 devicenamea:@"SWITCH MULTILEVEL" deviceida:1 devicetypea:SFIDeviceType_MultiLevelSwitch_2 valueindexa:1 valuetypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuea:@"50" vieweda:NO debugcountera:1213];
            
        
            SFINotification *switchMultilevelNotification3 = [[SFINotification alloc] init];
            switchMultilevelNotification3=[self createnotification:654654 externalIDa:@"56464" almondMACa:@"1234543210987890" timea:1 devicenamea:@"SWITCH MULTILEVEL" deviceida:1 devicetypea:SFIDeviceType_MultiLevelSwitch_2 valueindexa:1 valuetypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuea:@"30" vieweda:NO debugcountera:3];
            
        
            SFINotification *switchMultilevelNotification4 = [[SFINotification alloc] init];
            switchMultilevelNotification4=[self createnotification:89798 externalIDa:@"8798" almondMACa:@"1234543210987890" timea:1 devicenamea:@"Multilevel Switch" deviceida:1 devicetypea:SFIDeviceType_MultiLevelSwitch_2 valueindexa:1 valuetypea:SFIDevicePropertyType_SWITCH_MULTILEVEL valuea:@"30" vieweda:NO debugcountera:2];

            
            SFINotification *notification1=[[SFINotification alloc]init];
            notification1=[self createnotification:2 externalIDa:@"2" almondMACa:@"1234543210987890" timea:1 devicenamea:@"Z-wave Door Sensor" deviceida:2 devicetypea:SFIDeviceType_BinarySensor_3 valueindexa:1 valuetypea:SFIDevicePropertyType_SENSOR_BINARY valuea:@"false" vieweda:YES debugcountera:2323];
            
            SFINotification *notification_ID3=[[SFINotification alloc]init];
            
            notification_ID3.notificationId=2;
            notification_ID3.externalId=@"2";
            
            notification_ID3.almondMAC=@"1234543210987890";
            notification_ID3.time=5;
            notification_ID3.deviceName=@"Temperature sensor";
            notification_ID3.deviceId=3;
            notification_ID3.deviceType=SFIDevicePropertyType_TEMPERATURE;
            notification_ID3.valueIndex=1;
            
            notification_ID3.valueType=SFIDevicePropertyType_SWITCH_MULTILEVEL;//propertytype
            notification_ID3.value=[NSString stringWithFormat:@"%d",2];
            notification_ID3.debugCounter=1;
            notification_ID3.viewed=YES;
            
            SFINotification *notification_ID4=[[SFINotification alloc]init];
            notification_ID4.notificationId=2;
            notification_ID4.externalId=@"6";
            
            notification_ID4.almondMAC=@"1234543210987890";
            notification_ID4.time=9;
            notification_ID4.deviceName=@"Tharmosat";
            notification_ID4.deviceId=4;
            notification_ID4.deviceType=SFIDeviceType_Thermostat_7;
            notification_ID4.valueIndex=5;
            
            notification_ID4.valueType=SFIDevicePropertyType_THERMOSTAT_MODE;//propertytype
            notification_ID4.value=@"auto";
            notification_ID4.debugCounter=2;
            notification_ID4.viewed=YES;
            
            SFINotification *notification_ID5=[[SFINotification alloc]init];
            notification_ID5.notificationId=2;
            notification_ID5.externalId=@"12";
            
            notification_ID5.almondMAC=@"1234543210987890";
            notification_ID5.time=5;
            notification_ID5.deviceName=@"colour sense";
            notification_ID5.deviceId=5;
            notification_ID5.deviceType=SFIDeviceType_ColorControl_29;
            notification_ID5.valueIndex=1;
            
            notification_ID5.valueType=SFIDevicePropertyType_SWITCH_BINARY;//propertytype
            notification_ID5.value=@"false";
            notification_ID5.debugCounter=3;
            notification_ID5.viewed=YES;
            
            NSArray *notificationarray=[[NSArray alloc]initWithObjects:notification,notification_1,switchMultilevelNotification3,switchMultilevelNotification4,nil];
            NotificationListResponse *notificationlist=[NotificationListResponse new];
            notificationlist.requestId=@"12aaa12eee2eeffb1024";
            notificationlist.pageState=@"12345";
            notificationlist.notifications=notificationarray;
            notificationlist.newCount=4;
            

            [dc callDummyCloud:notificationlist commandType:CommandType_DEVICELOG_RESPONSE];
           // [dc callDummyCloud:notificationlist commandType:CommandType_DEVICELOG_RESPONSE];
            
            break;
        }
        case CommandType_NOTIFICATIONS_CLEAR_COUNT_REQUEST:{
            
        }
        
        case CommandType_ALMOND_NAME_CHANGE_REQUEST:{
            
            AlmondNameChange *namechange=cmd.command;
            
            AlmondNameChangeResponse *namechangeresp=[[AlmondNameChangeResponse alloc]init];
            namechangeresp.internalIndex=[NSString stringWithFormat:@"%d",namechange.correlationId];
            namechangeresp.isSuccessful=true;

            [dc callDummyCloud:namechangeresp commandType:CommandType_ALMOND_NAME_CHANGE_RESPONSE];
            break;
    
        }
    
        case CommandType_UPDATE_REQUEST:{
            
            NSLog(@"update request command type: %@", cmd.command);
            NSLog(@"update request");
            NSData *jsondata = [cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary * mainDict = [jsondata objectFromJSONData];
            NSString *requestType =  [mainDict valueForKey:@"CommandType"];
            NSInteger mii = [[mainDict valueForKey:@"MobileInternalIndex"] integerValue];
            NSLog(@"main dict update: %@", mainDict);
            dummyCloudEndpoint *dc = [[dummyCloudEndpoint alloc] init];
            Network *network = [[Network alloc] init];
            dc.delegate = network;
          
            if([requestType isEqualToString:@"SetScene"]){
                
                NSLog(@"set scene cloud");
                
                NSString *createSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"SET_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\" ,\"ReasonCode\":\"0\"}", (long)mii];
                NSData *createSceneResponseData = [createSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:createSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                            NSLog(@"dynamic set update scene");
                NSInteger sceneID = [[mainDict valueForKey:@"ID"] integerValue];
                NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
                NSString *sceneEntryList = [mainDict valueForKey:@"SceneEntryList"];
               NSLog(@"cloud dynamic set scene entry list:%@", sceneEntryList);
              NSLog(@"scene entry list after:%@", sceneEntryList);
             NSString *dynamcideleteSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSetScene\",\"HashNow\": \"44c1d03821da8d6a089d2fd5b0e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%ld\",\"Active\":\"true\",\"Name\":\"Scene1022\",\"LastActiveEpoch\":\"251176214925585\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\",\"Valid\":\"true\"},{\"DeviceID\":\"4\",\"Index\":\"1\",\"Value\":\"78\",\"Valid\":\"true\"}]}}", almondplusMAC, (long)sceneID];
               NSData *DynamicDeleteSceneResponseData = [dynamcideleteSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:DynamicDeleteSceneResponseData commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
           }
           else if([requestType isEqualToString:@"CreateScene"]){
                NSLog(@"cloud create scene");
                NSString *setSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"CREATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                NSData *setSceneResponseData = [setSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:setSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
                NSLog(@"almondplusmac: %@", almondplusMAC);
                NSArray *sceneEntryList = [mainDict valueForKey:@"SceneEntryList"];
                NSDictionary *sceneDict = sceneEntryList[0];
            
                NSInteger randomDeviceValue;
                randomDeviceValue = arc4random() % 100000;
                
                NSString *sceneName = [mainDict valueForKey:@"SceneName"];
          
                NSLog(@"cloud dynamic create scene entry list:%@", sceneDict);
             
                NSString *dynamicCreateScene = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicCreateScene\",\"HashNow\":\"44c1d03821da8d6a089d2fd5b0e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%ld\",\"Active\":\"true\",\"SceneName\":\"%@\",\"LastActiveEpoch\":\"251176214925585\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\",\"Valid\":\"true\"},{\"DeviceID\":\"4\",\"Index\":\"1\",\"Value\":\"78\",\"Valid\":\"false\"}]}}", almondplusMAC, (long)randomDeviceValue, sceneName];
               
              NSData *DynamicCreateSceneResponseData = [dynamicCreateScene dataUsingEncoding:NSUTF8StringEncoding];
                
                [dc callDummyCloud:DynamicCreateSceneResponseData commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
            }
            else if([requestType isEqualToString:@"DeleteScene"]){
                NSString *deleteSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"DELETE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                
                NSData *deleteSceneResponseData = [deleteSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                
                [dc callDummyCloud:deleteSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                NSLog(@"dynamic delete");
                NSInteger sceneID = [[mainDict valueForKey:@"ID"] integerValue];
                NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
                NSString *dynamcideleteSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicSceneRemoved\",\"Scenes\":{\"ID\":\"%ld\"},\"HashNow\":\"46a5sd4fa65sd4f\",\"AlmondMAC\":\"%@\"}",(long)sceneID, almondplusMAC];
                NSData *DynamicDeleteSceneResponseData = [dynamcideleteSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:DynamicDeleteSceneResponseData commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
            }
          else if([requestType isEqualToString:@"ActivateScene"]){
                
                NSLog(@"activate scene");
                NSString *activateSceneResponse = [NSString stringWithFormat:@"{\"MobileCommand\":\"ACTIVATE_SCENE_RESPONSE\",\"MobileInternalIndex\":\"%ld\",\"Success\":\"true\",\"ReasonCode\":\"0\"}", (long)mii];
                NSData *activateSceneResponseData = [activateSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:activateSceneResponseData commandType:CommandType_COMMAND_RESPONSE];
                NSLog(@"main dict activate: %@", mainDict);
                NSString *sceneID = [mainDict valueForKey:@"ID"];
                NSString *almondplusMAC = [mainDict valueForKey:@"AlmondplusMAC"];
                NSString *dynamciActivateSceneResponse = [NSString stringWithFormat:@"{\"CommandType\":\"DynamicActivateScene\",\"HashNow\":\"44c1d03821da8d6a08e7301b\",\"AlmondMAC\":\"%@\",\"Scenes\":{\"ID\":\"%@\",\"Active\":\"true\",\"LastActiveEpoch\":\"251176214925585\"}}", almondplusMAC, sceneID];
                NSData *dynamciActivateSceneResponseData = [dynamciActivateSceneResponse dataUsingEncoding:NSUTF8StringEncoding];
              NSLog(@"main dict id %@ \n %@",[mainDict valueForKey:@"ID"],mainDict);
                [dc callDummyCloud:dynamciActivateSceneResponseData commandType:CommandType_DYNAMIC_SET_CREATE_DELETE_ACTIVATE_SCENE];
            }
            //add wifi update requests
            
            else if ([requestType isEqualToString:@"UpdateClient"]){
                
                NSLog(@"wifi update client");
                
                NSString *updateClient = [NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileCommandResponse\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}", (long)mii];
                NSData *updateClientResponseData = [updateClient dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:updateClientResponseData commandType:CommandType_COMMAND_RESPONSE];
                //dynamic update
                
                NSArray *clientsArray = [mainDict valueForKey:@"Clients"];
                NSDictionary *clientsDict = clientsArray[0];
                NSString *ID = [clientsDict valueForKey:@"ID"];
                NSString *Name = @"dynamic client1";
                NSString *MAC = [clientsDict valueForKey:@"MAC"];
                NSString *Connection = @"wired";
                NSString *Type = @"other";
                NSString *LastKnownIP = [clientsDict valueForKey:@"LastKnownIP"];
                NSString *Active = [clientsDict valueForKey:@"Active"];
                NSString *UseAsPresence = [clientsDict valueForKey:@"UseAsPresence"];
                NSString *almondMac = [mainDict valueForKey:@"AlmondMAC"];
                NSLog(@"id: %@", ID);
                NSLog(@"dynamic client update");
                //changing command type from "DynamicClientUpdate" to "ClientUpdate"
                NSString *dynamciClientUpdate = [NSString stringWithFormat:@"{\"CommandType\":\"ClientUpdate\",\"Clients\":[{\"ID\":\"%@\",\"Name\":\"%@\",\"MAC\":\"%@\",\"Connection\":\"%@\",\"Type\":\"%@\",\"LastKnownIP\":\"%@\",\"Active\":\"%@\",\"UseAsPresence\":\"%@\"}],\"AlmondMAC\":\"%@\",\"HashNow\":\"7efeb1a4da6e3ddd2b4e352bea828d04\"}", ID, Name, MAC, Connection, Type, LastKnownIP, Active, UseAsPresence, almondMac];
                NSLog(@"dynamicClientUpdate: %@", dynamciClientUpdate);
                NSData *dynamicData = [dynamciClientUpdate dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:dynamicData commandType:CommandType_DYNAMIC_CLIENT_UPDATE_REQUEST];
            }
            else if ([requestType isEqualToString:@"RemoveClient"]){
            
                NSLog(@"wifi remove client");
                NSString *removeClient = [NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileCommandResponse\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}", (long)mii];
                NSData *removeClientResponseData = [removeClient dataUsingEncoding:NSUTF8StringEncoding];
                
                [dc callDummyCloud:removeClientResponseData commandType:CommandType_COMMAND_RESPONSE];
                                NSArray *clientsArray = [mainDict valueForKey:@"Clients"];
                
                NSDictionary *clientsDict = clientsArray[0];
                NSLog(@"main dict %@", mainDict);
                NSLog(@"clients dict: %@", clientsDict);
                NSString *clientID = [clientsDict valueForKey:@"ID"];
                NSString *MAC = [clientsDict valueForKey:@"MAC"];
                NSString *almondMac = [mainDict valueForKey:@"AlmondMAC"];
                NSLog(@"MAC: %@", MAC);
                NSLog(@"almond mac: %@", almondMac);
                //changing command type from "DynamicClientUpdate" to "RemoveClient"
                NSString *dynamciremove = [NSString stringWithFormat:@"{\"CommandType\":\"RemoveClient\",\"AlmondMAC\":\"%@\",\"Clients\":[{\"ID\":\"%@\",\"MAC\":\"%@\"}],\"HashNow\":\"7efeb1a4da6e3ddd2b4e352bea828d04\"}", almondMac, clientID, MAC];
                NSLog(@"dynamicremove: %@", dynamciremove);
                                NSData *dynamicData = [dynamciremove dataUsingEncoding:NSUTF8StringEncoding];
                [dc callDummyCloud:dynamicData commandType:CommandType_DYNAMIC_CLIENT_REMOVE_REQUEST];
            }
            break;
        }
        case CommandType_GET_ALL_SCENES:{
            
            NSLog(@"get all scenes");
            
            NSLog(@"command: %@", cmd.command);
      
            NSString *getAllSceneRequestJSON = @"{\"AlmondplusMAC\":\"251176217041064\",\"MobileCommand\":\"LIST_SCENE_RESPONSE\",\"Success\":\"true\",\"Scenes\":[{\"Active\":\"false\",\"ID\":\"1\",\"SceneName\":\"First Scene\",\"SceneEntryList\":[]},{\"Active\":\"true\",\"ID\":\"10\",\"SceneName\":\"Scene10\",\"SceneEntryList\":[]},{\"ID\":\"1022\",\"Active\":\"true\",\"SceneName\":\"Scene1022\",\"SceneEntryList\":[{\"DeviceID\":\"1\",\"Index\":\"1\",\"Value\":\"false\"}]}]}";
    
            NSData *jsondata = [getAllSceneRequestJSON dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:jsondata commandType:CommandType_LIST_SCENE_RESPONSE];
            break;
        }
           case CommandType_WIFI_CLIENTS_LIST_REQUEST:
        {
            NSData *da1=[cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict1=[da1 objectFromJSONData];
            NSString *commandtype=[dict1 valueForKey:@"CommandType"];
            NSInteger mobilecommand=[[dict1 valueForKey:@"MobileInternalIndex"]integerValue];
            NSLog(@"MobileInternalIndex %ld",(long)mobilecommand);
            NSString *wificlientdata=[NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\",\"Clients\":[{\"ID\":\"1\",\"Name\": \"Mydevice\",\"Connection\": \"wired\",\"MAC\": \"1c:75:08:32:2a:6d\",\"Type\": \"iPad\",\"LastKnownIP\": \"10.2.2.11\",\"Active\": \"true\",\"UseAsPresence\": \"true\"},{\"ID\":\"1\",\"Name\": \"Mydevice2\",\"Connection\": \"wired\",\"MAC\": \"1c:75:65:32:2a:11\",\"Type\": \"TV\",\"LastKnownIP\": \"10.2.3.55\",\"Active\": \"true\",\"UseAsPresence\": \"true\"},{\"ID\":\"1\",\"Name\": \"Mydevice2\",\"Connection\": \"wired\",\"MAC\": \"1c:75:08:32:2a:6d\",\"Type\": \"PC\",\"LastKnownIP\": \"10.2.2.11\",\"Active\": \"true\",\"UseAsPresence\": \"true\"}]}",(long)mobilecommand];
            NSData *wificlientdarta=[wificlientdata dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:wificlientdarta commandType:CommandType_WIFI_CLIENTS_LIST_RESPONSE];
            break;
        }

        case CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST:
        {
            NSData *da1=[cmd.command dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict1=[da1 objectFromJSONData];
            NSString *commandtype=[dict1 valueForKey:@"CommandType"];
            NSInteger mobilecommand=[[dict1 valueForKey:@"MobileInternalIndex"]integerValue];
            NSLog(@"MobileInternalIndex %ld",(long)mobilecommand);
            NSLog(@"sending wifi data");
            NSString *wificlientupdate=[NSString stringWithFormat:@"{\"Success\":\"true\",\"MobileInternalIndex\":\"%ld\",\"ReasonCode\":\"0\"}",(long)mobilecommand];
            NSData *wificlientupdate_data=[wificlientupdate dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:wificlientupdate_data commandType:CommandType_WIFI_CLIENT_UPDATE_PREFERENCE_REQUEST];
            break;
        }
        case CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST:{
            
            NSString *getwifi_prefernce=@"{\"Success\":\"true\",\"ReasonCode\":\"0\",\"ClientPreferences\":[{\"ClientID\":1,\"NotificationType\":2}]}";
            NSData *getwifipreference=[getwifi_prefernce dataUsingEncoding:NSUTF8StringEncoding];
            [dc callDummyCloud:getwifipreference commandType:CommandType_WIFI_CLIENT_GET_PREFERENCE_REQUEST];
            break;
        }
            
        default:
            break;
    }
  
}

// builds the SFIDevicePropertyType to values look up table
- (NSDictionary*)buildLookupTable:(NSArray*)knownValues {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (SFIDeviceKnownValues *values in knownValues) {
        // lookup by two keys: property ID and name
        // some properties such as PIN codes for a door lock do not have a well-defined property type ID
        // as they are synthesized based on a common property type and then an index number; in their case,
        // only a lookup by property name will yield a result.
        NSNumber *key = @(values.propertyType);
        dict[key] = values;
        NSLog(@"keys===%@",key);
        NSString *value = values.valueName;
        if (value != nil) {
            dict[value] = values;
            NSLog(@" dict[value] %@",dict[value]);
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

//-(SFIDevice *)createdevice:(SFIDeviceType*)devicetype DeviceID1:(sfi_id)DeviceID OZWNode1:(NSString *)OZWNode zigBeeEUI641:(NSString *)zigBeeEUI64 zigBeeShortID1:(NSString*)zigBeeShortID deviceTechnology1:(unsigned int*)deviceTechnology associationTimestamp1:(NSString*)associationTimestamp deviceTechnology1:(unsigned int allowNotification1:(NSString*)allowNotification location1:(NSString)location valueCount1:(unsigned int*)valueCount deviceFunction1:(NSString*)deviceFunction valueCount1:(unsigned int*)valueCount deviceTypeName1:(NSString *)deviceTypeName friendlyDeviceType1:(NSString *)friendlyDeviceType deviceName1:(NSString*)deviceName
//{
//    
//}

-(SFINotification*)createnotification:(long )notificationId externalIDa:(NSString*)externalID almondMACa:(NSString*)almondMAC timea:(NSTimeInterval)time devicenamea:(NSString*)devicename deviceida:(unsigned int)deviceID devicetypea:(unsigned int)devicetype valueindexa:(unsigned int)valueindex valuetypea:(unsigned int)valuetype valuea:(NSString*)value vieweda:(BOOL)viewed debugcountera:(long)debugcounter{
    
    
    
    SFINotification *notification=[[SFINotification alloc]init];
    notification.notificationId=notificationId;
    notification.externalId=externalID;
    
    notification.almondMAC=almondMAC;
    notification.time=time;
    notification.deviceName=devicename;
    notification.deviceId=deviceID;
    notification.deviceType=devicetype;
    notification.valueIndex=valueindex;
    
    notification.valueType=valuetype;//propertytype
    notification.value=value;
    notification.debugCounter=3;
    notification.viewed=viewed;
    notification.debugCounter=debugcounter;
    return notification;
}




-(SFIDeviceKnownValues*)settingknownvalues:(unsigned int)index propertytypea:(unsigned int)propertytype valuetypea:(NSString*)valurtype valuea:(NSString*)value valuenamea:(NSString*)valuename{
    
    SFIDeviceKnownValues *knownvalues1=[[SFIDeviceKnownValues alloc]init];
    knownvalues1.index=index;
    knownvalues1.propertyType=propertytype;
    knownvalues1.valueType=valurtype;
    knownvalues1.value=value;
    knownvalues1.valueName=valuename;
    return knownvalues1;
}


@end
