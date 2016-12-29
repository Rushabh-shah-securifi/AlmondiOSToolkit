//
//  AlmondManagement_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Securifitoolkit.h"
#import "ConnectionStatus.h"
#import "KeyChainAccess.h"
#import "Network.h"
#import "AlmondManagement.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "LocalNetworkManagement.h"
#import "Login.h"
#import "SFISecondaryUser.h"


@interface AlmondManagement_m_Tests : XCTestCase

@property BOOL currentAlmondDidChange;

@end

@interface AlmondManagement (Testing)

+(void) fillAlmondListWithAlmondListDataResponse: (NSArray*)almondAffiliationResponse intoDictionary:(NSMutableDictionary*)almondListData;

+(void) fillAlmondListWithAffiliationDataResponse:(NSArray*)almondListResponse intoDictionary:(NSMutableDictionary*)almondListData;

+ (void)onAlmondListAndAffiliationDataResponse:(NSData*)responseData network:(Network *)network;

@end

@implementation AlmondManagement_m_Tests

- (void)setUp {
    [super setUp];
    _currentAlmondDidChange = false;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    _currentAlmondDidChange = false;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void) authenticate{
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    XCTAssertEqual([toolkit isCloudReachable], YES);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    [toolkit tearDownLoginSession];
    
    [toolkit asyncInitNetwork];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        NSString* email = @"murali.kurapati@securifi.com";
        NSString* password = @"000000";
        //set the username and password so that it have credentials
        [KeyChainAccess setSecEmail:email];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:kPREF_USER_DEFAULT_LOGGED_IN_ONCE];
        
        Login *loginCommand = [Login new];
        loginCommand.UserID = email;
        loginCommand.Password = password;
        
        GenericCommand *cmd = [GenericCommand new];
        cmd.commandType = CommandType_LOGIN_COMMAND;
        cmd.command = loginCommand;
        NSLog(@"before sending the login command");
        [toolkit asyncSendToNetwork:cmd];
    });
}

-(void) onCurrentAlmondDidChange{
    NSLog(@"CurrentAlmondDidChange is called");
    _currentAlmondDidChange = true;
}


#pragma mark - Almond Management Test cases

-(void) testWriteCurrentAlmond {
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusName = @"TestCasesAlmond";
    [AlmondManagement writeCurrentAlmond:almond];
    NSString* currentAlmondName = [AlmondManagement currentAlmond].almondplusName;
    XCTAssertEqualObjects(@"TestCasesAlmond", currentAlmondName);
}


-(void) testSetCurrentAlmond {
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Testing testSetCurrentAlmond"];
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(onCurrentAlmondDidChange) name:kSFIDidChangeCurrentAlmond object:nil];
    
    [AlmondManagement setCurrentAlmond:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertFalse(_currentAlmondDidChange);
        SFIAlmondPlus* almond = [SFIAlmondPlus new];
        [AlmondManagement setCurrentAlmond:almond];
    });
    
    //testing if the notification is called
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(_currentAlmondDidChange);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error){
        NSLog(@"exception is not fulfilled within the timeout");
    }];
}


#pragma mark - Almond List management
-(void) testfillAlmondListWithAlmondListDataResponse {
    
    NSArray* almondListDataResponse = @[@{@"AlmondName":@"almondName" ,@"AlmondMAC":@"251176220099140" ,@"FirmwareVersion":@"AL3-R008dp",@"Ownership":@"P"},@{@"AlmondName":@"sat@AL2",@"AlmondMAC":@"251176215907164",@"FirmwareVersion":@"AL2-R095z",@"Ownership":@"S"},@{@"AlmondName":@"Almond+ Sfi",@"AlmondMAC":@"251176217032880",@"FirmwareVersion":@"AP2-R089aw-L009-W016-ZW016-ZB005-BETA",@"Ownership":@"S"}];
    
    NSMutableDictionary* almondListData = [NSMutableDictionary new];
    
    [AlmondManagement fillAlmondListWithAlmondListDataResponse:almondListDataResponse intoDictionary:almondListData];
    
    SFIAlmondPlus* almond = almondListData[@"251176220099140"];
    XCTAssertEqualObjects(almond.almondplusName, @"almondName");
    XCTAssertEqualObjects(almond.firmware, @"AL3-R008dp");
    XCTAssertEqual(almond.isPrimaryAlmond, 1);
    XCTAssertNil(almond.ownerEmailID);
    XCTAssertNil(almond.accessEmailIDs);
    
    almond = almondListData[@"251176215907164"];
    XCTAssertEqualObjects(almond.almondplusName, @"sat@AL2");
    XCTAssertEqualObjects(almond.firmware, @"AL2-R095z");
    XCTAssertEqual(almond.isPrimaryAlmond, 0);
    XCTAssertNil(almond.ownerEmailID);
    XCTAssertNil(almond.accessEmailIDs);

    
    almond = almondListData[@"251176217032880"];
    XCTAssertEqualObjects(almond.almondplusName, @"Almond+ Sfi");
    XCTAssertEqualObjects(almond.firmware, @"AP2-R089aw-L009-W016-ZW016-ZB005-BETA");
    XCTAssertEqual(almond.isPrimaryAlmond, 0);
    XCTAssertNil(almond.ownerEmailID);
    XCTAssertNil(almond.accessEmailIDs);
    
}

