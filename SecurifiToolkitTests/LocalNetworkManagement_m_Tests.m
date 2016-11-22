//
//  LocalNetworkManagement_m_Tests.m
//  SecurifiToolkit
//
//  Created by Masood on 11/22/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Securifitoolkit.h"
#import "AlmondManagement.h"
#import "SFIAlmondLocalNetworkSettings.h"
#import "LocalNetworkManagement.h"
#import "SFIAlmondPlus.h"
#import "ConnectionStatus.h"


@interface LocalNetworkManagement_m_Tests : XCTestCase

@end

@implementation LocalNetworkManagement_m_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
