//
//  Network_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Network.h"
#import "SecurifiToolkit.h"
#import "NetworkConfig.h"
#import "ConnectionStatus.h"
#import "AlmondManagement.h"
#import "KeyChainAccess.h"

@interface Network_m_Tests : XCTestCase

@end

@implementation Network_m_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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

@end
