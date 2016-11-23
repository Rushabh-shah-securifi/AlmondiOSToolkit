//
//  Network_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

//TODO: write the test cases for connect and shutdown for local network connections

#import <XCTest/XCTest.h>
#import "Network.h"
#import "SecurifiToolkit.h"
#import "NetworkConfig.h"
#import "ConnectionStatus.h"
#import "AlmondManagement.h"
#import "KeyChainAccess.h"
#import "Login.h"

@interface Network_m_Tests : XCTestCase
@property BOOL onLogOutNotification;
@end

@implementation Network_m_Tests

- (void)setUp {
    [super setUp];
    _onLogOutNotification = false;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    _onLogOutNotification = false;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - notifications

-(void) onLogoutNotification:(id)sender {
    NSLog(@"log out notification is called");
    _onLogOutNotification = true;
}

#pragma mark - test methods

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

-(void) testConnect_for_cloud_connection {
    
    //running this test case assuming that the cloud is reachable and test cases does not work properly when cloud goes down mean while
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    dispatch_queue_t networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
    SecurifiConfigurator* configurator = [SecurifiConfigurator new];
    
    NetworkConfig* networkConfig = [NetworkConfig cloudConfig:configurator useProductionHost:YES];
    
    Network* network = [Network networkWithNetworkConfig:networkConfig callbackQueue:networkCallbackQueue dynamicCallbackQueue:networkDynamicCallbackQueue];
    
    network.endpoint = nil;
    [network connect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
        XCTAssertEqualObjects(network.endpoint.delegate, network);
        
        //since it is already connected if we try to connect again then it returns immediately
        [network connect];
        XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:6.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


-(void) test_shutDown_for_cloud_connection {
    //running this test case assuming that the cloud is reachable and test cases does not work properly when cloud goes down mean while
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    dispatch_queue_t networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
    SecurifiConfigurator* configurator = [SecurifiConfigurator new];
    
    NetworkConfig* networkConfig = [NetworkConfig cloudConfig:configurator useProductionHost:YES];
    
    Network* network = [Network networkWithNetworkConfig:networkConfig callbackQueue:networkCallbackQueue dynamicCallbackQueue:networkDynamicCallbackQueue];
    
    //To test that shutdown is working properly we must initially connect and then try to shutdown.
    [network connect];
    
    //shutdown the network after connecting which probably happens within 5 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [network shutdown];
    });
    
    //one second after shutdown asserting the values
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //do assertions here
        XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
        XCTAssertNil(network.endpoint);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


-(void) testNetworkEndPointDidConnect_Delegate_for_CloudConnection_withoutCredentials{
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    Network* network = [Network new];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:SFIAlmondConnectionMode_cloud forKey:kPREF_DEFAULT_CONNECTION_MODE];
    
    [[SecurifiToolkit sharedInstance] tearDownLoginSession];
    [network networkEndpointDidConnect:nil];
    
    XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
}


//TODO: should handle the test case when network goes down and again comes while credentials are present
-(void) testNetworkEndPointDidConnect_Delegate_for_CloudConnection_withCredentials{
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(onLogoutNotification:) name:kSFIDidLogoutNotification object:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    SecurifiToolkit* toolkit = [SecurifiToolkit sharedInstance];
    
    [self authenticate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([KeyChainAccess hasLoginCredentials]);
        [toolkit.network networkEndpointDidConnect:nil];
    });
    
    //when we resend the login request when the session is already running we will get failure login response and login session is broken and credentials are cleared taking to login page
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(_onLogOutNotification);
        XCTAssertFalse([KeyChainAccess hasLoginCredentials]);
        XCTAssertEqual([ConnectionStatus getConnectionStatus], NO_NETWORK_CONNECTION);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:26.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