-(void) testFillAlmondAffiliationDataResponseIntoAlmondList {
    
    NSArray* almondListDataResponse = @[@{@"AlmondMAC":@"251176220099140",@"EmailID":@[@{@"UserID":@"522255655",@"SecondaryEmail":@"murali.kurapati@securifi.com"},@{@"UserID":@"522268840",@"SecondaryEmail":@"test@gmail.com"},@{@"UserID":@"106212",@"SecondaryEmail":@"krishnendu.s@securifi.com"}]},@{@"AlmondMAC":@"251176217032880",@"OwnerEmailID":@"krishnendu.s@securifi.com"}];
    
    NSMutableDictionary* almondListData = [NSMutableDictionary new];
    
    [AlmondManagement fillAlmondListWithAffiliationDataResponse:almondListDataResponse intoDictionary:almondListData];
    
    SFIAlmondPlus* almond = almondListData[@"251176220099140"];
    XCTAssertNil(almond.almondplusName);
    XCTAssertNil(almond.firmware);
    XCTAssertEqual(almond.isPrimaryAlmond, 0);
    XCTAssertNil(almond.ownerEmailID);
    XCTAssertEqual(almond.accessEmailIDs.count , 3);
    
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[0])).userId, @"522255655");
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[0])).emailId, @"murali.kurapati@securifi.com");
    
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[1])).userId, @"522268840");
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[1])).emailId, @"test@gmail.com");
    
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[2])).userId, @"106212");
    XCTAssertEqualObjects(((SFISecondaryUser*)(almond.accessEmailIDs[2])).emailId, @"krishnendu.s@securifi.com");

    almond = almondListData[@"251176217032880"];
    XCTAssertNil(almond.almondplusName);
    XCTAssertNil(almond.firmware);
    XCTAssertEqual(almond.isPrimaryAlmond, 0);
    XCTAssertEqualObjects(almond.ownerEmailID , @"krishnendu.s@securifi.com");
    XCTAssertEqual(almond.accessEmailIDs.count , 0);
}

-(void) testOnAlmondListAndAffiliationDataResponse {
    
    AlmondManagement* almondManagment = [AlmondManagement new];
    
    id mockedAlmondManagement = [OCMockObject partialMockForObject:almondManagment];
    
    [[mockedAlmondManagement expect] fillAlmondListWithAlmondListDataResponse: nil intoDictionary:nil];
    
    [[mockedAlmondManagement reject] fillAlmondListWithAffiliationDataResponse: nil intoDictionary:nil];
    
    NSMutableDictionary* response = [NSMutableDictionary new];
    
    response[@"CommandType"] = @"AlmondListResponse";
    
    Network* network;
    
    [mockedAlmondManagement onAlmondListAndAffiliationDataResponse:response network:network];
    
    [mockedAlmondManagement verify];
    
    [[mockedAlmondManagement reject] fillAlmondListWithAlmondListDataResponse: nil intoDictionary:nil];
    
    [[mockedAlmondManagement expect] fillAlmondListWithAffiliationDataResponse: nil intoDictionary:nil];

    response[@"CommandType"] = @"AlmondAffiliationData";
    
    [mockedAlmondManagement onAlmondListAndAffiliationDataResponse:response network:network];
    
    [mockedAlmondManagement verify];
}


-(void) testLocalLinkedAlmondList {
    
    //creating three cloud almonds and three local almond where two local almonds are only present in local and one local almond is present in both cloud and local networks
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray* almondList = [NSMutableArray new];
    SFIAlmondPlus* cloudAlmond1 = [SFIAlmondPlus new];
    SFIAlmondPlus* cloudAlmond2 = [SFIAlmondPlus new];
    SFIAlmondPlus* cloudAlmond3 = [SFIAlmondPlus new];
    
    cloudAlmond1.almondplusMAC = @"cloudAlmond1";
    cloudAlmond2.almondplusMAC = @"cloudAlmond2";
    cloudAlmond3.almondplusMAC = @"cloudLocalAlmond3";
    
    [almondList addObject:cloudAlmond1];
    [almondList addObject:cloudAlmond2];
    [almondList addObject:cloudAlmond3];
    
    [toolkit.dataManager writeAlmondList: almondList];
    
    SFIAlmondLocalNetworkSettings* localAlmond1 = [SFIAlmondLocalNetworkSettings new];
    localAlmond1.almondplusMAC = @"localAlmond1";
    [toolkit.dataManager writeAlmondLocalNetworkSettings:localAlmond1];
    
    SFIAlmondLocalNetworkSettings* localAlmond2 = [SFIAlmondLocalNetworkSettings new];
    localAlmond2.almondplusMAC = @"localAlmond2";
    [toolkit.dataManager writeAlmondLocalNetworkSettings:localAlmond2];
    
    SFIAlmondLocalNetworkSettings* localAlmond3 = [SFIAlmondLocalNetworkSettings new];
    localAlmond3.almondplusMAC = @"cloudLocalAlmond3";
    [toolkit.dataManager writeAlmondLocalNetworkSettings:localAlmond3];
    
    //Testing this method
    NSArray* localList = [AlmondManagement localLinkedAlmondList];
    
    for(SFIAlmondPlus* almond in localList){
        if([almond.almondplusMAC isEqualToString:@"localAlmond1"]){
            XCTAssertEqual(almond.linkType, SFIAlmondPlusLinkType_local_only);
        }else if([almond.almondplusMAC isEqualToString:@"localAlmond2"]){
            XCTAssertEqual(almond.linkType, SFIAlmondPlusLinkType_local_only);
        }else if([almond.almondplusMAC isEqualToString:@"cloudLocalAlmond3"]){
            XCTAssertEqual(almond.linkType, SFIAlmondPlusLinkType_cloud_local);
        }
    }
}


