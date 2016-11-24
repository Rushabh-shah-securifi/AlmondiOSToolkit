//
//  AlmondManagement_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
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

@interface AlmondManagement_m_Tests : XCTestCase
@property BOOL currentAlmondDidChange;
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

@end
