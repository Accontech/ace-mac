//
//  ContactsService.h
//  ACE
//
//  Created by Zack Matthews on 11/23/15.
//  Copyright © 2015 VTCSecure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactsService : NSObject

+(void) exportContact: (NSString*) firstName : (NSString*) lastName : (NSString*) sipAddress : (NSString*)path;
@end
