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
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    
    [DateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    fprintf(stderr,"%100s:%3d - %s",funcName, lineNumber, [msg UTF8String]);
}
@end
