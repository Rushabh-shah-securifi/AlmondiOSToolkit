//
//  Log.h
//  SecurifiToolkit
//
//  Created by Masood on 10/18/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#ifndef Log_h
#define Log_h
#import <Foundation/Foundation.h>

#define NSLog(args...) _Log(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
@interface Log : NSObject
void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...);
@end
#endif /* Log_h */
