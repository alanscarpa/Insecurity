//
//  DataStore.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/25/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore

+ (instancetype)sharedDataStore {
    static DataStore *_sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDataStore = [[DataStore alloc] init];
    });
    
    return _sharedDataStore;
}


@end
