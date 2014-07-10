//
//  SUnit.h
//
//  Created by sinclair on 7/10/14.
//
#import <Foundation/Foundation.h>

@class GenericCommand;


typedef NS_ENUM(NSUInteger, SUnitState) {
    SUnitStateNotDispatched = 1,
    SUnitStateWorking,
    SUnitStateWaitingForReply,
    SUnitStateCompletedSuccess,
    SUnitStateCompletedFailed,
    SUnitStateCompletedExpired,
    SUnitStateAborted,
};

// An SUnit is a processing unit for managing the request and response loop associated with
// commands sent to the cloud. The unit encapsulates a state machine and a semaphore latch allowing
// the underlying command runner to coordinate asynchronous I/O while waiting for a reply.
// An SUnit is a single shot unit and discarded after processing. It cannot be resubmitted for re-processing.
@interface SUnit : NSObject

@property (readonly) NSInteger counterTag;

// The command to be executed
@property (readonly) GenericCommand *command;

// The current processing state
@property (readonly) SUnitState processingState;

- (instancetype)initWithCommand:(GenericCommand *)command;

// Called when the unit is about to be dispatched to the network
// counterTag is a numerical identifier for the work unit; for tracking and reporting; should be monotonically incrementing.
- (void)markWorking:(NSInteger)counterTag;

// returns YES if response returned before timeout
// returns NO if waiting timed out
- (BOOL)waitForResponse:(int)timeoutSecs;

// Called when the reply to this work unit's command has been received.
// Indicates whether it was successful or not.
// Releases waiting clients
- (void)markResponse:(BOOL)success;

// Called to release waiting clients and mark the command as aborted.
// Used also to drain the work queue on connection failure or tear down.
- (void)abort;

- (NSString *)description;



@end