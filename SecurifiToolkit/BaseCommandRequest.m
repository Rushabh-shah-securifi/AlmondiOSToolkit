//
//  BaseCommandRequest.h
//
//  Created by sinclair on 10/22/14.
//

#import "BaseCommandRequest.h"
#import "SFIXmlWriter.h"

@implementation BaseCommandRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        // correlation id sent to cloud and returned in response
        _correlationId = (arc4random() % 1000) + 1;
        _created = [NSDate date];
    }

    return self;
}

- (void)addMobileInternalIndexElement:(SFIXmlWriter *)writer {
    NSString *value = [NSString stringWithFormat:@"%d", _correlationId];
    [writer addElement:@"MobileInternalIndex" text:value];
}

- (BOOL)shouldExpireAfterSeconds:(NSTimeInterval)timeOutSecsAfterCreation {
    NSTimeInterval elapsed = [self.created timeIntervalSinceNow];
    elapsed = fabs(elapsed);
    return elapsed >= timeOutSecsAfterCreation;
}

- (BOOL)isExpired {
    return [self shouldExpireAfterSeconds:5];
}

- (NSData *)serializeJson:(NSDictionary *)payload {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        NSLog(@"serializeJson: error serializing JSON, payload:%@, error:%@", payload, error.description);
        return [NSData data];
    }

    return data;
}

@end