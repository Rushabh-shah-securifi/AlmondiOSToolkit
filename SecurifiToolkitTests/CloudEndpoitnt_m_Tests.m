//
//  CloudEndpoitnt_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CloudEndpoint.h"
#import "NetworkConfig.h"
#import "Securifitoolkit.h"
#import "ConnectionStatus.h"
#import "Network.h"

@interface CloudEndpoint_m_Tests : XCTestCase

@end

//This category is added as inputStream and outputStream private properties so cannot be accessed directly by creating a test category
@interface CloudEndpoint (Tests)
- (NSInputStream *)inputStream;
- (NSOutputStream *)outputStream;
@end

@implementation CloudEndpoint_m_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testConnect_CloudEndPoint {
    //running this test case assuming that the cloud is reachable and test cases does not work properly when cloud goes down mean while
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    dispatch_queue_t networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
    SecurifiConfigurator* configurator = [SecurifiConfigurator new];
    
    NetworkConfig* networkConfig = [NetworkConfig cloudConfig:configurator useProductionHost:YES];
    
    Network* network = [Network networkWithNetworkConfig:networkConfig callbackQueue:networkCallbackQueue dynamicCallbackQueue:networkDynamicCallbackQueue];
    
    NetworkConfig* config = [NetworkConfig new];
    config.host = @"cloud.securifi.com";
    config.port = 1028;
    CloudEndpoint* endpoint = [CloudEndpoint endpointWithConfig:config];
    endpoint.delegate = network;
    network.endpoint = endpoint;
    
    [endpoint connect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
        XCTAssertNotNil(endpoint.outputStream);
        XCTAssertNotNil(endpoint.inputStream);
        
        //if it is alreay connected then we wont reconnect so it returns right away
        [endpoint connect];
        XCTAssertEqual([ConnectionStatus getConnectionStatus], CONNECTED_TO_NETWORK);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:6.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}


-(void) testShutDown_CloudEndPoint {
    //running this test case assuming that the cloud is reachable and test cases does not work properly when cloud goes down mean while
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    
    XCTAssertTrue([SecurifiToolkit sharedInstance].isCloudReachable);
    dispatch_queue_t networkCallbackQueue = dispatch_queue_create("socket_callback", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t networkDynamicCallbackQueue = dispatch_queue_create("socket_dynamic_callback", DISPATCH_QUEUE_CONCURRENT);
    SecurifiConfigurator* configurator = [SecurifiConfigurator new];
    
    NetworkConfig* networkConfig = [NetworkConfig cloudConfig:configurator useProductionHost:YES];
    
    Network* network = [Network networkWithNetworkConfig:networkConfig callbackQueue:networkCallbackQueue dynamicCallbackQueue:networkDynamicCallbackQueue];
    
    NetworkConfig* config = [NetworkConfig new];
    config.host = @"cloud.securifi.com";
    config.port = 1028;
    CloudEndpoint* endpoint = [CloudEndpoint endpointWithConfig:config];
    endpoint.delegate = network;
    network.endpoint = endpoint;
    
    [endpoint connect];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [endpoint shutdown];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertNil(endpoint.inputStream);
        XCTAssertNil(endpoint.outputStream);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
