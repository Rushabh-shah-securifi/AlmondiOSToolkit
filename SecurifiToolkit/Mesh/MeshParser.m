//
//  MeshParser.m
//  SecurifiToolkit
//
//  Created by Masood on 7/29/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "MeshParser.h"

@implementation MeshParser

- (instancetype)init {
    self = [super init];
    [self initNotification];
    return self;
}

-(void)initNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
//    [center addObserver:self
//               selector:@selector(onMeshDynamciResponse:)
//                   name:
//                 object:nil];
    
    
    
}

@end
