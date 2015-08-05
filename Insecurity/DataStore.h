//
//  DataStore.h
//  Insecurity
//
//  Created by Alan Scarpa on 7/25/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject

+ (instancetype)sharedDataStore;

@property (nonatomic) BOOL isUpgraded;

@end
