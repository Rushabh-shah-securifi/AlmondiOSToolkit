//
//  GenericCommandResponse.m
//  SecurifiToolkit
//
//  Created by Priya Yerunkar on 29/10/13.
//  Copyright (c) 2013 Securifi Ltd. All rights reserved.
//

#import "GenericCommandResponse.h"

@implementation GenericCommandResponse

- (NSData *)decodedData {
    NSString *data = self.genericData;
    if (data) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:data options:0];
        return decodedData;
    }
    else {
        return [NSData data];
    }
}

@end
