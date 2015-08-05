//
//  TextFields.m
//  Insecurity
//
//  Created by Alan Scarpa on 7/21/15.
//  Copyright (c) 2015 Skytop Designs. All rights reserved.
//

#import "TextFields.h"



@implementation TextFields


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat borderWidth = 5.0;
    CGColorRef borderColor = [UIColor colorWithRed:158/255.0f green:224/255.0f blue:254/255.0f alpha:1.0].CGColor;
    [self.layer setBorderWidth:borderWidth];
    [self.layer setBorderColor:borderColor];
    self.layer.cornerRadius = 10;
    
}







@end
