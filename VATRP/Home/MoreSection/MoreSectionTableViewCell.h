//
//  MoreSectionTableViewCell.h
//  ACE
//
//  Created by Karen Muradyan on 4/7/16.
//  Copyright © 2016 VTCSecure. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MoreSectionTableViewCell : NSTableCellView

@property (weak) IBOutlet NSImageView *moreSectionLeftImageView;
@property (weak) IBOutlet NSImageView *moreSectionRightImageView;
@property (weak) IBOutlet NSTextField *moreSectionTextField;

@end
