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

@interface SecurifiToolkitTests : XCTestCase

@end

@implementation SecurifiToolkitTests

- (void)setUp {
    [super setUp];
    NSLog(@"SetUp method is called");
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    NSLog(@"tearDown method is called");
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAsyncInitNetwork {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [ConnectionStatus setConnectionStatusTo:NO_NETWORK_CONNECTION];
    
    XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
    
    [toolkit asyncInitNetwork];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        BOOL isCloudReachable = [toolkit isCloudReachable];
        ConnectionStatusType currentStatus = [ConnectionStatus getConnectionStatus];
        NSLog(@"end of the time block and the status value is %ld",(long)currentStatus);
        
        BOOL hasLoginCredentials = [KeyChainAccess hasLoginCredentials];
        if(isCloudReachable){
            if(!hasLoginCredentials){
                XCTAssertEqual(currentStatus, CONNECTED_TO_NETWORK);
            }else{
                XCTAssertEqual(currentStatus, AUTHENTICATED);
            }
        }else{
            XCTAssertEqual(currentStatus, NO_NETWORK_CONNECTION);
        }
        
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
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


-(void) testTryShutDownAndRestartNetwork{
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    [toolkit asyncInitNetwork];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toolkit tryShutdownAndStartNetworks];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(toolkit.isCloudReachable){
            if([KeyChainAccess hasLoginCredentials])
                XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
            else
                XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
            }else{
                XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
            }
            [expectation fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:12.0 handler:^(NSError *error) {
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


-(void) testManageCurrentAlmondChange {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    SFIAlmondPlus* almond = [SFIAlmondPlus new];
    almond.almondplusName = @"UnKnownAlmondName";
    almond.almondplusMAC = @"UnknownAlmondMac";
    [toolkit setConnectionMode:SFIAlmondConnectionMode_cloud];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlmondManagement manageCurrentAlmondChange:almond];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@ is the sceneslist in testmangeCurrentAlmondChange",toolkit.scenesArray);
        
        XCTAssertEqual(toolkit.scenesArray.count,0);
        XCTAssertEqual(toolkit.devices.count,0);
        XCTAssertEqual(toolkit.ruleList.count,0);
        XCTAssertEqual(toolkit.clients.count,0);
        
        if(toolkit.isCloudReachable){
            XCTAssertEqual([ConnectionStatus getConnectionStatus], AUTHENTICATED);
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
        [AlmondManagement manageCurrentAlmondChange:almond];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(21.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(toolkit.scenesArray.count,0);
        XCTAssertEqual(toolkit.devices.count,0);
        XCTAssertEqual(toolkit.ruleList.count,0);
        XCTAssertEqual(toolkit.clients.count,0);
        XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:22.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


#pragma mark - Almond List management
-(void) testManageCurrentAlmondOnAlmondListUpdate{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    NSMutableArray* almondList = [NSMutableArray new];
    SFIAlmondPlus* singleAlmond = [SFIAlmondPlus new];
    singleAlmond.almondplusMAC = @"SingleAlmond";
    [almondList addObject:singleAlmond];
    SFIAlmondPlus* currentAlmond = [SFIAlmondPlus new];
    currentAlmond.almondplusMAC = @"CurrentAlmond";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        NSLog(@"current almond name in testing %@:",[toolkit currentAlmond].almondplusName);
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"SingleAlmond");
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
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(11.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"firstAlmond");
        
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
        [almondList addObject:currentAlmond];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toolkit writeCurrentAlmond:currentAlmond];
        NSLog(@"current almond name in testing %@:",[toolkit currentAlmond].almondplusName);
        [AlmondManagement manageCurrentAlmondOnAlmondListUpdate:almondList manageCurrentAlmondChange:NO];
        NSLog(@"current almond name in testing %@:",[toolkit currentAlmond].almondplusName);
        XCTAssertEqualObjects([toolkit currentAlmond].almondplusMAC, @"CurrentAlmond");
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:22.0 handler:^(NSError *error) {
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
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [LocalNetworkManagement storeLocalNetworkSettings:settings];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
        
        [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:settings.almondplusMAC];
        
        XCTAssertNil([LocalNetworkManagement localNetworkSettingsForAlmond:settings.almondplusMAC]);
        
        [defaults setInteger:SFIAlmondConnectionMode_local forKey:kPREF_DEFAULT_CONNECTION_MODE];
        
        [LocalNetworkManagement storeLocalNetworkSettings:settings];
        
        [AlmondManagement writeCurrentAlmond:almond];
        
        [LocalNetworkManagement removeLocalNetworkSettingsForAlmond:settings.almondplusMAC];
        
        //almond = [AlmondManagement currentAlmond];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
        [expectation fulfill];
    });
    
    
    [self waitForExpectationsWithTimeout:22.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
