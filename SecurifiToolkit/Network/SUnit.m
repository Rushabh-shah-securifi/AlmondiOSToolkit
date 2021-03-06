//
//  SUnit.h
//
//  Created by sinclair on 7/10/14.
//
#import "SUnit.h"
#import "GenericCommand.h"


@interface SUnit ()
@property(nonatomic, readonly) dispatch_semaphore_t completion_latch;
@property(nonatomic, readonly) NSDate *startDispatchTime;
@property(nonatomic, readonly) NSDate *endDispatchTime;
@end

@implementation SUnit

- (instancetype)initWithCommand:(GenericCommand *)command {
    self = [super init];
    if (self) {
        _command = command;
        _processingState = SUnitStateNotDispatched;
        _completion_latch = dispatch_semaphore_create(0);
    }

    return self;
}

- (void)markWorking:(NSInteger)counterTag {
    if (self.processingState != SUnitStateNotDispatched) {
        return;
    }
    _counterTag = counterTag;
    _processingState = SUnitStateWorking;
    _startDispatchTime = [NSDate date];
}

- (BOOL)waitForResponse:(int)numSecsToWait {
    dispatch_time_t max_time = dispatch_time(DISPATCH_TIME_NOW, numSecsToWait * NSEC_PER_SEC);

    BOOL timedOut = NO;

    dispatch_time_t blockingSleepSecondsIfNotDone;
    do {
        if (self.processingState != SUnitStateWorking) {
            break;
        }

        const int waitMs = 5;
        blockingSleepSecondsIfNotDone = dispatch_time(DISPATCH_TIME_NOW, waitMs * NSEC_PER_MSEC);

        timedOut = blockingSleepSecondsIfNotDone > max_time;
        if (timedOut) {
            DLog(@"Giving up on waiting for response. Timeout reached: %@", self);
            break;
        }
    }
    while (0 != dispatch_semaphore_wait(self.completion_latch, blockingSleepSecondsIfNotDone));

    // make sure...
    dispatch_semaphore_signal(self.completion_latch);

    if (timedOut) {
        [self markExpired];
    }
    return timedOut;
}

- (void)markExpired {
    if (self.processingState != SUnitStateWorking) {
        return;
    }
    _processingState = SUnitStateCompletedExpired;
}

- (void)markResponse:(BOOL)success {
    if (self.processingState != SUnitStateWorking) {
        return;
    }
    _processingState = success ? SUnitStateCompletedSuccess : SUnitStateCompletedFailed;
    _endDispatchTime = [NSDate date];
}

- (void)abort {
    switch (self.processingState) {
        case SUnitStateNotDispatched:
        case SUnitStateWorking:
        case SUnitStateWaitingForReply:
            _processingState = SUnitStateAborted;
            break;

        // do nothing; already terminated
        case SUnitStateCompletedSuccess:
        case SUnitStateCompletedFailed:
        case SUnitStateCompletedExpired:
        case SUnitStateAborted:
            break;
    }
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.counterTag=%ld", (long)self.counterTag];
    [description appendFormat:@", self.command=%@", self.command];
    [description appendFormat:@", command.data=%@", self.command.command];
    [description appendFormat:@", self.processingState=%lu", (unsigned long)self.processingState];
    [description appendFormat:@", self.completion_latch=%@", self.completion_latch];
    [description appendString:@">"];
    return description;
}

- (NSTimeInterval)timeToCompletionSuccess {
    if (self.processingState == SUnitStateCompletedSuccess) {
        return [self.endDispatchTime timeIntervalSinceDate:self.startDispatchTime];
    }
    return 0;
}

@end