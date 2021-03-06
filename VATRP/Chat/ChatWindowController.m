//
//  ChatWindowController.m
//  ACE
//
//  Created by Ruben Semerjyan on 10/13/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import "ChatWindowController.h"

@interface ChatWindowController ()

@property (strong) ChatViewController* chatViewController;

@end

@implementation ChatWindowController

@synthesize isShow;

-(id) init
{
    self = [super initWithWindowNibName:@"ChatWindowController"];
    if (self)
    {
        // init
    }
    return self;
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myWindowWillClose:) name:NSWindowWillCloseNotification object:[self window]];
    
    self.isShow = YES;
    
    self.chatViewController = [[ChatViewController alloc] init];
    [self.window.contentView addSubview:[self.chatViewController view]];
    [self.chatViewController initializeData];
    [self.window setTitle:@"Messages"];

}

- (void)myWindowWillClose:(NSNotification *)notification {
    self.isShow = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClosedMessagesWindow" object:nil];
}

- (ChatViewController*) getChatViewController {
    return (ChatViewController*)self.contentViewController;
}

@end
