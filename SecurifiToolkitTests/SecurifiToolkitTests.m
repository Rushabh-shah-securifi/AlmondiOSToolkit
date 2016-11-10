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

- (void)testAsyncInitNetwork
{
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

@end
