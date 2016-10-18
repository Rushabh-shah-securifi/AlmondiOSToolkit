//
//  Log.m
//  SecurifiToolkit
//
//  Created by Masood on 10/18/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "Log.h"
@implementation Log
void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...) {
    va_list ap;
    va_start (ap, format);
    format = [format stringByAppendingString:@"\n"];
    NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%@",format] arguments:ap];
    va_end (ap);
    fprintf(stderr,"%s%50s:%3d - %s",[prefix UTF8String], funcName, lineNumber, [msg UTF8String]);
}
@end
