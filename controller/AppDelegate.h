//
//  AppDelegate.h
//  controller
//
//  Created by Serghey Vice on 1/23/17.
//  Copyright © 2017 Serghey Vice. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
    @property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
    @property (strong, nonatomic) NSStatusItem *statusItem;
    @property (nonatomic, retain) NSMutableData *responseData;
    


@end

