//
//  VideoView.h
//  ACE
//
//  Created by Norayr Harutyunyan on 11/12/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LinphoneManager.h"

@interface VideoView : NSView

@property (nonatomic, assign) LinphoneCall* call;

- (void)setIncomingCall:(LinphoneCall*)acall;
- (void)setOutgoingCall:(LinphoneCall*)acall;
- (void)showSecondIncomingCallView:(LinphoneCall*)aCall;
- (void)hideSecondIncomingCallView;
- (void)setCallToSecondCallView:(LinphoneCall*)aCall;
- (void)hideSecondCallView;
- (void)setMouseInCallWindow;
- (void)showVideoPreview;
- (void)windowWillEnterFullScreen;
- (void)windowDidEnterFullScreen;
- (void)windowWillExitFullScreen;
- (void)windowDidExitFullScreen;

@property (weak) IBOutlet NSView *remoteVideoView;

@end
