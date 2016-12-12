//
//  SecurifiToolkitTests.m
//  SecurifiToolkitTests
//
//  Created by Masood on 11/10/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCmock/OCMock.h>
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
}


- (void)tearDown {
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


- (void)testAsyncInitNetwork {
    
    SecurifiToolkit* toolkit = [[SecurifiToolkit alloc] init];
    
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    
    id mock = [OCMockObject partialMockForObject:toolkit];
    
    [[mock expect] setUpNetwork];
    
    [mock asyncInitNetwork];
    
    [mock verify];
    
    [ConnectionStatus setConnectionStatusTo:CONNECTED_TO_NETWORK];
    
    [[mock reject] setUpNetwork];
    
    [mock asyncInitNetwork];
    
    [mock verify];
    
    [ConnectionStatus setConnectionStatusTo:IS_CONNECTING_TO_NETWORK];
    
    [[mock reject] setUpNetwork];
    
    [mock asyncInitNetwork];
    
    [mock verify];
    
    [ConnectionStatus setConnectionStatusTo:AUTHENTICATED];
    
    [[mock reject] setUpNetwork];
    
    [mock asyncInitNetwork];
    
    [mock verify];
}


-(void)testSetConnectionMode {
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    id mock = [OCMockObject partialMockForObject:toolkit];
    
    [[mock expect] tryShutdownAndStartNetworks];
    
    [mock setConnectionMode:SFIAlmondConnectionMode_cloud];
    
    [mock verify];
    
    XCTAssertEqual([toolkit currentConnectionMode], SFIAlmondConnectionMode_cloud);
    
    [[mock expect] tryShutdownAndStartNetworks];
    
    [mock setConnectionMode:SFIAlmondConnectionMode_local];
    
    [mock verify];
    
    XCTAssertEqual([toolkit currentConnectionMode], SFIAlmondConnectionMode_local);
}

-(void) testTearDownNetwork {
    SecurifiToolkit* toolkit = [SecurifiToolkit new];
    toolkit.network = [Network new];
    [toolkit tearDownNetwork];
    XCTAssertNil(toolkit.network);
    XCTAssertNil(toolkit.network.delegate);
    XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
    
    id mockToolkit = [OCMockObject partialMockForObject:toolkit];
    [[mockToolkit expect] cleanUp];
    [mockToolkit tearDownNetwork];
    [mockToolkit verify];
}


-(void) testTryShutDownAndRestartNetwork {
    
    SecurifiToolkit* toolkit = [[SecurifiToolkit alloc] init];
    toolkit.config.enableLocalNetworking = YES;
    
    SecurifiConfigurator* config = [SecurifiConfigurator new];
    config.enableLocalNetworking = YES;
    id mock = [OCMockObject partialMockForObject:toolkit];
    OCMStub([mock config]).andReturn(config);
    
    [[mock expect] tearDownNetwork];
    
    [[mock expect] asyncInitNetwork];
    
    [mock tryShutdownAndStartNetworks];
    
    [mock verify];
    
    config.enableLocalNetworking = NO;
    OCMStub([mock config]).andReturn(config);
    
    [[mock reject] tearDownNetwork];
    
    [[mock reject] asyncInitNetwork];
    
    [mock verify];
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
    
    SFIAlmondLocalNetworkSettings* settings = [SFIAlmondLocalNetworkSettings new];
    settings.almondplusMAC = @"TestingAlmondMAC";
    [[SecurifiToolkit sharedInstance].dataManager writeAlmondLocalNetworkSettings:settings];
    
    data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"alert.message-Connected to your Almond via cloud.", @"Connected to your Almond via cloud."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"switch_local", @"Switch to Local Connection"));
    XCTAssertFalse(data.presentLocalNetworkSettings);
    XCTAssertNil(data.subTitle2);
    
    [LocalNetworkManagement clearLocalNetworkSettings];
    
    data = [toolkit suggestionsFromNetworkStateAndConnectiontype];
    
    XCTAssertEqualObjects(data.title, NSLocalizedString(@"alert msg offline Local connection not supported.", @"Local connection settings are missing."));
    XCTAssertEqualObjects(data.subTitle1, NSLocalizedString(@"Add Local Connection Settings", @"Add Local Connection Settings"));
    XCTAssertTrue(data.presentLocalNetworkSettings);
    XCTAssertNil(data.subTitle2);
}


@end
