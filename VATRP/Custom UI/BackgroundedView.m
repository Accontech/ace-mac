//
//  BackgroundedView.m
//  ACE
//
//  Created by Edgar Sukiasyan on 10/14/15.
//  Copyright © 2015 Home. All rights reserved.
//

#import "BackgroundedView.h"

@interface BackgroundedView () {
    NSColor *_backgroundColor;
}

@end

@implementation BackgroundedView

- (id) init {
    self = [super init];
    
    if (self) {
        _backgroundColor = [NSColor whiteColor];
    }
    
    return self;
}

- (void) setBackgroundColor:(NSColor*)color {
    _backgroundColor = color;
    
    [self needsToDrawRect:self.bounds];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    [_backgroundColor set];
    NSBezierPath * path = [NSBezierPath bezierPathWithRect:self.bounds];
    [path fill];
}

@end
