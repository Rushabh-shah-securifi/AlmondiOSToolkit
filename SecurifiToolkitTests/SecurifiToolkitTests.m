//
//  SecurifiToolkitTests.m
//  SecurifiToolkitTests
//
//  Created by Masood on 11/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Securifitoolkit.h"
#import "ConnectionStatus.h"
#import "KeyChainAccess.h"
#import "Network.h"
#import "AlmondManagement.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "LocalNetworkManagement.h"
#import "Login.h"

@interface SecurifiToolkitTests : XCTestCase

@end

@implementation SecurifiToolkitTests

- (void)setUp {
    [super setUp];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onReachabilityChanged) name:kSFIReachabilityChangedNotification object:nil];
    NSLog(@"SetUp method is called");
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

-(void)onReachabilityChanged {
    NSLog(@"onReachabilityChanged is called from test cases");
    if(![SecurifiToolkit sharedInstance].isCloudReachable){
        XCTAssertTrue(false);
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(onReachabilityChanged) name:kSFIReachabilityChangedNotification object:nil];
    }
}

-(void) testingInternetDown {
    while(true){
        [NSThread sleepForTimeInterval:100];
    }
}

- (void)tearDown {
    NSLog(@"tearDown method is called");
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - toolkit methods

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


-(void)testUserAuthentication_Cloud {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    [self authenticate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:16.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


- (void)testAsyncInitNetwork_withOutLoginCredential_withOutNetwork {
    
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [toolkit tearDownLoginSession];
    
    [toolkit asyncInitNetwork];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:11.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void)testAsyncInitNetwork_withLoginCredentials_withOutNetwork {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [self authenticate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
        [toolkit asyncInitNetwork];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(21.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:22.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

//if the network is already in connecting or connected or Authenticated it should not retry the connection
-(void) testAsyncInitNetwork_ForConnectionsStates_OtherThan_NO_NETWORK_CONNECTION{
    [ConnectionStatus setConnectionStatusTo:IS_CONNECTING_TO_NETWORK];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncInitNetwork];
    
    XCTAssertEqual([ConnectionStatus getConnectionStatus], IS_CONNECTING_TO_NETWORK);
    
    [ConnectionStatus setConnectionStatusTo:CONNECTED_TO_NETWORK];
   
    [toolkit asyncInitNetwork];
    
    XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
    
    [ConnectionStatus setConnectionStatusTo:AUTHENTICATED];
    
    [toolkit asyncInitNetwork];
    
    XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
}

-(void) testTearDownNetwork {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [toolkit asyncInitNetwork];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"logging1 is called");
        if(toolkit.isCloudReachable){
            if([KeyChainAccess hasLoginCredentials])
                XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
            else
                XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
            [toolkit tearDownNetwork];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"logging2 is called");
            XCTAssertNil(toolkit.network);
            XCTAssertNil(toolkit.network.delegate);
            XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:12.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


-(void) testTryShutDownAndRestartNetwork_forCloudConnection{
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [self authenticate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toolkit tryShutdownAndStartNetworks];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:21.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

#pragma mark - Almond Management Test cases
-(void) testWriteCurrentAlmond {
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusName = @"TestCasesAlmond";
    [AlmondManagement setCurrentAlmond:almond];
    NSString* currentAlmondName = [AlmondManagement currentAlmond].almondplusName;
    XCTAssertEqualObjects(@"TestCasesAlmond", currentAlmondName);
}

-(void) testManageCurrentAlmondChange_CloudConnection {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [self authenticate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(14.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
        [expectation fulfill];
    });
    
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusName = @"UnKnownAlmondName";
    almond.almondplusMAC = @"UnknownAlmondMac";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlmondManagement manageCurrentAlmondChange:almond];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@ is the sceneslist in testmangeCurrentAlmondChange",toolkit.scenesArray);
        XCTAssertEqual(toolkit.scenesArray.count,0);
        XCTAssertEqual(toolkit.devices.count,0);
        XCTAssertEqual(toolkit.ruleList.count,0);
        XCTAssertEqual(toolkit.clients.count,0);
        XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
    });
    
    [self waitForExpectationsWithTimeout:28.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


#pragma mark - Almond List management

-(void) testManageCurrentAlmondOnAlmondListUpdate_CloudConnection{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    NSMutableArray* almondList = [NSMutableArray new];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SFIAlmondPlus* singleAlmond = [SFIAlmondPlus new];
        singleAlmond.almondplusMAC = @"SingleAlmond";
        [almondList addObject:singleAlmond];
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"SingleAlmond");
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
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"firstAlmond");
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
        NSLog(@"current almond name in testing %@:",[toolkit currentAlmond].almondplusName);
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        NSLog(@"current almond name in testing %@:",[toolkit currentAlmond].almondplusName);
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"CurrentAlmond");
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:19.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

#pragma mark - Local Network Mangement 

-(void) testStoreLocalNetworkSettings {
    SFIAlmondLocalNetworkSettings* settings = [SFIAlmondLocalNetworkSettings new];
    settings.almondplusName = @"TestingAlmondName";
    settings.almondplusMAC = @"TestinngAlmondMac";
    settings.host = @"Testinghost";
    settings.port = 1111;
    settings.login = @"TestingLogin";
    settings.password = @"TestingPassword";
    [LocalNetworkManagement storeLocalNetworkSettings:settings];
    SFIAlmondLocalNetworkSettings* localSettings = [LocalNetworkManagement localNetworkSettingsForAlmond:settings.almondplusMAC];
    XCTAssertNotNil(localSettings);
}

-(void) testRemoveLocalNetworkSettingsForAlmond {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SFIAlmondLocalNetworkSettings* settings = [SFIAlmondLocalNetworkSettings new];
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusName = @"TestingAlmondName";
    almond.almondplusMAC = @"TestingAlmondMac";
    settings.almondplusName = @"TestingAlmondName";
    settings.almondplusMAC = @"TestinngAlmondMac";
    settings.host = @"Testinghost";
    settings.port = 1111;
    settings.login = @"TestingLogin";
    settings.password = @"TestingPassword";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [LocalNetworkManagement storeLocalNetworkSettings:settings];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
        
        [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:settings.almondplusMAC];
        
        XCTAssertNil([LocalNetworkManagement localNetworkSettingsForAlmond:settings.almondplusMAC]);
        
        [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
        
        [LocalNetworkManagement storeLocalNetworkSettings:settings];
        
        [AlmondManagement writeCurrentAlmond:almond];
        
        [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:settings.almondplusMAC];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:22.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


-(void)testTryUpdateLocalNetworkSettingsForAlmond_withNoPreviousSettings{
    
    SFIRouterSummary* summary = [SFIRouterSummary new];
    summary.login = @"TestingLoginValue";
    summary.password = @"TestingPassword";
    summary.url = @"TestingUrl";
    
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusMAC = @"TestingAlmondMac";
    [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:almond.almondplusMAC];
    
    [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:almond.almondplusMAC withRouterSummary:summary];
    
    SFIAlmondLocalNetworkSettings* settings = [LocalNetworkManagement localNetworkSettingsForAlmond:almond.almondplusMAC];
    
    XCTAssertNil(settings.login);
    XCTAssertNil(settings.password);
    XCTAssertNil(settings.host);
}

//when the have some previous settings for the mac then it will override that settings with values from router summary
-(void)testTryUpdateLocalNetworkSettingsForAlmond_withPreviousSettings{

    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusMAC = @"TestingAlmondMac";
    
    SFIAlmondLocalNetworkSettings* oldSettings = [SFIAlmondLocalNetworkSettings new];
    oldSettings.host = @"OldTestingUrl";
    oldSettings.login = @"OldTestingLoginValue";
    oldSettings.password = @"OldTestingPassword";
    oldSettings.almondplusMAC = @"TestingAlmondMac";
    
    [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:almond.almondplusMAC];
    [LocalNetworkManagement storeLocalNetworkSettings:oldSettings];
    
    SFIRouterSummary* summary = [SFIRouterSummary new];
    summary.login = @"TestingLoginValue";
    summary.password = @"G8TNM78pxDqUYZ9K3tzfccmkL16LycEgk7dvD9ZHSlkmbGhBfPS6XDs2uSF7TjqunZF9TdXtWEcqrCujAJIgog==";
    summary.url = @"TestingUrl";
    summary.uptime = @"654321";
    
    [LocalNetworkManagement tryUpdateLocalNetworkSettingsForAlmond:almond.almondplusMAC withRouterSummary:summary];
    
    SFIAlmondLocalNetworkSettings* newSettings = [LocalNetworkManagement localNetworkSettingsForAlmond:almond.almondplusMAC];
    
    XCTAssertEqualObjects(newSettings.login, @"TestingLoginValue");
    char arrayChar[16];
    arrayChar[0] = 23;
    arrayChar[1] = 30;
    arrayChar[2] = 45;
    arrayChar[3] = 53;
    arrayChar[4] = 110;
    arrayChar[5] = 79;
    arrayChar[6] = 3;
    arrayChar[7] = 48;
    arrayChar[8] = 121;
    arrayChar[9] = 106;
    arrayChar[10] = 99;
    arrayChar[11] = 100;
    arrayChar[12] = 113;
    arrayChar[13] = 61;
    arrayChar[14] = 113;
    arrayChar[15] = 7;
    NSString *str = [NSString stringWithFormat:@"%s", arrayChar];
    XCTAssertEqualObjects(newSettings.password, str);
    XCTAssertEqualObjects(newSettings.host, @"TestingUrl");
    
}
@end