-(void) testManageCurrentAlmondOnAlmondListUpdate_CloudConnection{
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    NSMutableArray* almondList = [NSMutableArray new];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SFIAlmondPlus* singleAlmond = [SFIAlmondPlus new];
        singleAlmond.almondplusMAC = @"SingleAlmond";
        [almondList addObject:singleAlmond];
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        XCTAssertEqualObjects([AlmondManagement currentAlmond].almondplusMAC, @"SingleAlmond");
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(17.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [almondList removeAllObjects];
        SFIAlmondPlus *firstAlmond = [SFIAlmondPlus new];
        firstAlmond.almondplusMAC = @"firstAlmond";
        SFIAlmondPlus* secondAlmond = [SFIAlmondPlus new];
        secondAlmond.almondplusMAC = @"secondAlmond";
        SFIAlmondPlus* thirdAlmond = [SFIAlmondPlus new];
        thirdAlmond.almondplusMAC = @"thirdAlmond";
        [almondList addObject:firstAlmond];
        [almondList addObject:secondAlmond];
        [almondList addObject:thirdAlmond];
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        XCTAssertEqualObjects([AlmondManagement currentAlmond].almondplusMAC, @"firstAlmond");
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(18.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [almondList removeAllObjects];
        SFIAlmondPlus *firstAlmond = [SFIAlmondPlus new];
        firstAlmond.almondplusMAC = @"firstAlmond";
        SFIAlmondPlus* secondAlmond = [SFIAlmondPlus new];
        secondAlmond.almondplusMAC = @"secondAlmond";
        SFIAlmondPlus* thirdAlmond = [SFIAlmondPlus new];
        thirdAlmond.almondplusMAC = @"thirdAlmond";
        SFIAlmondPlus* currentAlmond = [SFIAlmondPlus new];
        currentAlmond.almondplusMAC = @"CurrentAlmond";
        [almondList addObject:firstAlmond];
        [almondList addObject:secondAlmond];
        [almondList addObject:thirdAlmond];
        [almondList addObject:currentAlmond];
        [AlmondManagement writeCurrentAlmond:currentAlmond];
        NSLog(@"current almond name in testing %@:",[AlmondManagement currentAlmond].almondplusName);
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        NSLog(@"current almond name in testing %@:",[AlmondManagement currentAlmond].almondplusName);
        XCTAssertEqualObjects([AlmondManagement currentAlmond].almondplusMAC, @"CurrentAlmond");
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:19.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}



- (void)testSuggestionsFromNetworkStateAndConnectiontype{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    struct PopUpSuggestions data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"Alert view fail-Cloud connection to your Almond failed. Tap retry or switch to local connection.", @"Cloud connection to your Almond failed. Tap retry or switch to local connection."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"switch_local", @"Switch to Local Connection"));
    XCTAssertEqualObjects(data.subTitle2, @"Retry Cloud Connection");
    
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"local_conn_failed_retry", "Local connection to your Almond failed. Tap retry or switch to cloud connection."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"alert title offline Local Retry Local Connection", @"Retry Local Connection"));
    XCTAssertEqualObjects(data.subTitle2, NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection"));
    
    
    [ConnectionStatus setConnectionStatusTo:AUTHENTICATED];
    [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"alert.message-Connected to your Almond via local.", @"Connected to your Almond via local."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"switch_cloud", @"Switch to Cloud Connection"));
    XCTAssertNil(data.subTitle2);
    
    [ConnectionStatus setConnectionStatusTo:AUTHENTICATED];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusMAC = @"TestingAlmondMAC";
    [AlmondManagement writeCurrentAlmond:almond];
    
    data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings"));
    XCTAssertTrue(data.presentLocalNetworkSettings);
    XCTAssertNil(data.subTitle2);
    
}


@end
